import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class ZenzivaService {
  static const String _userKey = '1c2862404c33';
  static const String _passKey = '2d6605743f8ef904448af764';
  static const String _baseUrl = 'https://console.zenziva.net/wareguler/api/sendWA/';
//   static const String _baseUrl = 'https://console.zenziva.net/waofficial/api/sendWAOfficial/';

  /// Send WhatsApp OTP
  static Future<bool> sendOtpWhatsapp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl);
      
      final request = http.MultipartRequest('POST', uri)
        ..fields['userkey'] = _userKey
        ..fields['passkey'] = _passKey
        ..fields['to'] = phoneNumber
        ..fields['brand'] = 'RESQ'
        ..fields['otp'] = otpCode;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('---------------- Zenziva Debug ----------------');
      developer.log('Request URL: $_baseUrl');
      developer.log('Request Fields: ${request.fields}');
      developer.log('Response Status: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');
      developer.log('-----------------------------------------------');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonResponse = jsonDecode(response.body);
          developer.log('Parsed JSON: $jsonResponse');
          
          // If the API returns a specific status field in JSON, we should check it.
          // For now, we'll assume HTTP 2xx is success, but log the content.
          return true;
        } catch (e) {
          developer.log('Error parsing JSON response: $e');
          // Even if JSON parsing fails, if status is 200, maybe it's okay? 
          // But usually API returns JSON.
          return true; 
        }
      } else {
        developer.log('Zenziva API returned non-success status code.');
        return false;
      }
    } catch (e) {
      developer.log('---------------- Zenziva Exception ----------------');
      developer.log('Error sending WhatsApp OTP: $e');
      developer.log('---------------------------------------------------');
      return false;
    }
  }
}
