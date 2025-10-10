import 'package:flutter/material.dart';

enum DisasterType {
  flood,
  fire,
  earthquake,
  volcano,
  unknown;

  /// Returns the display name of the disaster type
  String get displayName {
    switch (this) {
      case DisasterType.flood:
        return 'Banjir';
      case DisasterType.fire:
        return 'Kebakaran';
      case DisasterType.earthquake:
        return 'Gempa Bumi';
      case DisasterType.volcano:
        return 'Erupsi Gunung Berapi';
      case DisasterType.unknown:
        return 'Tidak Diketahui';
    }
  }

  /// Returns the color associated with this disaster type
  Color get color {
    switch (this) {
      case DisasterType.flood:
        return Colors.blue;
      case DisasterType.fire:
        return Colors.red;
      case DisasterType.earthquake:
        return Colors.orange;
      case DisasterType.volcano:
        return Colors.deepOrange;
      case DisasterType.unknown:
        return Colors.grey;
    }
  }

  /// Returns the icon associated with this disaster type
  IconData get icon {
    switch (this) {
      case DisasterType.flood:
        return Icons.water_damage;
      case DisasterType.fire:
        return Icons.local_fire_department;
      case DisasterType.earthquake:
        return Icons.vibration;
      case DisasterType.volcano:
        return Icons.terrain;
      case DisasterType.unknown:
        return Icons.warning;
    }
  }

  /// Parse a string to DisasterType enum
  static DisasterType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
      case 'banjir':
        return DisasterType.flood;
      case 'fire':
      case 'kebakaran':
        return DisasterType.fire;
      case 'earthquake':
      case 'gempa':
      case 'gempa bumi':
        return DisasterType.earthquake;
      case 'volcano':
      case 'volcanic eruption':
      case 'erupsi':
      case 'erupsi gunung berapi':
        return DisasterType.volcano;
      default:
        return DisasterType.unknown;
    }
  }

  /// Convert enum to string for API/database storage
  String toApiString() {
    switch (this) {
      case DisasterType.flood:
        return 'flood';
      case DisasterType.fire:
        return 'fire';
      case DisasterType.earthquake:
        return 'earthquake';
      case DisasterType.volcano:
        return 'volcano';
      case DisasterType.unknown:
        return 'unknown';
    }
  }
}

