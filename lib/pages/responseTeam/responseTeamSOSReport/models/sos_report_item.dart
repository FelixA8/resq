/// Model for SOS Report items displayed in the list
class SOSReportItem {
  final String reportId;
  final String userName;
  final String phoneNumber;
  final double distanceKm; // Distance in kilometers
  final DateTime timestamp;
  final String? assignedUnitId; // If null, report is unassigned
  final double? locationLat;
  final double? locationLng;

  SOSReportItem({
    required this.reportId,
    required this.userName,
    required this.phoneNumber,
    required this.distanceKm,
    required this.timestamp,
    this.assignedUnitId,
    this.locationLat,
    this.locationLng,
  });

  /// Check if report is already assigned to a unit
  bool get isAssigned => assignedUnitId != null;

  /// Check if report has location data
  bool get hasLocation => locationLat != null && locationLng != null;
}

