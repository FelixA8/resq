import 'package:flutter/material.dart';

enum SafetyPointType {
  hospital,
  police,
  shelter,
  unknown;

  /// Returns the display name of the safety point type
  String get displayName {
    switch (this) {
      case SafetyPointType.hospital:
        return 'Rumah Sakit';
      case SafetyPointType.police:
        return 'Kantor Polisi';
      case SafetyPointType.shelter:
        return 'Tempat Penampungan';
      case SafetyPointType.unknown:
        return 'Tidak Diketahui';
    }
  }

  /// Returns the color associated with this safety point type
  Color get color {
    switch (this) {
      case SafetyPointType.hospital:
        return Colors.green;
      case SafetyPointType.police:
        return Colors.blue;
      case SafetyPointType.shelter:
        return Colors.purple;
      case SafetyPointType.unknown:
        return Colors.grey;
    }
  }

  /// Returns the icon associated with this safety point type
  IconData get icon {
    switch (this) {
      case SafetyPointType.hospital:
        return Icons.local_hospital;
      case SafetyPointType.police:
        return Icons.local_police;
      case SafetyPointType.shelter:
        return Icons.home;
      case SafetyPointType.unknown:
        return Icons.place;
    }
  }

  /// Parse a string to SafetyPointType enum
  static SafetyPointType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
      case 'rumah sakit':
      case 'rs':
        return SafetyPointType.hospital;
      case 'police':
      case 'polisi':
      case 'kantor polisi':
        return SafetyPointType.police;
      case 'shelter':
      case 'penampungan':
      case 'tempat penampungan':
        return SafetyPointType.shelter;
      default:
        return SafetyPointType.unknown;
    }
  }

  /// Convert enum to string for API/database storage
  String toApiString() {
    switch (this) {
      case SafetyPointType.hospital:
        return 'hospital';
      case SafetyPointType.police:
        return 'police';
      case SafetyPointType.shelter:
        return 'shelter';
      case SafetyPointType.unknown:
        return 'unknown';
    }
  }
}



