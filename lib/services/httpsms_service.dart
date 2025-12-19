import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

/// Service for httpSMS - Uses your Android phone as SMS gateway
/// Documentation: https://httpsms.com/docs
class HttpSmsService {
  static const String _baseUrl = 'https://api.httpsms.com/v1/messages/send';
  
  // Load credentials from .env file
  static String get _apiKey => dotenv.env['HTTPSMS_API_KEY'] ?? '';
  static String get _fromNumber => dotenv.env['HTTPSMS_FROM_NUMBER'] ?? '';
  
  /// Check if service is configured
  static bool get isConfigured {
    return _apiKey.isNotEmpty && _fromNumber.isNotEmpty;
  }

  /// Send SMS to a single recipient
  /// Returns a map with 'success' (bool) and 'message' (String)
  static Future<Map<String, dynamic>> sendSMS({
    required String to,
    required String content,
  }) async {
    if (!isConfigured) {
      return {
        'success': false,
        'message': 'httpSMS not configured (missing API key or phone number)',
      };
    }

    try {
      final requestBody = {
        'from': _fromNumber,
        'to': to,
        'content': content,
      };

      developer.log('httpSMS: Sending to $to');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('httpSMS: ✅ SMS sent successfully to $to');
        
        return {
          'success': true,
          'message': 'SMS sent successfully',
        };
      } else {
        final errorBody = response.body;
        developer.log('httpSMS: ❌ Failed (${response.statusCode}): $errorBody');
        
        return {
          'success': false,
          'message': 'Failed to send SMS (${response.statusCode})',
        };
      }
    } catch (e) {
      developer.log('httpSMS: Error - $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Send SMS to multiple recipients (sends individually)
  /// Returns a map with 'sent', 'failed', and 'total' counts
  static Future<Map<String, dynamic>> sendBulkSMS({
    required List<String> recipients,
    required String content,
  }) async {
    if (!isConfigured) {
      return {
        'sent': 0,
        'failed': recipients.length,
        'total': recipients.length,
        'message': 'httpSMS not configured',
      };
    }

    int sent = 0;
    int failed = 0;

    for (final recipient in recipients) {
      final result = await sendSMS(to: recipient, content: content);
      
      if (result['success']) {
        sent++;
      } else {
        failed++;
      }
      
      // Small delay between messages to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    developer.log('httpSMS: Bulk send complete - Sent: $sent, Failed: $failed');

    return {
      'sent': sent,
      'failed': failed,
      'total': recipients.length,
    };
  }
}
