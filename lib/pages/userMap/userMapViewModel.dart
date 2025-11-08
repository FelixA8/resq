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
  
  // Map annotations
  // Disaster points: Retrieved via API, appear in both maps
  final List<LatLng> _disasterPoints = [];
  // Evacuation points: Created by response team, appear in both maps
  final List<LatLng> _evacuationPoints = [];
  
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
    // Load disaster points from API (using dummy data for now)
    _loadDisasterPoints();
    // Load evacuation points (these come from response team, using dummy data for now)
    _loadEvacuationPoints();
  }

  /// Load disaster points from API
  /// TODO: Replace with actual API call
  Future<void> _loadDisasterPoints() async {
    try {
      // TODO: Replace with actual API call
      // Example: final response = await disasterService.getDisasterPoints();
      // _disasterPoints.clear();
      // _disasterPoints.addAll(response.map((point) => LatLng(point.lat, point.lng)));
      
      // Dummy data for now
      _disasterPoints
        ..clear()
        ..addAll([
          LatLng(-6.2200, 106.8400),
          LatLng(-6.2000, 106.8600),
        ]);
      
      notifyListeners();
    } catch (e) {
      // Handle error - for now, just use empty list
      _disasterPoints.clear();
      notifyListeners();
    }
  }

  /// Load evacuation points (created by response team)
  /// TODO: Replace with actual API call or real-time listener
  Future<void> _loadEvacuationPoints() async {
    try {
      // TODO: Replace with actual API call or real-time listener
      // Example: final response = await evacuationService.getEvacuationPoints();
      // _evacuationPoints.clear();
      // _evacuationPoints.addAll(response.map((point) => LatLng(point.lat, point.lng)));
      
      // Dummy data for now
      _evacuationPoints
        ..clear()
        ..addAll([
          LatLng(-6.2075, 106.8450),
          LatLng(-6.2130, 106.8500),
        ]);
      
      notifyListeners();
    } catch (e) {
      // Handle error - for now, just use empty list
      _evacuationPoints.clear();
      notifyListeners();
    }
  }

  /// Refresh disaster points from API
  Future<void> refreshDisasterPoints() async {
    await _loadDisasterPoints();
  }

  /// Refresh evacuation points
  Future<void> refreshEvacuationPoints() async {
    await _loadEvacuationPoints();
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

  // ---------- Annotations API ----------
  List<LatLng> get evacuationPoints => List.unmodifiable(_evacuationPoints);
  List<LatLng> get disasterPoints => List.unmodifiable(_disasterPoints);

  /// Replace all disaster points (called after fetching from API)
  /// This should be called when disaster data is retrieved from API
  void setDisasterPoints(List<LatLng> points) {
    _disasterPoints
      ..clear()
      ..addAll(points);
    notifyListeners();
  }

  /// Replace all evacuation points (called when evacuation points are updated)
  /// This should be called when response team adds/removes evacuation points
  void setEvacuationPoints(List<LatLng> points) {
    _evacuationPoints
      ..clear()
      ..addAll(points);
    notifyListeners();
  }

  /// Add a single evacuation point (called when response team creates one)
  /// This should be called via real-time listener or API callback
  void addEvacuationPoint(LatLng point) {
    if (!_evacuationPoints.contains(point)) {
      _evacuationPoints.add(point);
      notifyListeners();
    }
  }

  /// Remove a single evacuation point (called when response team removes one)
  void removeEvacuationPoint(LatLng point) {
    _evacuationPoints.remove(point);
    notifyListeners();
  }

  /// Add a single disaster point (called when a new disaster event is received from API)
  void addDisasterPoint(LatLng point) {
    if (!_disasterPoints.contains(point)) {
      _disasterPoints.add(point);
      notifyListeners();
    }
  }

  /// Remove a single disaster point (called when a disaster is resolved/removed)
  void removeDisasterPoint(LatLng point) {
    _disasterPoints.remove(point);
    notifyListeners();
  }

  // ---------- SOS Functionality ----------
  
  /// Send SOS with current location to response team
  /// This will send the user's current location to the backend,
  /// which will then notify the response team
  /// TODO: Replace with actual API call
  Future<void> sendSOS() async {
    try {
      // TODO: Call API to send SOS with current location
      // Example: await sosService.sendSOS(currentLocation);
      // The backend will then notify response team via real-time listener or API
      
      // For now, this is a placeholder - in real implementation,
      // the backend will receive this and notify response team
      // Response team will receive it via their API listener and call addSOSPoint()
      
      // TODO: After API call succeeds, you might want to show success message
    } catch (e) {
      // Handle error - could show error message to user
      rethrow;
    }
  }
}