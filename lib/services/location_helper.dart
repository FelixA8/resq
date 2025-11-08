import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  static const LatLng defaultLocation = LatLng(
    -6.2088,
    106.8456,
  ); // Jakarta default

  /// Initialize location by checking permissions first, then getting location
  static Future<LocationResult> initializeLocation() async {
    try {
      // Step 1: Check if location services are enabled
      bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        Get.snackbar(
          'Location Service Disabled',
          'Please enable location services to use this feature',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Location service disabled',
        );
      }

      // Step 2: Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Step 3: Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required to show your position on the map',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 1),
            isDismissible: true,
          );
          return LocationResult(
            location: defaultLocation,
            hasPermission: false,
            error: 'Permission denied',
          );
        }
      }

      // Step 4: Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied Permanently',
          'Please enable location permission in your device settings',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Permission denied permanently',
        );
      }

      // Step 5: Permission granted! Now get location
      return await _getLocationAfterPermission();
    } catch (e) {
      Get.snackbar(
        'Location Error',
        'Failed to initialize location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  /// Get location after permission has been granted
  static Future<LocationResult> _getLocationAfterPermission() async {
    try {
      // Try to get last known position first (quick)
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return LocationResult(
          location: LatLng(
            lastKnownPosition.latitude,
            lastKnownPosition.longitude,
          ),
          hasPermission: true,
        );
      }

      // If no last known position, get current location
      return await _getCurrentLocation();
    } catch (e) {
      // If quick location fails, try full location
      return await _getCurrentLocation();
    }
  }

  static Future<LocationResult> _getCurrentLocation() async {
    try {
      // Verify location service is still enabled
      bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        Get.snackbar(
          'Location Service Disabled',
          'Please enable location services to use this feature',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Location service disabled',
        );
      }

      // Verify permission is still granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required to show your position on the map',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Permission denied',
        );
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

      return LocationResult(
        location: LatLng(position.latitude, position.longitude),
        hasPermission: true,
      );
    } catch (e) {
      String errorMessage = 'Location Service Not Responding';
      Color backgroundColor = const Color(0xFFB71C1C);

      if (e.toString().contains('timeout')) {
        errorMessage = 'Unable to get location. Please try again.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Location permission is required to show your position on the map';
      } else if (e.toString().contains(
        'Unable to get current or last known location',
      )) {
        errorMessage = 'Unable to get your current location. Please try again.';
      }

      Get.snackbar(
        'Location Error',
        errorMessage,
        backgroundColor: backgroundColor,
        colorText: Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 1),
        isDismissible: true,
      );

      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  /// Get current location without showing error messages (for refresh operations)
  static Future<LocationResult> getCurrentLocationSilent() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );

      return LocationResult(
        location: LatLng(position.latitude, position.longitude),
        hasPermission: true,
      );
    } catch (e) {
      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }
}

class LocationResult {
  final LatLng location;
  final bool hasPermission;
  final String? error;

  LocationResult({
    required this.location,
    required this.hasPermission,
    this.error,
  });
}
