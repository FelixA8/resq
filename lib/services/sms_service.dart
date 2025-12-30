import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class SmsService {
  static Future<bool> sendOtpSms({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final message =
          'Your ResQ verification code is: $otpCode\n\nThis code will expire in 15 minutes.';
      final smsUrl = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      final canLaunch = await canLaunchUrl(smsUrl);
      if (canLaunch) {
        await launchUrl(smsUrl);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      developer.log('SMS Error: $e');
      return false;
    }
  }

  /// Check if SMS app can be launched
  static Future<bool> canSendSms() async {
    try {
      final smsUrl = Uri(scheme: 'sms', path: '');
      return await canLaunchUrl(smsUrl);
    } catch (e) {
      developer.log('SMS Check Error: $e');
      return false;
    }
  }
}
