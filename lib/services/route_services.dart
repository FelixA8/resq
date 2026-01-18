import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:resqapp/services/location_services.dart';

class RouteServices {
  static Future<RouteData?> getRouteWithInstructions(
    LatLng start,
    LatLng end,
  ) async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;
          final polyline =
              geometry
                  .map(
                    (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()),
                  )
                  .toList();

          final steps = <RouteStep>[];
          if (route['legs'] != null && (route['legs'] as List).isNotEmpty) {
            final leg = route['legs'][0];
            if (leg['steps'] != null) {
              for (var step in leg['steps']) {
                final maneuver = step['maneuver'];
                final stepLocation = LatLng(
                  maneuver['location'][1].toDouble(),
                  maneuver['location'][0].toDouble(),
                );

                steps.add(
                  RouteStep(
                    distance: (step['distance'] ?? 0.0).toDouble(),
                    duration: (step['duration'] ?? 0.0).toDouble(),
                    instruction: step['name'] ?? '',
                    maneuverType: maneuver['type'] ?? 'turn',
                    maneuverModifier: maneuver['modifier'],
                    location: stepLocation,
                  ),
                );
              }
            }
          }

          return RouteData(
            polyline: polyline,
            steps: steps,
            totalDistance: (route['distance'] ?? 0.0).toDouble(),
            totalDuration: (route['duration'] ?? 0.0).toDouble(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching route with instructions: $e');
    }
    return null;
  }

  static bool isUserOffRoute(
    LatLng userLocation,
    List<LatLng> routePoints, {
    double thresholdMeters = 50.0,
  }) {
    if (routePoints.isEmpty) return false;

    double minDistanceKm = double.infinity;

    for (final point in routePoints) {
      final distance = GeoDistanceCalculator.calculateDistance(
        userLocation,
        point,
      );
      if (distance < minDistanceKm) {
        minDistanceKm = distance;
      }
    }
    final minDistanceMeters = minDistanceKm * 1000;

    return minDistanceMeters > thresholdMeters;
  }
}

class RouteStep {
  final double distance;
  final double duration;
  final String instruction;
  final String maneuverType;
  final String? maneuverModifier;
  final LatLng location;

  RouteStep({
    required this.distance,
    required this.duration,
    required this.instruction,
    required this.maneuverType,
    this.maneuverModifier,
    required this.location,
  });
}

class RouteData {
  final List<LatLng> polyline;
  final List<RouteStep> steps;
  final double totalDistance;
  final double totalDuration;

  RouteData({
    required this.polyline,
    required this.steps,
    required this.totalDistance,
    required this.totalDuration,
  });
}
