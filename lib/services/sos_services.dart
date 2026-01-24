import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resqapp/services/httpsms_service.dart';
import 'package:resqapp/services/login_services.dart';
import '../models/supabase_models.dart';

class SosServices {
  static final SupabaseClient _client = Supabase.instance.client;
  static final theme = ResQTheme();

  // ==================== SOS Events ====================
  /// Create SOS event
  static Future<SosEvent?> createSosEvent({
    required String userId,
    required double lat,
    required double lng,
  }) async {
    try {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
      final sosData = {
        'user_id': userId,
        'location_lat': lat,
        'location_lng': lng,
        'response_team_id': null,
        'is_current': true,
        'pressed_at': currentTimestamp,
        'assigned_at': 0.0,
        'resolved_at': 0.0,
      };

      final response =
          await _client.from('sos_events').insert(sosData).select().single()
          .timeout(const Duration(seconds: 1));

      return SosEvent.fromJson(response);
    } catch (e) {
      Get.snackbar(
        'Tidak ada koneksi',
        'Mohon periksa koneksi internet anda',
        backgroundColor: theme.colors.primary,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Color(0xffFFFFFF),
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
        isDismissible: true,
      );
      developer.log('Error creating SOS event: $e');
      return null;
    }
  }

  static Future<List<SosEvent>> getSoSEvents() async {
    try {
      final response = await _client
          .from('sos_events')
          .select()
          .order('pressed_at', ascending: true);

      final events =
          (response as List).map((json) => SosEvent.fromJson(json)).toList();

      return events;
    } catch (e) {
      print('Error getting SOS events: $e');
      return [];
    }
  }

