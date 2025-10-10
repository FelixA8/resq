// ViewModel
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/pages/userMap/models/disaster.dart';
import 'package:resqapp/pages/userMap/models/safetyPoint.dart';
import 'package:resqapp/pages/userMap/models/locationError.dart';

class UserMapViewModel extends ChangeNotifier {
  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(-6.2088, 106.8456); // Jakarta default
  List<Disaster> disasters = [];
  List<SafetyPoint> safetyPoints = [];
  bool isLoading = false;
  LocationError? error;
  bool hasLocationPermission = false;
  bool _locationServiceEnabled = false;
  Disaster? selectedDisaster;

  UserMapViewModel() {
    getQuickLocation();
    _initializeData();
  }

  void _initializeData() {
    // Add sample disasters for testing with type-specific properties
    disasters = [
      VolcanoDisaster(
        id: '1',
        location: LatLng(-6.2088, 106.8556),
        description: 'Erupsi gunung berapi dengan tinggi kolom abu 3.5 km',
        timestamp: DateTime.now(),
        address: 'Jl. Akasia 9-12, Kapasa, Kec. Tamalanrea, Kota Makassar, Sulawesi Selatan 90245',
        impactedRadius: 256,
        alertStatus: '3.5 M',
      ),
      EarthquakeDisaster(
        id: '2',
        location: LatLng(-6.1888, 106.8656),
        description: 'Gempa bumi berkekuatan 6.5 SR',
        timestamp: DateTime.now(),
        address: 'Jl. Gatot Subroto, Jakarta Selatan',
        impactedRadius: 150,
        strength: 3.32,
        tsunamiPotential: false,
        alertStatus: 'Siaga 3',
      ),
      FloodDisaster(
        id: '3',
        location: LatLng(-6.1988, 106.8356),
        description: 'Banjir setinggi 2 meter dengan arus deras',
        timestamp: DateTime.now(),
        address: 'Jl. Sudirman, Jakarta Pusat',
        impactedRadius: 50,
        waterHeight: 3.5,
        waterFlowSpeed: 35,
      ),
      TsunamiDisaster(
        id: '4',
        location: LatLng(-6.2188, 106.8256),
        description: 'Tsunami dengan tinggi gelombang 3.5 meter',
        timestamp: DateTime.now(),
        address: 'Jl. Akasia 9-12, Kapasa, Kec. Tamalanrea, Kota Makassar, Sulawesi Selatan 90245',
        impactedRadius: 256,
        waveHeight: 3.5,
        alertStatus: 'Siaga 3',
      ),
      LandslideDisaster(
        id: '5',
        location: LatLng(-6.2288, 106.8756),
        description: 'Longsor dengan area terdampak 256 km',
        timestamp: DateTime.now(),
        address: 'Jl. Akasia 9-12, Kapasa, Kec. Tamalanrea, Kota Makassar, Sulawesi Selatan 90245',
        impactedRadius: 256,
        alertStatus: '3.5 M',
      ),
    ];
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        error = LocationError.locationServiceDisabled();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          error = LocationError.permissionDenied();
          hasLocationPermission = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        error = LocationError.permissionDenied();
        hasLocationPermission = false;
        return;
      }

      hasLocationPermission = true;
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
      
      currentLocation = LatLng(position.latitude, position.longitude);
      mapController.move(currentLocation, 15.0);
      error = null;
    } catch (e) {
      if (e.toString().contains('timeout')) {
        error = LocationError.timeout();
      } else if (e.toString().contains('permission')) {
        error = LocationError.permissionDenied();
      } else if (e.toString().contains('Unable to get current or last known location')) {
        error = LocationError.unableToGetLocation();
      } else if (e.toString().contains('All location retrieval methods failed')) {
        error = LocationError.serviceNotResponding();
      } else {
        error = LocationError.generic('Failed to get current location: ${e.toString()}');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
  }

  void addDisaster(Disaster disaster) {
    disasters.add(disaster);
    notifyListeners();
  }

  void refreshData() {
    _getCurrentLocation();
    // Refresh disasters and safety points from API
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<void> retryLocationRequest() async {
    await _getCurrentLocation();
  }

  Future<void> getQuickLocation() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        currentLocation = LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
        mapController.move(currentLocation, 15.0);
        hasLocationPermission = true;
        error = null;
        return;
      }
      
      await _getCurrentLocation();
    } catch (e) {
      error = LocationError.quickLocationFailed();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectDisaster(Disaster disaster) {
    selectedDisaster = disaster;
    notifyListeners();
  }

  void clearSelectedDisaster() {
    selectedDisaster = null;
    notifyListeners();
  }
}
