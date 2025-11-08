import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class SmsService {
  /// Send SMS with OTP code
  /// For POC: Opens SMS app with pre-filled message
  static Future<bool> sendOtpSms({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final message =
          'Your ResQ verification code is: $otpCode\n\nThis code will expire in 15 minutes.';

      // For development/testing - print to console
      if (kDebugMode) {
        print('📱 SMS Service - Opening SMS App');
        print('📞 Phone: $phoneNumber');
        print('🔐 Code: $otpCode');
        print('💬 Message: $message');
      }

      // Create SMS URL
      final smsUrl = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      // Launch SMS app
      final canLaunch = await canLaunchUrl(smsUrl);
      if (canLaunch) {
        await launchUrl(smsUrl);

        if (kDebugMode) {
          print('📤 SMS app opened successfully');
        }

        return true;
      } else {
        if (kDebugMode) {
          print('❌ Cannot launch SMS app');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SMS Error: $e');
      }
      return false;
    }
  }

  /// Check if SMS app can be launched
  static Future<bool> canSendSms() async {
    try {
      final smsUrl = Uri(scheme: 'sms', path: '');
      return await canLaunchUrl(smsUrl);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SMS Check Error: $e');
      }
      return false;
    }
  }

  /// Send SMS with custom message (for other use cases)
  static Future<bool> sendCustomSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      if (kDebugMode) {
        print('📱 SMS Service - Opening SMS App (Custom)');
        print('📞 Phone: $phoneNumber');
        print('💬 Message: $message');
      }

      // Create SMS URL
      final smsUrl = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      // Launch SMS app
      final canLaunch = await canLaunchUrl(smsUrl);
      if (canLaunch) {
        await launchUrl(smsUrl);

        if (kDebugMode) {
          print('📤 Custom SMS app opened successfully');
        }

        return true;
      } else {
        if (kDebugMode) {
          print('❌ Cannot launch SMS app');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SMS Error: $e');
      }
      return false;
    }
  }

  /// For POC: Show OTP code in debug mode (since we can't auto-send)
  static void showOtpForTesting({
    required String phoneNumber,
    required String otpCode,
  }) {
    if (kDebugMode) {
      print('🔐 ===== OTP CODE FOR TESTING =====');
      print('📞 Phone: $phoneNumber');
      print('🔢 OTP Code: $otpCode');
      print('⏰ Valid for 15 minutes');
      print('🔐 ================================');
    }
  }
}
