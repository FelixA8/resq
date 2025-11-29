import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/services/distance_calculator.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:resqapp/components/disaster_detail_modal.dart';

class MapHelper {
  static final DateFormat _disasterDateFormatter =
      DateFormat('d MMMM yyyy, HH:mm:ss', 'id_ID');

  static Disaster? findDisasterByLocation(
      List<Disaster> list, LatLng location) {
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
      List<EvacuationPoint> list, LatLng location) {
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
      double? lat, double? lng, Map<String, String> cache, String id) async {
    if (cache.containsKey(id)) return cache[id]!;
    if (lat == null || lng == null) return 'Lokasi tidak tersedia';

    try {
      final result =
          await LocationHelper.getLocationDetails(LatLng(lat, lng));
      final address = result.locationDetail;
      cache[id] = address;
      return address;
    } catch (_) {
      return 'Lokasi tidak tersedia';
    }
  }

  static String formatDisasterDate(double? timestamp) {
    if (timestamp == null) return 'Tidak tersedia';
    try {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
      return '${_disasterDateFormatter.format(dateTime)} WIB';
    } catch (_) {
      return 'Tidak tersedia';
    }
  }

  static String formatSOSReportTime(double? timestamp) {
    if (timestamp == null || timestamp == 0) return '-';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    final time =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    final date =
        "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";
    return "$time, $date";
  }

  static String formatMagnitude(double? magnitude) {
    return magnitude != null
        ? '${magnitude.toStringAsFixed(2)} SR'
        : 'Tidak tersedia';
  }

  static String getTsunamiPotential(double? magnitude) {
    if (magnitude == null) return 'Tidak Berpotensi';
    return magnitude >= 7.0 ? 'Berpotensi' : 'Tidak Berpotensi';
  }

  static String formatDepth(String? depth) {
    return (depth == null || depth.isEmpty) ? 'Tidak tersedia' : depth;
  }

  static Future<void> launchShakeMap(String? url) async {
    if (url == null || url.isEmpty) {
      throw const DisasterActionException('Peta guncangan tidak tersedia');
    }
    try {
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        throw const DisasterActionException(
            'Tidak dapat membuka peta guncangan');
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (e is DisasterActionException) rethrow;
      throw DisasterActionException('Error: ${e.toString()}');
    }
  }

  static Future<List<LatLng>> getRoutePolyline(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final geometry = data['routes'][0]['geometry']['coordinates'] as List;
          return geometry
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
    return [];
  }

  static bool isUserOffRoute(
    LatLng userLocation, 
    List<LatLng> routePoints, 
    {double thresholdMeters = 50.0}
  ) {
    if (routePoints.isEmpty) return false;

    double minDistanceKm = double.infinity;

    for (final point in routePoints) {
      final distance = GeoDistanceCalculator.calculateDistance(userLocation, point);
      if (distance < minDistanceKm) {
        minDistanceKm = distance;
      }
    }
    final minDistanceMeters = minDistanceKm * 1000;
    
    return minDistanceMeters > thresholdMeters;
  }
}