import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_models.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

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
      // Delete existing contact with same name for this user
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

  // ==================== Disasters ====================

  /// Get all disasters that occurred today
  static Future<List<Disaster>> getFilteredDisasters() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      final startOfDayMs = startOfDay.millisecondsSinceEpoch.toDouble();
      final endOfDayMs = endOfDay.millisecondsSinceEpoch.toDouble();

      final response = await _client
          .from('disasters')
          .select()
          .gte('occurred_at', startOfDayMs)
          .lte('occurred_at', endOfDayMs)
          .order('occurred_at', ascending: false);

      return (response as List).map((json) => Disaster.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error getting disasters: $e');
      return [];
    }
  }

  /// Get all disasters (for debugging - not filtered by date)
  static Future<List<Disaster>> getAllDisasters() async {
    try {
      final response = await _client
          .from('disasters')
          .select()
          .order('occurred_at', ascending: false)
          .limit(100);

      return (response as List).map((json) => Disaster.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error getting disasters: $e');
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

      final response =
          await _client.from('sos_events').insert(sosData).select().single();

      return SosEvent.fromJson(response);
    } catch (e) {
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

    final events = (response as List)
        .map((json) => SosEvent.fromJson(json))
        .toList();

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
          .update({
            'response_team_id': null,
            'assigned_at': 0.0,
          })
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

      final events = (response as List)
          .map((json) => SosEvent.fromJson(json))
          .toList();

      developer.log('Fetched ${events.length} SOS events (offset: $offset, limit: $limit)');
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
      developer.log('Error getting evacuation points: $e');
      return [];
    }
  }

  /// Get evacuation point by ID
  static Future<EvacuationPoint?> getEvacuationPointById(
    String evacuationId,
  ) async {
    try {
      final response =
          await _client
              .from('evacuation_points')
              .select()
              .eq('evacuation_id', evacuationId)
              .maybeSingle();

      return response != null ? EvacuationPoint.fromJson(response) : null;
    } catch (e) {
      developer.log('Error getting evacuation point: $e');
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

      final response =
          await _client
              .from('evacuation_points')
              .insert(insertData)
              .select()
              .single();

      developer.log(
        'SupabaseService: Successfully inserted evacuation point. Response: $response',
      );
      final evacuationPoint = EvacuationPoint.fromJson(response);
      return evacuationPoint;
    } catch (e) {
      developer.log('SupabaseService: Error adding evacuation point: $e');
      return null;
    }
  }

  /// Update evacuation point
  static Future<bool> modifyEvacuationPoint(
    EvacuationPoint evacuationPoint,
  ) async {
    try {
      if (evacuationPoint.evacuationId == null) {
        developer.log('Error: evacuation_id is required for updating');
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
        developer.log('Warning: No fields to update');
        return true;
      }

      await _client
          .from('evacuation_points')
          .update(updateData)
          .eq('evacuation_id', evacuationPoint.evacuationId!);
      return true;
    } catch (e) {
      developer.log('Error updating evacuation point: $e');
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
      developer.log('Error deleting evacuation point: $e');
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
      developer.log('Error getting nearby evacuation points: $e');
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
  /// Store response team data in shared preferences
  static Future<void> _storeResponseTeamData(ResponseTeam responseTeam) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(responseTeam.toSharedPrefsJson());
      await prefs.setString('response_team_data', jsonString);
    } catch (e) {
      developer.log('Error storing response team data: $e');
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
      developer.log('Error getting stored response team data: $e');
      return null;
    }
  }

  /// Clear stored response team data (logout)
  static Future<void> clearStoredResponseTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('response_team_data');
    } catch (e) {
      developer.log('Error clearing response team data: $e');
    }
  }
}
