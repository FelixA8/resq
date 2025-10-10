import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Base class for all disasters
sealed class Disaster {
  final String id;
  final LatLng location;
  final String description;
  final DateTime timestamp;
  final String? address;
  final double impactedRadius; // in kilometers

  const Disaster({
    required this.id,
    required this.location,
    required this.description,
    required this.timestamp,
    required this.impactedRadius,
    this.address,
  });

  /// Get the display name of the disaster
  String get displayName;

  /// Get the color associated with this disaster
  Color get color;

  /// Get the icon associated with this disaster
  String get icon;

  /// Get the type string for API storage
  String get typeString;

  /// Factory constructor to create Disaster from JSON
  factory Disaster.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type.toLowerCase()) {
      case 'earthquake':
      case 'gempa':
      case 'gempa bumi':
        return EarthquakeDisaster.fromJson(json);
      case 'flood':
      case 'banjir':
        return FloodDisaster.fromJson(json);
      case 'tsunami':
        return TsunamiDisaster.fromJson(json);
      case 'volcano':
      case 'volcanic eruption':
      case 'erupsi':
      case 'erupsi gunung berapi':
        return VolcanoDisaster.fromJson(json);
      case 'landslide':
      case 'longsor':
        return LandslideDisaster.fromJson(json);
      default:
        throw ArgumentError('Unknown disaster type: $type');
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson();
}

/// Earthquake disaster with specific properties
class EarthquakeDisaster extends Disaster {
  final double strength; // in SR (Skala Richter)
  final bool tsunamiPotential;
  final String alertStatus;

  const EarthquakeDisaster({
    required super.id,
    required super.location,
    required super.description,
    required super.timestamp,
    required super.impactedRadius,
    required this.strength,
    required this.tsunamiPotential,
    required this.alertStatus,
    super.address,
  });

  @override
  String get displayName => 'Gempa Bumi';

  @override
  Color get color => Colors.orange;

  @override
  String get icon => "assets/images/icons/map-disaster-earthquake.png";

  @override
  String get typeString => 'earthquake';

  factory EarthquakeDisaster.fromJson(Map<String, dynamic> json) {
    return EarthquakeDisaster(
      id: json['id'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      impactedRadius: (json['impactedRadius'] as num).toDouble(),
      strength: (json['strength'] as num).toDouble(),
      tsunamiPotential: json['tsunamiPotential'] as bool? ?? false,
      alertStatus: json['alertStatus'] as String,
      address: json['address'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': typeString,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'impactedRadius': impactedRadius,
      'strength': strength,
      'tsunamiPotential': tsunamiPotential,
      'alertStatus': alertStatus,
      if (address != null) 'address': address,
    };
  }
}

/// Flood disaster with specific properties
class FloodDisaster extends Disaster {
  final double waterHeight; // in meters
  final double waterFlowSpeed; // in m/s

  const FloodDisaster({
    required super.id,
    required super.location,
    required super.description,
    required super.timestamp,
    required super.impactedRadius,
    required this.waterHeight,
    required this.waterFlowSpeed,
    super.address,
  });

  @override
  String get displayName => 'Banjir';

  @override
  Color get color => Colors.blue;

  @override
  String get icon => "assets/images/icons/map-disaster-tsunami.png";

  @override
  String get typeString => 'flood';

  factory FloodDisaster.fromJson(Map<String, dynamic> json) {
    return FloodDisaster(
      id: json['id'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      impactedRadius: (json['impactedRadius'] as num).toDouble(),
      waterHeight: (json['waterHeight'] as num).toDouble(),
      waterFlowSpeed: (json['waterFlowSpeed'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': typeString,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'impactedRadius': impactedRadius,
      'waterHeight': waterHeight,
      'waterFlowSpeed': waterFlowSpeed,
      if (address != null) 'address': address,
    };
  }
}

/// Tsunami disaster with specific properties
class TsunamiDisaster extends Disaster {
  final double waveHeight; // in meters
  final String alertStatus;

  const TsunamiDisaster({
    required super.id,
    required super.location,
    required super.description,
    required super.timestamp,
    required super.impactedRadius,
    required this.waveHeight,
    required this.alertStatus,
    super.address,
  });

  @override
  String get displayName => 'Tsunami';

  @override
  Color get color => Colors.blueAccent;

  @override
  String get icon => "assets/images/icons/map-disaster-tsunami.png";

  @override
  String get typeString => 'tsunami';

  factory TsunamiDisaster.fromJson(Map<String, dynamic> json) {
    return TsunamiDisaster(
      id: json['id'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      impactedRadius: (json['impactedRadius'] as num).toDouble(),
      waveHeight: (json['waveHeight'] as num).toDouble(),
      alertStatus: json['alertStatus'] as String,
      address: json['address'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': typeString,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'impactedRadius': impactedRadius,
      'waveHeight': waveHeight,
      'alertStatus': alertStatus,
      if (address != null) 'address': address,
    };
  }
}

/// Volcano disaster with specific properties
class VolcanoDisaster extends Disaster {
  final String alertStatus;

  const VolcanoDisaster({
    required super.id,
    required super.location,
    required super.description,
    required super.timestamp,
    required super.impactedRadius,
    required this.alertStatus,
    super.address,
  });

  @override
  String get displayName => 'Erupsi Gunung Berapi';

  @override
  Color get color => Colors.deepOrange;

  @override
  String get icon => "assets/images/icons/map-disaster-eruption.png";

  @override
  String get typeString => 'volcano';

  factory VolcanoDisaster.fromJson(Map<String, dynamic> json) {
    return VolcanoDisaster(
      id: json['id'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      impactedRadius: (json['impactedRadius'] as num).toDouble(),
      alertStatus: json['alertStatus'] as String,
      address: json['address'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': typeString,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'impactedRadius': impactedRadius,
      'alertStatus': alertStatus,
      if (address != null) 'address': address,
    };
  }
}

/// Landslide disaster with specific properties
class LandslideDisaster extends Disaster {
  final String alertStatus;

  const LandslideDisaster({
    required super.id,
    required super.location,
    required super.description,
    required super.timestamp,
    required super.impactedRadius,
    required this.alertStatus,
    super.address,
  });

  @override
  String get displayName => 'Longsor';

  @override
  Color get color => Colors.brown;

  @override
  String get icon => "assets/images/icons/map-disaster-landslide.png";

  @override
  String get typeString => 'landslide';

  factory LandslideDisaster.fromJson(Map<String, dynamic> json) {
    return LandslideDisaster(
      id: json['id'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      impactedRadius: (json['impactedRadius'] as num).toDouble(),
      alertStatus: json['alertStatus'] as String,
      address: json['address'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': typeString,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'impactedRadius': impactedRadius,
      'alertStatus': alertStatus,
      if (address != null) 'address': address,
    };
  }
}
