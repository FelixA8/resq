import 'dart:math';
import 'package:latlong2/latlong.dart';

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
