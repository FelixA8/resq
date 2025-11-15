// Supabase Database Service
// File: lib/services/supabase_service.dart

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_models.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Test Supabase connection
  /// Returns true if connection is successful, false otherwise
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing Supabase connection...');
      // Note: Supabase URL is configured at initialization, not accessible via client

      // Try a simple query to test connectivity
      final response = await _client
          .from('users')
          .select('count')
          .limit(1)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Connection timeout after 10 seconds');
            },
          );

      print('✅ Supabase connection successful');
      print('📊 Response: $response');
      return true;
    } on SocketException catch (e) {
      print('❌ Network/DNS Error: ${e.message}');
      print('🔍 Possible causes:');
      print('   1. Device/Simulator not connected to internet');
      print('   2. Incorrect Supabase URL in .env file');
      print('   3. DNS resolution issue');
      print('   4. Firewall/Network blocking the connection');
      return false;
    } on TimeoutException catch (e) {
      print('❌ Connection Timeout: ${e.message}');
      print('🔍 The server might be slow or unreachable');
      return false;
    } catch (e) {
      print('❌ Supabase connection failed: $e');
      print('📊 Error type: ${e.runtimeType}');

      // Check if it's a URL/configuration issue
      if (e.toString().contains('hostname') ||
          e.toString().contains('Failed host lookup')) {
        print('🚨 DNS Resolution Failed');
        print('   Check your SUPABASE_URL in .env file');
        print('   Expected format: https://your-project-id.supabase.co');
      }

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
      print('Error getting user: $e');
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
      return ResqUser.fromJson(response); // Assuming ResqUser has a fromJson constructor
    }
    return null;
  } catch (e) {
    print('Error fetching user by phone: $e');
    return null;
  }
}

  /// Create a new user
  static Future<ResqUser?> createUser(ResqUser user) async {
    try {
      await _client.from('users').insert(user.toJson());
      return user;
    } catch (e) {
      print('Error creating user: $e');
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
      print('Error updating user: $e');
      return false;
    }
  }

  // ==================== OTP Code ====================

  /// Create OTP code
  static Future<OtpCode?> createOtpCode(OtpCode otpCode) async {
    try {
      print('🔍 Attempting to create OTP code...($otpCode)');
      print('📋 OTP Data: ${otpCode.toJson()}');

      final response =
          await _client.from('otp_code').insert(otpCode.toJson()).select();

      print('✅ Supabase response: $response');
      return otpCode;
    } catch (e) {
      print('❌ Error creating OTP code: $e');
      print('📊 Error type: ${e.runtimeType}');
      if (e.toString().contains('relation') &&
          e.toString().contains('does not exist')) {
        print('🚨 Table "otp_code" does not exist in Supabase database');
      }
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
      print("using verificationId: $verificationId and code: $code, result is $value, because otpCode is ${otpCode.otpCode} and isActive is ${otpCode.isValid}");
      return value;
    } catch (e) {
      print('Error verifying OTP: $e');
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
      print('Error invalidating OTP: $e');
      return false;
    }
  }

  // ==================== Contacts ====================

  /// Get user's emergency contacts
  static Future<List<Contact>> getUserContacts(String userId) async {
    try {
      final response = await _client
          .from('contacts')
          .select()
          .eq('user_id', userId);

      return (response as List).map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      print('Error getting contacts: $e');
      return [];
    }
  }

  /// Add emergency contact
  static Future<bool> addContact(Contact contact) async {
    try {
      await _client.from('contacts').insert(contact.toJson());
      return true;
    } catch (e) {
      print('Error adding contact: $e');
      return false;
    }
  }

  // ==================== Disasters ====================

  /// Get all disasters that occurred today
  static Future<List<Disaster>> getDisasters() async {
    try {
      // Calculate start and end of today in milliseconds since epoch
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      
      final startOfDayMs = startOfDay.millisecondsSinceEpoch.toDouble();
      final endOfDayMs = endOfDay.millisecondsSinceEpoch.toDouble();
      
      print('🔍 Fetching disasters from ${startOfDay} to ${endOfDay}');
      print('📊 Timestamp range: $startOfDayMs - $endOfDayMs');

      final response = await _client
          .from('disasters')
          .select()
          // .gte('occurred_at', startOfDayMs)
          // .lte('occurred_at', endOfDayMs)
          .order('occurred_at', ascending: false);

      print('✅ Found ${(response as List).length} disasters today');
      
      // Debug: Print each disaster's details
      if ((response as List).isNotEmpty) {
        print('📋 Disaster details:');
        for (var disasterJson in response) {
          print('  - ID: ${disasterJson['disaster_id']}');
          print('    Occurred: ${disasterJson['occurred_at']}');
          print('    Location: ${disasterJson['center_lat']}, ${disasterJson['center_lng']}');
          print('    Magnitude: ${disasterJson['magnitude']}');
        }
      } else {
        print('⚠️ No disasters found for today. Checking all disasters in database...');
        // Check all disasters for debugging
        final allDisasters = await getAllDisasters();
        print('📊 Total disasters in database: ${allDisasters.length}');
        if (allDisasters.isNotEmpty) {
          print('📋 Recent disasters (last 5):');
          for (var i = 0; i < allDisasters.length && i < 5; i++) {
            final d = allDisasters[i];
            if (d.occurredAt != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(d.occurredAt!.toInt());
              print('  - ${d.disasterId}: ${date.toString()} (${d.magnitude} SR)');
            }
          }
        }
      }
      
      return (response as List).map((json) => Disaster.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error getting disasters: $e');
      print('📊 Error type: ${e.runtimeType}');
      return [];
    }
  }

  /// Get all disasters (for debugging - not filtered by date)
  static Future<List<Disaster>> getAllDisasters() async {
    try {
      print('🔍 Fetching ALL disasters from database (no date filter)...');
      
      final response = await _client
          .from('disasters')
          .select()
          .order('occurred_at', ascending: false)
          .limit(100); // Limit to last 100 for performance

      print('✅ Found ${(response as List).length} total disasters in database');
      return (response as List).map((json) => Disaster.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error getting all disasters: $e');
      return [];
    }
  }

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
      
      print('📤 Inserting SOS event: $sosData');
      
      final response = await _client
          .from('sos_events')
          .insert(sosData)
          .select()
          .single();
      
      print('✅ SOS event created: $response');
      
      return SosEvent.fromJson(response);
    } catch (e) {
      print('❌ Error creating SOS event: $e');
      print('📊 Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Get SOS events
  // static Future<List<SosEvent>> getSoSEvents() async {
  //   try {
  //     final response = await _client
  //         .from('sos_events')
  //         .select()
  //         .order('pressed_at', ascending: true);

  //     return (response as List).map((json) => SosEvent.fromJson(json)).toList();
  //   } catch (e) {
  //     print('Error getting SOS events: $e');
  //     print('IIIIIIIIIIUIIUIUIIIIIUIIUIIUIIU got ')
  //     return [];
  //   }
  // }
  static Future<List<SosEvent>> getSoSEvents() async {
  try {
    final response = await _client
        .from('sos_events')
        .select()
        .order('pressed_at', ascending: true);

    final events = (response as List)
        .map((json) => SosEvent.fromJson(json))
        .toList();

    print('Active SOS count: ${events.length}');

    return events;
  } catch (e) {
    print('Error getting SOS events: $e');
    print('IIIIIIIIIIUIIUIUIIIIIUIIUIIUIIU got an error');
    return [];
  }
}


  /// Get SOS events for a user
  /// Returns the most recent SOS event for the user
  static Future<SosEvent?> getUserSosEvents(String userId) async {
    try {
      final response = await _client
          .from('sos_events')
          .select()
          .eq('user_id', userId)
          .order('sos_id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('ℹ️ No SOS events found for user: $userId');
        return null;
      }
      
      return SosEvent.fromJson(response);
    } catch (e) {
      print('❌ Error getting SOS events: $e');
      return null;
    }
  }

  /// Assign SOS event to response team
  /// Updates the sos_events table with the response team assignment
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
      
      print('✅ SOS event $sosId assigned to team $responseTeamId');
      return true;
    } catch (e) {
      print('❌ Error assigning SOS: $e');
      return false;
    }
  }

  /// Resolve SOS event
  /// Updates the sos_events table to mark the SOS as resolved
  static Future<bool> resolveSosEvent(String sosId) async {
    try {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
      
      await _client
          .from('sos_events')
          .update({
            'resolved_at': currentTimestamp,
            'is_current': false,
          })
          .eq('sos_id', sosId)
          .eq('is_current', true);
      
      print('✅ SOS event $sosId resolved');
      return true;
    } catch (e) {
      print('❌ Error resolving SOS: $e');
      return false;
    }
  }

  /// Delete SOS event by user ID
  /// Deletes the most recent active SOS event for a user
  static Future<bool> deleteSosEventByUserId(String userId) async {
    try {
      print('🗑️ Attempting to delete SOS event for user: $userId');
      
      // Delete all active SOS events for this user (where is_current = true)
      await _client
          .from('sos_events')
          .delete()
          .eq('user_id', userId);
      
      print('✅ SOS event(s) deleted for user: $userId');
      return true;
    } catch (e) {
      print('❌ Error deleting SOS event: $e');
      print('📊 Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Delete SOS event by SOS ID
  /// Deletes a specific SOS event
  static Future<bool> deleteSosEventById(String sosId) async {
    try {
      print('🗑️ Attempting to delete SOS event: $sosId');
      
      await _client
          .from('sos_events')
          .delete()
          .eq('sos_id', sosId);
      
      print('✅ SOS event deleted: $sosId');
      return true;
    } catch (e) {
      print('❌ Error deleting SOS event: $e');
      print('📊 Error type: ${e.runtimeType}');
      return false;
    }
  }

  // ==================== Evacuation Points ====================

  /// Get evacuation points
  static Future<List<EvacuationPoint>> getEvacuationPoints({
    String? city,
  }) async {
    try {
      var query = _client.from('evacuation_points').select();

      if (city != null) {
        query = query.eq('city', city);
      }

      final response = await query;
      return (response as List)
          .map((json) => EvacuationPoint.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting evacuation points: $e');
      return [];
    }
  }

  /// Get evacuation point by ID
  static Future<EvacuationPoint?> getEvacuationPointById(String evacuationId) async {
    try {
      final response = await _client
          .from('evacuation_points')
          .select()
          .eq('evacuation_id', evacuationId)
          .maybeSingle();

      return response != null ? EvacuationPoint.fromJson(response) : null;
    } catch (e) {
      print('Error getting evacuation point: $e');
      return null;
    }
  }

  /// Add evacuation point
  static Future<EvacuationPoint?> addEvacuationPoint({
    required double locationLat,
    required double locationLng,
    required String responseTeamId,
    String? city,
    String? locationDetail,
  }) async {
    try {
      final insertData = <String, dynamic>{
        'response_team_id': responseTeamId,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'city': city,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'location_detail': locationDetail,
      };
      
      print('SupabaseService: Attempting to insert evacuation point with data: $insertData');

      final response = await _client
          .from('evacuation_points')
          .insert(insertData)
          .select()
          .single();

      print('SupabaseService: Successfully inserted evacuation point. Response: $response');
      
      final evacuationPoint = EvacuationPoint.fromJson(response);
      print('SupabaseService: Created EvacuationPoint object: ${evacuationPoint.evacuationId}');
      
      return evacuationPoint;
    } catch (e) {
      print('SupabaseService: Error adding evacuation point: $e');
      print('SupabaseService: Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('SupabaseService: PostgrestException details - Code: ${e.code}, Message: ${e.message}');
      }
      return null;
    }
  }

  /// Update evacuation point
  static Future<bool> modifyEvacuationPoint(EvacuationPoint evacuationPoint) async {
    try {
      if (evacuationPoint.evacuationId == null) {
        print('Error: evacuation_id is required for updating');
        return false;
      }
      
      final updateData = <String, dynamic>{};
      
      if (evacuationPoint.responseTeamId != null) {
        updateData['response_team_id'] = evacuationPoint.responseTeamId;
      }
      if (evacuationPoint.locationLat != null) {
        updateData['location_lat'] = evacuationPoint.locationLat;
      }
      if (evacuationPoint.locationLng != null) {
        updateData['location_lng'] = evacuationPoint.locationLng;
      }
      if (evacuationPoint.city != null) {
        updateData['city'] = evacuationPoint.city;
      }
      if (evacuationPoint.locationDetail != null) {
        updateData['location_detail'] = evacuationPoint.locationDetail;
      }

      if (updateData.isEmpty) {
        print('Warning: No fields to update');
        return true;
      }

      await _client
          .from('evacuation_points')
          .update(updateData)
          .eq('evacuation_id', evacuationPoint.evacuationId!);
      return true;
    } catch (e) {
      print('Error updating evacuation point: $e');
      return false;
    }
  }

  /// Delete evacuation point
  static Future<bool> deleteEvacuationPoint(String evacuationId) async {
    try {
      await _client
          .from('evacuation_points')
          .delete()
          .eq('evacuation_id', evacuationId);
      return true;
    } catch (e) {
      print('Error deleting evacuation point: $e');
      return false;
    }
  }

  /// Get nearby evacuation points
  static Future<List<EvacuationPoint>> getNearbyEvacuationPoints({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    try {
      final latOffset = radiusKm / 111.0;
      final lngOffset = radiusKm / (111.0 * cos(lat * 3.14159 / 180));

      final response = await _client
          .from('evacuation_points')
          .select()
          .gte('location_lat', lat - latOffset)
          .lte('location_lat', lat + latOffset)
          .gte('location_lng', lng - lngOffset)
          .lte('location_lng', lng + lngOffset);

      return (response as List)
          .map((json) => EvacuationPoint.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting nearby evacuation points: $e');
      return [];
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
      print('Error getting response team: $e');
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
        // Store in shared preferences after successful login
        await _storeResponseTeamData(responseTeam);
        return responseTeam;
      }
      return null;
    } catch (e) {
      print('Error logging in response team: $e');
      return null;
    }
  }

  // ==================== Shared Preferences ====================

  /// Store response team data in shared preferences
  static Future<void> _storeResponseTeamData(ResponseTeam responseTeam) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(responseTeam.toSharedPrefsJson());
      await prefs.setString('response_team_data', jsonString);
    } catch (e) {
      print('Error storing response team data: $e');
    }
  }

  /// Get stored response team data from shared preferences
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
      print('Error getting stored response team data: $e');
      return null;
    }
  }

  /// Clear stored response team data (logout)
  static Future<void> clearStoredResponseTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('response_team_data');
    } catch (e) {
      print('Error clearing response team data: $e');
    }
  }
}
