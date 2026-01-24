import 'dart:ui';
import 'dart:math';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resqapp/theme/theme_app.dart';
import '../models/supabase_models.dart';

class LocationServices {
  static final SupabaseClient _client = Supabase.instance.client;
  static const LatLng defaultLocation = LatLng(-6.2088, 106.8456);
  static const theme = ResQTheme();

  // ==================== Location Helper Methods ====================

  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        Get.snackbar(
          'Layanan Lokasi Nonaktif',
          'Mohon aktifkan Lokasi Anda untuk menggunakan fitur ini',
          snackPosition: SnackPosition.BOTTOM,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Location service disabled',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Izin lokasi diperlukan untuk menampilkan posisi Anda di peta',
            snackPosition: SnackPosition.BOTTOM,
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 2),
            isDismissible: true,
          );
          return LocationResult(
            location: defaultLocation,
            hasPermission: false,
            error: 'Permission denied',
          );
        }
      }

      return await _getLocationAfterPermission();
    } catch (e) {
      Get.snackbar(
        'Kesalahan Lokasi',
        'Gagal menginisialisasi lokasi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  static Future<LocationResult> _getLocationAfterPermission() async {
    try {
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return LocationResult(
          location: LatLng(
            lastKnownPosition.latitude,
            lastKnownPosition.longitude,
          ),
          hasPermission: true,
        );
      }

      return await _getCurrentLocation();
    } catch (e) {
      return await _getCurrentLocation();
    }
  }

  static Future<LocationResult> _getCurrentLocation() async {
    try {
      bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        Get.snackbar(
          'Layanan Lokasi Nonaktif',
          'Mohon aktifkan Lokasi Anda untuk menggunakan fitur ini',
          snackPosition: SnackPosition.BOTTOM,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Location service disabled',
        );
      }

      Position? position;

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );
      } catch (e) {
        throw Exception('Location retrieval methods failed: ${e.toString()}');
      }

      return LocationResult(
        location: LatLng(position.latitude, position.longitude),
        hasPermission: true,
      );
    } catch (e) {
      String errorMessage = 'Layanan Lokasi Tidak Merespons';
      Color backgroundColor = theme.colors.primary;

      if (e.toString().contains('timeout')) {
        errorMessage = 'Tidak dapat mendapatkan lokasi. Silakan coba lagi.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Izin lokasi diperlukan untuk menampilkan posisi Anda di peta';
      } else if (e.toString().contains(
        'Unable to get current or last known location',
      )) {
        errorMessage = 'Gagal mendapatkan lokasi terkini. Silakan coba lagi.';
      }

      Get.snackbar(
        'Kesalahan Lokasi',
        errorMessage,
        backgroundColor: backgroundColor,
        colorText: Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
        isDismissible: true,
      );

      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  /// Get current location without showing error messages (for refresh operations)
  static Future<LocationResult> getCurrentLocationSilent() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );

      return LocationResult(
        location: LatLng(position.latitude, position.longitude),
        hasPermission: true,
      );
    } catch (e) {
      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  /// Get address details from coordinates using reverse geocoding
  static Future<LocationDetailResult> getLocationDetails(
    LatLng coordinates,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        String city =
            placemark.locality ??
            placemark.administrativeArea ??
            placemark.subAdministrativeArea ??
            'Kota Tidak Diketahui';

        List<String> addressParts = [];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subLocality != null &&
            placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }

        String locationDetail =
            addressParts.isNotEmpty
                ? addressParts.join(', ')
                : 'Lat: ${coordinates.latitude.toStringAsFixed(6)}, Lng: ${coordinates.longitude.toStringAsFixed(6)}';

        return LocationDetailResult(
          city: city,
          locationDetail: locationDetail,
          success: true,
        );
      } else {
        return LocationDetailResult(
          city: 'Kota Tidak Diketahui',
          locationDetail:
              'Lat: ${coordinates.latitude.toStringAsFixed(6)}, Lng: ${coordinates.longitude.toStringAsFixed(6)}',
          success: false,
          error: 'Alamat tidak ditemukan untuk lokasi ini',
        );
      }
    } catch (e) {
      return LocationDetailResult(
        city: 'Kota Tidak Diketahui',
        locationDetail:
            'Lat: ${coordinates.latitude.toStringAsFixed(6)}, Lng: ${coordinates.longitude.toStringAsFixed(6)}',
        success: false,
        error: e.toString(),
      );
    }
  }

  // ==================== Location-based Lookup Methods ====================

  static Disaster? findDisasterByLocation(
    List<Disaster> list,
    LatLng location,
  ) {
    const tolerance = 0.0001;
    try {
      return list.firstWhere(
        (d) =>
            d.centerLat != null &&
            d.centerLng != null &&
            (d.centerLat! - location.latitude).abs() < tolerance &&
            (d.centerLng! - location.longitude).abs() < tolerance,
      );
    } catch (_) {
      return null;
    }
  }

  static EvacuationPoint? findEvacuationPointByLocation(
    List<EvacuationPoint> list,
    LatLng location,
  ) {
    const tolerance = 0.0001;
    try {
      return list.firstWhere(
        (p) =>
            p.locationLat != null &&
            p.locationLng != null &&
            (p.locationLat! - location.latitude).abs() < tolerance &&
            (p.locationLng! - location.longitude).abs() < tolerance,
      );
    } catch (_) {
      return null;
    }
  }

  static SosEvent? findSOSByLocation(List<SosEvent> list, LatLng location) {
    const tolerance = 0.0001;
    try {
      return list.firstWhere(
        (s) =>
            s.locationLat != null &&
            s.locationLng != null &&
            (s.locationLat! - location.latitude).abs() < tolerance &&
            (s.locationLng! - location.longitude).abs() < tolerance,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> getAddressFromLocation(
    double? lat,
    double? lng,
    Map<String, String> cache,
    String id,
  ) async {
    if (cache.containsKey(id)) return cache[id]!;
    if (lat == null || lng == null) return 'Lokasi tidak tersedia';

    try {
      final result = await LocationServices.getLocationDetails(LatLng(lat, lng));
      final address = result.locationDetail;
      cache[id] = address;
      return address;
    } catch (_) {
      return 'Lokasi tidak tersedia';
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

      final response = await query.order('created_at', ascending: false);

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
  static Future<EvacuationPoint?> saveNewEvacuationPoint({
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
        'LocationServices: Successfully inserted evacuation point. Response: $response',
      );
      final evacuationPoint = EvacuationPoint.fromJson(response);
      return evacuationPoint;
    } catch (e) {
      developer.log('LocationServices: Error adding evacuation point: $e');
      return null;
    }
  }

  /// Update evacuation point
  static Future<bool> updateEvacuationPoint(
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
}

class GeoDistanceCalculator {
  static const double earthRadiusKm = 6371.0;

  /// Calculate distance between two coordinates using Haversine formula
  static double calculateDistance(LatLng point1, LatLng point2) {
    final lat1Rad = _degreesToRadians(point1.latitude);
    final lat2Rad = _degreesToRadians(point2.latitude);
    final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
    final deltaLngRad = _degreesToRadians(point2.longitude - point1.longitude);

    final a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distanceKm = earthRadiusKm * c;

    return distanceKm;
  }

  static double calculateDistanceFromCoordinates({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return calculateDistance(LatLng(lat1, lng1), LatLng(lat2, lng2));
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} Km';
    }
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}

class LocationResult {
  final LatLng location;
  final bool hasPermission;
  final String? error;

  LocationResult({
    required this.location,
    required this.hasPermission,
    this.error,
  });
}

class LocationDetailResult {
  final String city;
  final String locationDetail;
  final bool success;
  final String? error;

  LocationDetailResult({
    required this.city,
    required this.locationDetail,
    required this.success,
    this.error,
  });
}
