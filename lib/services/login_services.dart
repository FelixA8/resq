import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:resqapp/theme/theme_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_models.dart';

class LoginServices {
  static final SupabaseClient _client = Supabase.instance.client;
  static final theme = ResQTheme();

  /// Test Supabase connection
  static Future<bool> testConnection() async {
    try {
      final _ = await _client
          .from('users')
          .select('count')
          .limit(1)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Connection timeout after 10 seconds');
            },
          );

      return true;
    } catch (e) {
      developer.log('Supabase connection failed: $e');
      return false;
    }
  }

  // ==================== Users ====================
  /// Get a user by ID
  static Future<ResqUser?> getUserById(String userId) async {
    try {
      final response =
          await _client
              .from('users')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      return response != null ? ResqUser.fromJson(response) : null;
    } catch (e) {
      developer.log('Error getting user: $e');
      return null;
    }
  }

  static Future<ResqUser?> getUserByPhone(String phoneNumber) async {
    try {
      final response =
          await _client
              .from('users')
              .select()
              .eq('phone_number', phoneNumber)
              .single();
      if (response.isNotEmpty) {
        return ResqUser.fromJson(response);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching user by phone: $e');
      return null;
    }
  }

  /// Create a new user
  static Future<ResqUser?> createUser(ResqUser user) async {
    try {
      await _client.from('users').insert(user.toJson());
      return user;
    } catch (e) {
      developer.log('Error creating user: $e');
      return null;
    }
  }

  /// Update user information
  static Future<bool> updateUser(ResqUser user) async {
    try {
      await _client
          .from('users')
          .update(user.toJson())
          .eq('user_id', user.userId);
      return true;
    } catch (e) {
      developer.log('Error updating user: $e');
      return false;
    }
  }

  // ==================== OTP Code ====================
  /// Create OTP code
  static Future<OtpCode?> createOtpCode(OtpCode otpCode) async {
    try {
      final _ =
          await _client.from('otp_code').insert(otpCode.toJson()).select();
      return otpCode;
    } catch (e) {
      developer.log('Error creating OTP code: $e');
      return null;
    }
  }

  /// Verify OTP code
  static Future<bool> verifyOtpCode(String verificationId, String code) async {
    try {
      final response =
          await _client
              .from('otp_code')
              .select()
              .eq('verification_id', verificationId)
              .maybeSingle();

      if (response == null) return false;

      final otpCode = OtpCode.fromJson(response);
      bool value = (otpCode.otpCode == code && otpCode.isValid);
      developer.log(
        "using verificationId: $verificationId and code: $code, result is $value, because otpCode is ${otpCode.otpCode} and isActive is ${otpCode.isValid}",
      );
      return value;
    } catch (e) {
      developer.log('Error verifying OTP: $e');
      return false;
    }
  }

  /// Mark OTP as used
  static Future<bool> invalidateOtpCode(String verificationId) async {
    try {
      await _client
          .from('otp_code')
          .update({'is_valid': false})
          .eq('verification_id', verificationId);
      return true;
    } catch (e) {
      developer.log('Error invalidating OTP: $e');
      return false;
    }
  }

  // ==================== Response Teams ====================
  /// Get response team by ID
  static Future<ResponseTeam?> getResponseTeamByInstanceCode(
    String instanceCode,
  ) async {
    try {
      final response =
          await _client
              .from('response_teams')
              .select()
              .eq('instance_code', instanceCode)
              .maybeSingle();

      return response != null ? ResponseTeam.fromJson(response) : null;
    } catch (e) {
      developer.log('Error getting response team: $e');
      return null;
    }
  }

  static Future<ResponseTeam?> loginResponseTeam(
    String instanceCode,
    String password,
  ) async {
    try {
      final response =
          await _client
              .from('response_teams')
              .select()
              .eq('instance_code', instanceCode)
              .eq('password', password)
              .maybeSingle();

      if (response != null) {
        final responseTeam = ResponseTeam.fromJson(response);
        await _storeResponseTeamData(responseTeam);
        return responseTeam;
      }
      return null;
    } catch (e) {
      developer.log('Error logging in response team: $e');
      return null;
    }
  }

  // ==================== Shared Preferences ====================
  static Future<void> _storeResponseTeamData(ResponseTeam responseTeam) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(responseTeam.toSharedPrefsJson());
      await prefs.setString('response_team_data', jsonString);
    } catch (e) {
      developer.log('Error storing response team data: $e');
    }
  }

  static Future<ResponseTeam?> getStoredResponseTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('response_team_data');

      if (jsonString != null) {
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        return ResponseTeam.fromSharedPrefsJson(jsonData);
      }
      return null;
    } catch (e) {
      developer.log('Error getting stored response team data: $e');
      return null;
    }
  }

  static Future<void> clearStoredResponseTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('response_team_data');
    } catch (e) {
      developer.log('Error clearing response team data: $e');
    }
  }
}
