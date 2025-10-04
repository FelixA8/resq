import 'package:latlong2/latlong.dart';

class SafetyPoint {
  final String id;
  final String name;
  final LatLng location;
  final String type; // hospital, police, shelter, etc.

  SafetyPoint({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
  });
}