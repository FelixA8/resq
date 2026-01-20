import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

/// Service for Message Central VerifyNow API
/// Documentation: https://cpaas-bucket.s3.ap-south-1.amazonaws.com/Message_Central_Verify_Now_API_Doc.pdf
class MessageCentralService {
  static const String _baseUrl = 'https://cpaas.messagecentral.com';

  // Load credentials from .env file
  static String get _customerId =>
      dotenv.env['MESSAGE_CENTRAL_CUSTOMER_ID'] ?? '';
  static String get _apiKey => dotenv.env['MESSAGE_CENTRAL_API_KEY'] ?? '';
  static String get _countryCode =>
      dotenv.env['MESSAGE_CENTRAL_COUNTRY_CODE'] ?? '62';
  static String get _senderId =>
      dotenv.env['MESSAGE_CENTRAL_SENDER_ID'] ?? 'RESQAP';

  // WORKAROUND: If token generation fails, you can paste a pre-generated token here
  static String get _preGeneratedToken =>
      dotenv.env['MESSAGE_CENTRAL_AUTH_TOKEN'] ?? '';

  // Cache the auth token
  static String? _cachedAuthToken;
  static DateTime? _tokenExpiry;

  /// Check if service is configured with credentials
  static bool get isConfigured {
    // Either have credentials OR a pre-generated token
    return (_customerId.isNotEmpty && _apiKey.isNotEmpty) ||
        _preGeneratedToken.isNotEmpty;
  }

  /// Generate authentication token
  static Future<String?> _generateToken() async {
    if (_preGeneratedToken.isNotEmpty) {
      developer.log('Message Central: Using pre-generated authToken from .env');
      return _preGeneratedToken;
    }

    if (_cachedAuthToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedAuthToken;
    }

    try {
      final url = Uri.parse('$_baseUrl/auth/v1/authentication/token');

      developer.log('Message Central: Attempting token generation...');
      developer.log('Customer ID length: ${_customerId.length}');
      developer.log('API Key length: ${_apiKey.length}');
      developer.log('Country Code: $_countryCode');

      final requestBody = {
        'customerId': _customerId,
        'key': _apiKey,
        'scope': 'NEW',
        'country': _countryCode,
      };

      developer.log('Request body keys: ${requestBody.keys.join(", ")}');

      final response = await http.post(
        url,
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedAuthToken = data['data']?['authToken'];
        // Cache token for 23 hours (tokens typically last 24 hours)
        _tokenExpiry = DateTime.now().add(const Duration(hours: 23));

        developer.log('Message Central: Token generated successfully');
        return _cachedAuthToken;
      } else {
        developer.log(
          'Message Central: Token generation failed - ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      developer.log('Message Central: Token generation error - $e');
      return null;
    }
  }

  /// Send OTP to a phone number
  static Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    int otpLength = 6,
  }) async {
    if (!isConfigured) {
      return {
        'success': false,
        'verificationId': null,
        'message': 'Message Central credentials not configured',
      };
    }

    try {
      final authToken = await _generateToken();
      if (authToken == null) {
        return {
          'success': false,
          'verificationId': null,
          'message': 'Failed to generate authentication token',
        };
      }

      String cleanNumber = phoneNumber
          .replaceAll('+', '')
          .replaceAll(' ', '')
          .replaceAll('-', '');

      // Remove country code if present
      if (cleanNumber.startsWith(_countryCode)) {
        cleanNumber = cleanNumber.substring(_countryCode.length);
      }

      final url = Uri.parse('$_baseUrl/verification/v3/send');

      final queryParams = {
        'countryCode': _countryCode,
        'customerId': _customerId,
        'flowType': 'SMS',
        'mobileNumber': cleanNumber,
        'otpLength': otpLength.toString(),
        'senderId': _senderId,
      };

      final response = await http.post(
        url.replace(queryParameters: queryParams),
        headers: {'authToken': authToken, 'accept': '*/*'},
      );

      final data = jsonDecode(response.body);
      final responseCode = data['responseCode'] ?? response.statusCode;

      if (responseCode == 200) {
        final verificationId = data['data']?['verificationId'];
        developer.log(
          'Message Central: OTP sent successfully - verificationId: $verificationId',
        );

        return {
          'success': true,
          'verificationId': verificationId?.toString(),
          'message': 'OTP sent successfully',
        };
      } else {
        final errorMessage = _getErrorMessage(responseCode);
        developer.log(
          'Message Central: Send OTP failed - $responseCode: $errorMessage',
        );

        return {
          'success': false,
          'verificationId': null,
          'message': errorMessage,
        };
      }
    } catch (e) {
      developer.log('Message Central: Send OTP error - $e');
      return {
        'success': false,
        'verificationId': null,
        'message': 'Failed to send OTP: $e',
      };
    }
  }

