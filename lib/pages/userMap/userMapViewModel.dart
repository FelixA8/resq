
// ViewModel
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/pages/userMap/models/disasterReport.dart';
import 'package:resqapp/pages/userMap/models/safetyPoint.dart';

class UserMapViewModel extends ChangeNotifier {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(-6.2088, 106.8456); // Jakarta default
  List<DisasterReport> _disasterReports = [];
  List<SafetyPoint> _safetyPoints = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLocationPermission = false;
  bool _locationServiceEnabled = false;

  // Getters
  MapController get mapController => _mapController;
  LatLng get currentLocation => _currentLocation;
  List<DisasterReport> get disasterReports => _disasterReports;
  List<SafetyPoint> get safetyPoints => _safetyPoints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLocationPermission => _hasLocationPermission;
  bool get locationServiceEnabled => _locationServiceEnabled;

  UserMapViewModel() {

    getQuickLocation();
  }

  void initializeData() {

  }

  Future<void> _getCurrentLocation() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if location services are enabled
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        _errorMessage = 'Location services are disabled. Please enable location services in your device settings.';
        return;
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied. Please grant location permission to use this feature.';
          _hasLocationPermission = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied. Please enable location permissions in your device settings.';
        _hasLocationPermission = false;
        return;
      }

      _hasLocationPermission = true;

      // Try to get current position with multiple fallback strategies
      Position? position;
      
      try {
        // First try: High accuracy with shorter timeout
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );
      } catch (e) {
        // Second try: Medium accuracy with longer timeout
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          );
        } catch (e) {
          // Third try: Low accuracy with longer timeout
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 10),
            );
          } catch (e) {
            // Final fallback: Try to get last known position
            try {
              position = await Geolocator.getLastKnownPosition();
              if (position == null) {
                throw Exception('Unable to get current or last known location');
              }
            } catch (e) {
              throw Exception('All location retrieval methods failed: ${e.toString()}');
            }
          }
        }
      }
      
      _currentLocation = LatLng(position.latitude, position.longitude);
      
      // Move map to current location
      _mapController.move(_currentLocation, 15.0);
      
      // Clear any previous error messages
      _errorMessage = null;
      
    } catch (e) {
      if (e.toString().contains('timeout')) {
        _errorMessage = 'Location request timed out. This might be due to poor GPS signal or network issues. Please try again or check your location settings.';
      } else if (e.toString().contains('permission')) {
        _errorMessage = 'Location permission is required to show your current location.';
      } else if (e.toString().contains('Unable to get current or last known location')) {
        _errorMessage = 'Unable to determine your location. Please ensure GPS is enabled and try again.';
      } else if (e.toString().contains('All location retrieval methods failed')) {
        _errorMessage = 'Location services are not responding. Please check your GPS settings and try again.';
      } else {
        _errorMessage = 'Failed to get current location: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void moveToLocation(LatLng location) {
    _mapController.move(location, 16.0);
  }

  void addDisasterReport(DisasterReport report) {
    _disasterReports.add(report);
    notifyListeners();
  }

  void refreshData() {
    _getCurrentLocation();
    // Refresh disaster reports and safety points from API
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> retryLocationRequest() async {
    await _getCurrentLocation();
  }

  Future<void> getQuickLocation() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Try to get last known position first (faster)
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        _currentLocation = LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
        _mapController.move(_currentLocation, 15.0);
        _hasLocationPermission = true;
        _errorMessage = null;
        return;
      }

      // If no last known position, fall back to current location
      await _getCurrentLocation();
    } catch (e) {
      _errorMessage = 'Quick location failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Color getDisasterColor(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return Colors.blue;
      case 'fire':
        return Colors.red;
      case 'earthquake':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getDisasterIcon(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return Icons.water_damage;
      case 'fire':
        return Icons.local_fire_department;
      case 'earthquake':
        return Icons.vibration;
      default:
        return Icons.warning;
    }
  }

  Color getSafetyPointColor(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Colors.green;
      case 'police':
        return Colors.blue;
      case 'shelter':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData getSafetyPointIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'police':
        return Icons.local_police;
      case 'shelter':
        return Icons.home;
      default:
        return Icons.place;
    }
  }
}