class Earthquake {
  final String tanggal;
  final String jam;
  final String dateTime;
  final String coordinates;
  final String lintang;
  final String bujur;
  final String magnitude;
  final String kedalaman;
  final String wilayah;
  final String potensi;

  Earthquake({
    required this.tanggal,
    required this.jam,
    required this.dateTime,
    required this.coordinates,
    required this.lintang,
    required this.bujur,
    required this.magnitude,
    required this.kedalaman,
    required this.wilayah,
    required this.potensi,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    return Earthquake(
      tanggal: json['Tanggal'] ?? '',
      jam: json['Jam'] ?? '',
      dateTime: json['DateTime'] ?? '',
      coordinates: json['Coordinates'] ?? '',
      lintang: json['Lintang'] ?? '',
      bujur: json['Bujur'] ?? '',
      magnitude: json['Magnitude'] ?? '',
      kedalaman: json['Kedalaman'] ?? '',
      wilayah: json['Wilayah'] ?? '',
      potensi: json['Potensi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Tanggal': tanggal,
      'Jam': jam,
      'DateTime': dateTime,
      'Coordinates': coordinates,
      'Lintang': lintang,
      'Bujur': bujur,
      'Magnitude': magnitude,
      'Kedalaman': kedalaman,
      'Wilayah': wilayah,
      'Potensi': potensi,
    };
  }

  // Helper methods for better data handling
  double get magnitudeValue {
    try {
      return double.parse(magnitude);
    } catch (e) {
      return 0.0;
    }
  }

  int get depthValue {
    try {
      return int.parse(kedalaman.replaceAll(' km', ''));
    } catch (e) {
      return 0;
    }
  }

  DateTime? get parsedDateTime {
    try {
      return DateTime.parse(dateTime);
    } catch (e) {
      return null;
    }
  }

  bool get hasTsunamiPotential {
    return !potensi.toLowerCase().contains('tidak berpotensi');
  }
}

class EarthquakeResponse {
  final List<Earthquake> earthquakes;

  EarthquakeResponse({required this.earthquakes});

  factory EarthquakeResponse.fromJson(Map<String, dynamic> json) {
    final infogempa = json['Infogempa'] as Map<String, dynamic>?;
    final gempaList = infogempa?['gempa'] as List<dynamic>? ?? [];
    
    return EarthquakeResponse(
      earthquakes: gempaList
          .map((json) => Earthquake.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }
}
