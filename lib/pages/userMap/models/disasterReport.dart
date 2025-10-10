import 'package:latlong2/latlong.dart';
import 'package:resqapp/pages/userMap/models/disasterType.dart';

class DisasterReport {
  final String id;
  final DisasterType type;
  final LatLng location;
  final String description;
  final DateTime timestamp;
  final String severity;
  final String? address;
  final double? radiusKm;
  final String? alertStatus;

  DisasterReport({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.address,
    this.radiusKm,
    this.alertStatus,
  });

  /// Factory constructor to create DisasterReport from JSON/API response
  factory DisasterReport.fromJson(Map<String, dynamic> json) {
    return DisasterReport(
      id: json['id'] as String,
      type: DisasterType.fromString(json['type'] as String),
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: json['severity'] as String,
      address: json['address'] as String?,
      radiusKm: json['radiusKm'] as double?,
      alertStatus: json['alertStatus'] as String?,
    );
  }

  /// Convert DisasterReport to JSON for API/database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toApiString(),
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      if (address != null) 'address': address,
      if (radiusKm != null) 'radiusKm': radiusKm,
      if (alertStatus != null) 'alertStatus': alertStatus,
    };
  }
}