  /// Validate OTP code
  static Future<Map<String, dynamic>> validateOtp({
    required String verificationId,
    required String code,
    required String phoneNumber,
  }) async {
    if (!isConfigured) {
      return {
        'success': false,
        'message': 'Message Central credentials not configured',
      };
    }

    try {
      final authToken = await _generateToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Failed to generate authentication token',
        };
      }

      String cleanNumber = phoneNumber
          .replaceAll('+', '')
          .replaceAll(' ', '')
          .replaceAll('-', '');

      if (cleanNumber.startsWith(_countryCode)) {
        cleanNumber = cleanNumber.substring(_countryCode.length);
      }

      final url = Uri.parse('$_baseUrl/verification/v3/validateOtp');

      final queryParams = {
        'countryCode': _countryCode,
        'mobileNumber': cleanNumber,
        'verificationId': verificationId,
        'customerId': _customerId,
        'code': code,
      };

      final response = await http.get(
        url.replace(queryParameters: queryParams),
        headers: {'authToken': authToken},
      );

      final data = jsonDecode(response.body);
      final responseCode = data['responseCode'] ?? response.statusCode;

      if (responseCode == 200) {
        final verificationStatus = data['data']?['verificationStatus'];

        if (verificationStatus == 'VERIFICATION_COMPLETED') {
          developer.log('Message Central: OTP validated successfully');
          return {'success': true, 'message': 'OTP verified successfully'};
        } else {
          developer.log(
            'Message Central: OTP validation incomplete - $verificationStatus',
          );
          return {'success': false, 'message': 'OTP verification incomplete'};
        }
      } else {
        final errorMessage = _getErrorMessage(responseCode);
        developer.log(
          'Message Central: Validate OTP failed - $responseCode: $errorMessage',
        );

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      developer.log('Message Central: Validate OTP error - $e');
      return {'success': false, 'message': 'Failed to validate OTP: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    if (!isConfigured) {
      return {
        'success': false,
        'message': 'Message Central credentials not configured',
      };
    }

    try {
      final authToken = await _generateToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Failed to generate authentication token',
        };
      }

      String cleanNumber = phoneNumber
          .replaceAll('+', '')
          .replaceAll(' ', '')
          .replaceAll('-', '');

      if (cleanNumber.startsWith(_countryCode)) {
        cleanNumber = cleanNumber.substring(_countryCode.length);
      }

      final url = Uri.parse('$_baseUrl/verification/v3/send');

      final queryParams = {
        'countryCode': _countryCode,
        'customerId': _customerId,
        'senderId': _senderId,
        'type': 'SMS',
        'flowType': 'SMS',
        'mobileNumber': cleanNumber,
        'message': message,
      };

      final response = await http.post(
        url.replace(queryParameters: queryParams),
        headers: {'authToken': authToken, 'accept': '*/*'},
      );

      final data = jsonDecode(response.body);
      final responseCode = data['responseCode'] ?? response.statusCode;

      if (responseCode == 200) {
        developer.log('Message Central: SMS sent successfully to $cleanNumber');

        return {'success': true, 'message': 'SMS sent successfully'};
      } else {
        final errorMessage = _getErrorMessage(responseCode);
        developer.log(
          'Message Central: Send SMS failed - $responseCode: $errorMessage',
        );

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      developer.log('Message Central: Send SMS error - $e');
      return {'success': false, 'message': 'Failed to send SMS: $e'};
    }
  }

  static String _getErrorMessage(int code) {
    switch (code) {
      case 400:
        return 'Invalid request';
      case 409:
        return 'Duplicate request';
      case 500:
        return 'Server error';
      case 501:
        return 'Invalid customer ID';
      case 505:
        return 'Invalid verification ID';
      case 506:
        return 'Request already exists';
      case 511:
        return 'Invalid country code';
      case 700:
        return 'Verification failed';
      case 702:
        return 'Wrong OTP code';
      case 703:
        return 'Already verified';
      case 705:
        return 'OTP expired';
      case 800:
        return 'Maximum attempts reached';
      case 913:
        return 'Account expired';
      default:
        return 'An error occurred (code: $code)';
    }
  }
}
