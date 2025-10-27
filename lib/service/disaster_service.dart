import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

class EarthquakeService {
  static const String _baseUrl = 'https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json';
  
  static Future<EarthquakeResponse> getEarthquakes() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print(jsonData);
        return EarthquakeResponse.fromJson(jsonData);
      } else {
        throw EarthquakeException(
          'Failed to load earthquake data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is EarthquakeException) {
        rethrow;
      }
      throw EarthquakeException('Network error: ${e.toString()}');
    }
  }
}

class EarthquakeException implements Exception {
  final String message;
  
  EarthquakeException(this.message);
  
  @override
  String toString() => 'EarthquakeException: $message';
}
