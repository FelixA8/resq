import 'package:latlong2/latlong.dart';

class DisasterReport {
  final String id;
  final String type;
  final LatLng location;
  final String description;
  final DateTime timestamp;
  final String severity;

  DisasterReport({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.timestamp,
    required this.severity,
  });
}