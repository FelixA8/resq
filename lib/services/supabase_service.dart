// Supabase Database Service
// File: lib/services/supabase_service.dart

import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_models.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

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
      await _client.from('otp_code').insert(otpCode.toJson());
      return otpCode;
    } catch (e) {
      print('Error creating OTP code: $e');
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
      return otpCode.otpCode == code && otpCode.isActive;
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

  /// Get all disasters
  static Future<List<Disaster>> getDisasters() async {
    try {
      final response = await _client
          .from('disasters')
          .select()
          .order('occurred_at', ascending: false);

      return (response as List).map((json) => Disaster.fromJson(json)).toList();
    } catch (e) {
      print('Error getting disasters: $e');
      return [];
    }
  }

  // ==================== SOS Events ====================

  /// Create SOS event
  static Future<SosEvent?> createSosEvent(SosEvent sosEvent) async {
    try {
      await _client.from('sos_events').insert(sosEvent.toJson());
      return sosEvent;
    } catch (e) {
      print('Error creating SOS event: $e');
      return null;
    }
  }

  /// Get SOS events
  static Future<List<SosEvent>> getSoSEvents() async {
    try {
      final response = await _client
          .from('sos_events')
          .select()
          .order('pressed_at', ascending: true);

      return (response as List).map((json) => SosEvent.fromJson(json)).toList();
    } catch (e) {
      print('Error getting SOS events: $e');
      return [];
    }
  }

  /// Get SOS events for a user
  static Future<SosEvent?> getUserSosEvents(String userId) async {
    try {
      final response = await _client
          .from('sos_events')
          .select()
          .eq('user_id', userId)
          .order('sos_id', ascending: false);

      return (response as SosEvent);
    } catch (e) {
      print('Error getting SOS events: $e');
      return null;
    }
  }

  /// Assign SOS event to response team
  static Future<bool> assignSosToTeam({
    required String sosId,
    required String responseTeamId,
  }) async {
    try {
      await _client.from('sos_assignments').insert({
        'sos_id': sosId,
        'response_team_id': responseTeamId,
        'assigned_at': DateTime.now().toIso8601String(),
        'is_current': true,
      });
      return true;
    } catch (e) {
      print('Error assigning SOS: $e');
      return false;
    }
  }

  /// Resolve SOS event
  static Future<bool> resolveSosEvent(String sosId) async {
    try {
      await _client
          .from('sos_assignments')
          .update({
            'resolved_at': DateTime.now().toIso8601String(),
            'is_current': false,
          })
          .eq('sos_id', sosId)
          .eq('is_current', true);
      return true;
    } catch (e) {
      print('Error resolving SOS: $e');
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
