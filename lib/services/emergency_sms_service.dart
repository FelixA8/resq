import 'package:intl/intl.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/httpsms_service.dart';
import 'dart:developer' as developer;

// ============================================================
// FEATURE FLAG: Toggle Emergency SMS Alerts
// ============================================================
// Set to true to send SMS alerts to emergency contacts
// Set to false to disable SMS sending (save costs during development)
const bool SEND_EMERGENCY_SMS = true;
// ============================================================

/// Service for sending emergency SMS alerts to user's emergency contacts
class EmergencySmsService {
  /// Send emergency alerts to all configured emergency contacts
  /// Returns a map with 'sent', 'failed', and 'total' counts
  static Future<Map<String, dynamic>> sendEmergencyAlerts({
    required String userId,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    if (!SEND_EMERGENCY_SMS) {
      developer.log('Emergency SMS: Feature disabled (emergency_sms_service.dart:SEND_EMERGENCY_SMS = false)');
      return {
        'sent': 0,
        'failed': 0,
        'total': 0,
        'skipped': true,
      };
    }

    try {
      // Fetch user and contacts
      final user = await SupabaseService.getUserById(userId);
      if (user == null) {
        developer.log('Emergency SMS: User not found');
        return {'sent': 0, 'failed': 0, 'total': 0};
      }

      final contacts = await SupabaseService.getUserContacts(userId);
      if (contacts.isEmpty) {
        developer.log('Emergency SMS: No emergency contacts configured');
        return {'sent': 0, 'failed': 0, 'total': 0};
      }

      // Get all valid phone numbers
      final phoneNumbers = contacts
          .where((contact) => !(contact.phoneNumber?.isEmpty ?? true))
          .map((contact) => contact.phoneNumber!)
          .toList();

      if (phoneNumbers.isEmpty) {
        developer.log('Emergency SMS: No valid phone numbers found');
        return {'sent': 0, 'failed': 0, 'total': 0};
      }

      // Log contact details
      developer.log('Emergency SMS: Found ${contacts.length} contact(s)');
      for (int i = 0; i < contacts.length; i++) {
        final contact = contacts[i];
        developer.log('Emergency SMS: Contact ${i + 1}: ${contact.contactName} - ${contact.phoneNumber ?? "NO NUMBER"}');
      }

      // Format emergency message
      final message = _formatEmergencyMessage(
        username: user.username ?? 'Unknown User',
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      );

      developer.log('Emergency SMS: Sending to ${phoneNumbers.length} contact(s)');

      // Send SMS to all contacts using httpSMS
      final result = await HttpSmsService.sendBulkSMS(
        recipients: phoneNumbers,
        content: message,
      );

      developer.log('Emergency SMS: Summary - Sent: ${result['sent']}, Failed: ${result['failed']}, Total: ${result['total']}');

      return result;
    } catch (e) {
      developer.log('Emergency SMS: Error sending alerts - $e');
      return {
        'sent': 0,
        'failed': 0,
        'total': 0,
        'error': e.toString(),
      };
    }
  }

  /// Format the emergency message with user info and location
  static String _formatEmergencyMessage({
    required String username,
    required String locationName,
    required double latitude,
    required double longitude,
  }) {
    final timestamp = DateFormat('HH:mm, dd MMM yyyy').format(DateTime.now());
    final mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
    
    return '''DARURAT! $username sedang dalam keadaan darurat.

Lokasi: $locationName
Link: $mapsLink
Waktu: $timestamp

- ResQ Emergency Alert''';
  }
}
