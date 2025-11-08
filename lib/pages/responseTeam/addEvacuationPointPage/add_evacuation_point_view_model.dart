import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:resqapp/services/supabase_service.dart';

class AddEvacuationPointViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  
  // Reactive state
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final Rx<LatLng> selectedLocation = LatLng(-6.2088, 106.8456).obs; // Selected evacuation point location
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;
  final RxString selectedCity = 'Jakarta'.obs; // Default city
  final RxString selectedLocationDetail = ''.obs; // Location detail from geocoding
  final RxBool isGeocodingLoading = false.obs;

  AddEvacuationPointViewModel({required this.instanceCode});

  @override
  void onInit() {
    _initializeLocation();
    super.onInit();
  }

  /// Initialize location using the LocationHelper
  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      
      LocationResult result = await LocationHelper.initializeLocation();
      
      currentLocation.value = result.location;
      selectedLocation.value = result.location; // Initially set selected location to current location
      hasLocationPermission.value = result.hasPermission;
      
      // Move map to the location
      mapController.move(currentLocation.value, 15.0);
      
    } catch (e) {
      // LocationHelper already handles error messages
      hasLocationPermission.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update selected location when map is moved
  void onMapPositionChanged(MapCamera camera) {
    selectedLocation.value = camera.center;
  }

  /// Move map to a specific location
  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
  }

  /// Move to current user location
  void moveToCurrentLocation() {
    if (hasLocationPermission.value) {
      mapController.move(currentLocation.value, 16.0);
      selectedLocation.value = currentLocation.value;
    }
  }

  /// Refresh current location
  Future<void> refreshCurrentLocation() async {
    if (!hasLocationPermission.value) return;
    
    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.getCurrentLocationSilent();
      
      if (result.hasPermission) {
        currentLocation.value = result.location;
      }
    } catch (e) {
      // Silent refresh, no error messages
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry location initialization
  Future<void> retryLocationRequest() async {
    await _initializeLocation();
  }

  /// Handle confirmation button press
  Future<void> onConfirmPressed() async {
    try {
      isLoading.value = true;

      // Get stored response team data to get response_team_id
      final storedResponseTeam = await SupabaseService.getStoredResponseTeam();
      
      if (storedResponseTeam == null) {
        Get.snackbar(
          'Error',
          'Response team not logged in. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('Adding evacuation point with data:');
      print('Location: ${selectedLocation.value.latitude}, ${selectedLocation.value.longitude}');
      print('City: ${selectedCity.value.isNotEmpty ? selectedCity.value : 'Jakarta'}');
      print('Response Team ID: ${storedResponseTeam.responseTeamId}');

      final result = await SupabaseService.addEvacuationPoint(
        locationLat: selectedLocation.value.latitude,
        locationLng: selectedLocation.value.longitude,
        city: selectedCity.value.isNotEmpty ? selectedCity.value : 'Jakarta',
        locationDetail: selectedLocationDetail.value.isNotEmpty 
            ? selectedLocationDetail.value 
            : 'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}',
        responseTeamId: storedResponseTeam.responseTeamId,
      );
      
      print('SupabaseService.addEvacuationPoint result: $result');
      
      if (result != null) {
        print('Success: Evacuation point added successfully');
    
        // Navigate back with success result
        Get.back(result: true);
      } else {
        print('Error: Failed to add evacuation point - result is null');
        Get.snackbar(
          'Error',
          'Failed to add evacuation point',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Exception in onConfirmPressed: $e');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate back
  void onBackPressed() {
    Get.back(result: false);
  }
}