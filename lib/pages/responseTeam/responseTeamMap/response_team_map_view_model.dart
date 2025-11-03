import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ResponseTeamMapViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  
  // Reactive state
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final RxBool isLoading = false.obs;
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

      // Step 1: Check if location services are enabled
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        hasLocationPermission.value = false;
        isLoading.value = false;
        Get.snackbar(
          'Location Service Disabled',
          'Please enable location services to use this feature',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Step 2: Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Step 3: Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          hasLocationPermission.value = false;
          isLoading.value = false;
          Get.snackbar(
            'Permission Denied',
            'Location permission is required to show your position on the map',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Step 4: Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
        isLoading.value = false;
        Get.snackbar(
          'Permission Denied Permanently',
          'Please enable location permission in your device settings',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Step 5: Permission granted! Now get location
      hasLocationPermission.value = true;
      await _getLocationAfterPermission();
      
    } catch (e) {
      hasLocationPermission.value = false;
      Get.snackbar(
        'Location Error',
        'Failed to initialize location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
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

      // Verify location service is still enabled
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        Get.snackbar(
          'Location Service Disabled',
          'Please enable location services to use this feature',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Verify permission is still granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
        Get.snackbar(
          'Permission Denied',
          'Location permission is required to show your position on the map',
          snackPosition: SnackPosition.BOTTOM,
        );
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
    } catch (e) {
      if (e.toString().contains('timeout')) {
        Get.snackbar(
          'Location Timeout',
          'Unable to get location. Please try again.',
          backgroundColor: const Color(0xFFB71C1C),
          colorText: Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (e.toString().contains('permission')) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required to show your position on the map',
          backgroundColor: const Color(0xFFB71C1C),
          colorText: Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (e.toString().contains('Unable to get current or last known location')) {
        Get.snackbar(
          'Location Unavailable',
          'Unable to get your current location. Please try again.',
          backgroundColor: const Color(0xFFB71C1C),
          colorText: Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Location Service Not Responding',
          'The location service is not responding. Please try again later.',
          backgroundColor: const Color(0xFFB71C1C),
          colorText: Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
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

  Future<void> retryLocationRequest() async {
    await _initializeLocation();
  }

  Future<void> getQuickLocation() async {
    await _initializeLocation();
  }
}