  /// Get SOS events for a user
  static Future<SosEvent?> getUserSosEvents(String userId) async {
    try {
      final response =
          await _client
              .from('sos_events')
              .select()
              .eq('user_id', userId)
              .order('sos_id', ascending: false)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        developer.log('No SOS events found for user: $userId');
        return null;
      }

      return SosEvent.fromJson(response);
    } catch (e) {
      developer.log('Error getting SOS events: $e');
      return null;
    }
  }

  /// Assign SOS event to response team
  static Future<bool> assignSosToTeam({
    required String sosId,
    required String responseTeamId,
  }) async {
    try {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();

      await _client
          .from('sos_events')
          .update({
            'response_team_id': responseTeamId,
            'assigned_at': currentTimestamp,
            'is_current': true,
          })
          .eq('sos_id', sosId);

      developer.log('SOS event $sosId assigned to team $responseTeamId');
      return true;
    } catch (e) {
      developer.log('Error assigning SOS: $e');
      return false;
    }
  }

  /// Unassign SOS event from response team
  static Future<bool> unassignSosFromTeam(String sosId) async {
    try {
      await _client
          .from('sos_events')
          .update({'response_team_id': null, 'assigned_at': 0.0})
          .eq('sos_id', sosId);

      developer.log('SOS event $sosId unassigned');
      return true;
    } catch (e) {
      developer.log('Error unassigning SOS: $e');
      return false;
    }
  }

  /// Resolve SOS event
  static Future<bool> resolveSosEvent(String sosId) async {
    try {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();

      await _client
          .from('sos_events')
          .update({'resolved_at': currentTimestamp, 'is_current': false})
          .eq('sos_id', sosId)
          .eq('is_current', true);

      developer.log('SOS event $sosId resolved');
      return true;
    } catch (e) {
      developer.log('Error resolving SOS: $e');
      return false;
    }
  }

  /// Complete SOS event (set is_current to false)
  static Future<bool> completeSosEvent(String sosId) async {
    try {
      await _client
          .from('sos_events')
          .update({'is_current': false})
          .eq('sos_id', sosId);

      developer.log('SOS event $sosId completed');
      return true;
    } catch (e) {
      developer.log('Error completing SOS: $e');
      return false;
    }
  }

  /// Delete SOS event by user ID
  static Future<bool> deleteSosEventByUserId(String userId) async {
    try {
      await _client.from('sos_events').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      developer.log('Error deleting SOS event: $e');
      return false;
    }
  }

  /// Delete SOS event by SOS ID
  static Future<bool> deleteSosEventById(String sosId) async {
    try {
      await _client.from('sos_events').delete().eq('sos_id', sosId);
      return true;
    } catch (e) {
      developer.log('Error deleting SOS event: $e');
      return false;
    }
  }

  /// Get paginated SOS events (for SOS report list)
  /// Returns active SOS events ordered by most recent first
  static Future<List<SosEvent>> getPaginatedSosEvents({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('sos_events')
          .select()
          .eq('is_current', true)
          .order('pressed_at', ascending: false)
          .range(offset, offset + limit - 1);

      final events =
          (response as List).map((json) => SosEvent.fromJson(json)).toList();

      developer.log(
        'Fetched ${events.length} SOS events (offset: $offset, limit: $limit)',
      );
      return events;
    } catch (e) {
      developer.log('Error getting paginated SOS events: $e');
      return [];
    }
  }

  /// Get total count of active SOS events
  static Future<int> getActiveSosEventsCount() async {
    try {
      final response = await _client
          .from('sos_events')
          .select('sos_id')
          .eq('is_current', true);

      return (response as List).length;
    } catch (e) {
      developer.log('Error getting SOS events count: $e');
      return 0;
    }
  }

  // ==================== Contacts ====================
  /// Get user's emergency contacts
  static Future<List<Contact>> getContactList(String userId) async {
    try {
      final response = await _client
          .from('contacts')
          .select()
          .eq('user_id', userId);

      return (response as List).map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error getting contacts: $e');
      return [];
    }
  }

  /// Add emergency contact
  static Future<bool> addContact(Contact contact) async {
    try {
      await _client.from('contacts').insert(contact.toJson());
      return true;
    } catch (e) {
      developer.log('Error adding contact: $e');
      return false;
    }
  }

  static Future<bool> upsertContact(Contact contact) async {
    try {
      await _client
          .from('contacts')
          .delete()
          .eq('user_id', contact.userId)
          .eq('contact_name', contact.contactName);

      // Insert new/updated contact
      await _client.from('contacts').insert(contact.toJson());
      return true;
    } catch (e) {
      developer.log('Error upserting contact: $e');
      return false;
    }
  }

  /// Update emergency contact
  static Future<bool> updateContact(Contact contact) async {
    try {
      await _client
          .from('contacts')
          .update(contact.toJson())
          .eq('user_id', contact.userId)
          .eq('contact_name', contact.contactName);
      return true;
    } catch (e) {
      developer.log('Error updating contact: $e');
      return false;
    }
  }

  /// Delete emergency contact
  static Future<bool> deleteContact(String userId, String contactName) async {
    try {
      await _client
          .from('contacts')
          .delete()
          .eq('user_id', userId)
          .eq('contact_name', contactName);
      return true;
    } catch (e) {
      developer.log('Error deleting contact: $e');
      return false;
    }
  }
}

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
  static Future<Map<String, dynamic>> sendEmergencyAlerts({
    required String userId,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    if (!SEND_EMERGENCY_SMS) {
      developer.log(
        'Emergency SMS: Feature disabled (sos_services.dart:SEND_EMERGENCY_SMS = false)',
      );
      return {'sent': 0, 'failed': 0, 'total': 0, 'skipped': true};
    }

    try {
      final user = await LoginServices.getUserById(userId);
      if (user == null) {
        developer.log('Emergency SMS: User not found');
        return {'sent': 0, 'failed': 0, 'total': 0};
      }

      final contacts = await SosServices.getContactList(userId);
      if (contacts.isEmpty) {
        developer.log('Emergency SMS: No emergency contacts configured');
        return {'sent': 0, 'failed': 0, 'total': 0};
      }

      final phoneNumbers =
          contacts
              .where((contact) => !(contact.phoneNumber?.isEmpty ?? true))
              .map((contact) => contact.phoneNumber!)
              .toList();

      if (phoneNumbers.isEmpty) {
        developer.log('Emergency SMS: No valid phone numbers found');
        return {'sent': 0, 'failed': 0, 'total': 0};
      }

      developer.log('Emergency SMS: Found ${contacts.length} contact(s)');
      for (int i = 0; i < contacts.length; i++) {
        final contact = contacts[i];
        developer.log(
          'Emergency SMS: Contact ${i + 1}: ${contact.contactName} - ${contact.phoneNumber ?? "NO NUMBER"}',
        );
      }

      final message = _formatEmergencyMessage(
        username: user.username ?? 'Unknown User',
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      );

      developer.log(
        'Emergency SMS: Sending to ${phoneNumbers.length} contact(s)',
      );

      // Send SMS to all contacts using httpSMS
      final result = await HttpSmsService.sendBulkSMS(
        recipients: phoneNumbers,
        content: message,
      );

      developer.log(
        'Emergency SMS: Summary - Sent: ${result['sent']}, Failed: ${result['failed']}, Total: ${result['total']}',
      );

      return result;
    } catch (e) {
      developer.log('Emergency SMS: Error sending alerts - $e');
      return {'sent': 0, 'failed': 0, 'total': 0, 'error': e.toString()};
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
