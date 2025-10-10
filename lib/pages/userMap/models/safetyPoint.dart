import 'package:latlong2/latlong.dart';
import 'package:resqapp/pages/userMap/models/safetyPointType.dart';

class SafetyPoint {
  final String id;
  final String name;
  final LatLng location;
  final SafetyPointType type;

  SafetyPoint({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
  });

  /// Factory constructor to create SafetyPoint from JSON/API response
  factory SafetyPoint.fromJson(Map<String, dynamic> json) {
    return SafetyPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      type: SafetyPointType.fromString(json['type'] as String),
    );
  }

  /// Convert SafetyPoint to JSON for API/database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': type.toApiString(),
    };
  }
}