import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/location_error.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';

class UserMapViewModel extends ChangeNotifier {
  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(-6.2088, 106.8456); // Jakarta default
  bool isLoading = false;
  LocationError? error;
  bool hasLocationPermission = false;
  bool _locationServiceEnabled = false;
  
  // Map annotations (frontend-only for now; replace with backend data later)
  final List<LatLng> _evacuationPoints = [];
  final List<LatLng> _disasterPoints = [];
  
  // SOS State Management
  SOSWaitingViewModel? _sosWaitingViewModel;
  bool _isSOSActive = false;
  
  bool get isSOSActive => _isSOSActive;
  SOSWaitingViewModel? get sosWaitingViewModel => _sosWaitingViewModel;

  UserMapViewModel() {
    getQuickLocation();
    _initializeData();
  }

  void _initializeData() {
    // TODO: Replace with backend-driven data loading
    // Dummy evacuation points
    _evacuationPoints
      ..clear()
      ..addAll([
        LatLng(-6.2075, 106.8450),
        LatLng(-6.2130, 106.8500),
      ]);

    // Dummy disaster (earthquake) points
    _disasterPoints
      ..clear()
      ..addAll([
        LatLng(-6.2200, 106.8400),
        LatLng(-6.2000, 106.8600),
      ]);

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
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );
      } catch (e) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          );
        } catch (e) {
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

  void refreshData() {
    _getCurrentLocation();
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
  
  // SOS Management Methods
  void startSOS() {
    _isSOSActive = true;
    // Create SOSWaitingViewModel if it doesn't exist, or reuse existing one
    if (_sosWaitingViewModel == null) {
      _sosWaitingViewModel = SOSWaitingViewModel();
    }
    notifyListeners();
  }
  
  void stopSOS() {
    _isSOSActive = false;
    _sosWaitingViewModel?.dispose();
    _sosWaitingViewModel = null;
    notifyListeners();
  }

  // ---------- Annotations API (for future backend integration) ----------
  List<LatLng> get evacuationPoints => List.unmodifiable(_evacuationPoints);
  List<LatLng> get disasterPoints => List.unmodifiable(_disasterPoints);

  /// Replace all evacuation points (e.g., after fetching from backend)
  void setEvacuationPoints(List<LatLng> points) {
    _evacuationPoints
      ..clear()
      ..addAll(points);
    notifyListeners();
  }

  /// Replace all disaster points (e.g., after fetching from backend)
  void setDisasterPoints(List<LatLng> points) {
    _disasterPoints
      ..clear()
      ..addAll(points);
    notifyListeners();
  }

  /// Add a single evacuation point (used when response team creates one)
  void addEvacuationPoint(LatLng point) {
    _evacuationPoints.add(point);
    notifyListeners();
  }

  /// Add a single disaster point (used when a new event is received)
  void addDisasterPoint(LatLng point) {
    _disasterPoints.add(point);
    notifyListeners();
  }
}
