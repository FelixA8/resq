import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/location_error.dart';

class ResponseTeamMapViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  
  // Reactive state
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final RxBool isLoading = false.obs;
  final Rx<LocationError?> error = Rx<LocationError?>(null);
  final RxBool hasLocationPermission = false.obs;
  bool _locationServiceEnabled = false;

  ResponseTeamMapViewModel({required this.instanceCode});

  @override
  void onInit() {
    _initializeLocation();
    super.onInit();
  }

  /// Initialize location by checking permissions first, then getting location
  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      error.value = null;

      // Step 1: Check if location services are enabled
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        error.value = LocationError.locationServiceDisabled();
        hasLocationPermission.value = false;
        isLoading.value = false;
        return;
      }

      // Step 2: Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Step 3: Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          error.value = LocationError.permissionDenied();
          hasLocationPermission.value = false;
          isLoading.value = false;
          return;
        }
      }

      // Step 4: Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        error.value = LocationError.permissionDenied();
        hasLocationPermission.value = false;
        isLoading.value = false;
        return;
      }

      // Step 5: Permission granted! Now get location
      hasLocationPermission.value = true;
      await _getLocationAfterPermission();
      
    } catch (e) {
      error.value = LocationError.generic('Failed to initialize location: ${e.toString()}');
      hasLocationPermission.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get location after permission has been granted
  Future<void> _getLocationAfterPermission() async {
    try {
      // Try to get last known position first (quick)
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        currentLocation.value = LatLng(lastKnownPosition.latitude, lastKnownPosition.longitude);
        mapController.move(currentLocation.value, 15.0);
        error.value = null;
        return;
      }
      
      // If no last known position, get current location
      await _getCurrentLocation();
    } catch (e) {
      // If quick location fails, try full location
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      isLoading.value = true;
      error.value = null;

      // Verify location service is still enabled
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        error.value = LocationError.locationServiceDisabled();
        return;
      }

      // Verify permission is still granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        error.value = LocationError.permissionDenied();
        hasLocationPermission.value = false;
        return;
      }

      Position? position;
      
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );
      } catch (e) {
        throw Exception('Location retrieval methods failed: ${e.toString()}');
      }
      
      currentLocation.value = LatLng(position.latitude, position.longitude);
      mapController.move(currentLocation.value, 15.0);
      error.value = null;
    } catch (e) {
      if (e.toString().contains('timeout')) {
        error.value = LocationError.timeout();
      } else if (e.toString().contains('permission')) {
        error.value = LocationError.permissionDenied();
      } else if (e.toString().contains('Unable to get current or last known location')) {
        error.value = LocationError.unableToGetLocation();
      } else if (e.toString().contains('All location retrieval methods failed')) {
        error.value = LocationError.serviceNotResponding();
      } else {
        error.value = LocationError.generic('Failed to get current location: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
  }

  void refreshData() {
    _getCurrentLocation();
  }

  void clearError() {
    error.value = null;
  }

  Future<void> retryLocationRequest() async {
    await _initializeLocation();
  }

  Future<void> getQuickLocation() async {
    await _initializeLocation();
  }
}
