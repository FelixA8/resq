import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/services/location_helper.dart';

class AddEvacuationPointViewModel extends GetxController {
  final String instanceCode;
  final EvacuationPoint? existingEvacuationPoint; // For editing mode
  final MapController mapController = MapController();

  // Reactive state
  final Rx<LatLng> currentLocation =
      LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final Rx<LatLng> selectedLocation =
      LatLng(-6.2088, 106.8456).obs; // Selected evacuation point location
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;
  final RxString selectedCity = 'Jakarta'.obs; // Default city
  final RxString selectedLocationDetail = ''.obs; // Location detail from geocoding
  final RxBool isGeocodingLoading = false.obs;

  // Timer for debounced geocoding
  Timer? _geocodingTimer;

  AddEvacuationPointViewModel({
    required this.instanceCode,
    this.existingEvacuationPoint,
  });

  @override
  void onInit() {
    _initializeLocation();
    super.onInit();
  }

  /// Check if this is editing mode
  bool get isEditMode => existingEvacuationPoint != null;

  @override
  void onClose() {
    // Cancel any pending geocoding timer
    _geocodingTimer?.cancel();
    super.onClose();
  }

  /// Initialize location using the LocationHelper
  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;

      // If editing mode, use existing evacuation point location
      if (isEditMode && existingEvacuationPoint!.hasLocation()) {
        currentLocation.value = LatLng(
          existingEvacuationPoint!.locationLat!,
          existingEvacuationPoint!.locationLng!,
        );
        selectedLocation.value = currentLocation.value;
        selectedCity.value = existingEvacuationPoint!.city ?? 'Unknown City';
        selectedLocationDetail.value = existingEvacuationPoint!.locationDetail ?? '';
        hasLocationPermission.value = true;

        // Move map to the existing location
        mapController.move(currentLocation.value, 15.0);
      } else {
        // Normal initialization for new evacuation point
        LocationResult result = await LocationHelper.initializeLocation();

        currentLocation.value = result.location;
        selectedLocation.value = result.location;
        hasLocationPermission.value = result.hasPermission;

        // Move map to the location
        mapController.move(currentLocation.value, 15.0);

        // Perform initial geocoding for the current location
        _performGeocodingForSelectedLocation();
      }
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
    _startGeocodingTimer();
  }

  void _startGeocodingTimer() {
    // Cancel existing timer if it exists
    _geocodingTimer?.cancel();
    
    // Start new timer for 1 second delay
    _geocodingTimer = Timer(Duration(milliseconds: 500), () {
      _performGeocodingForSelectedLocation();
    });
  }

  /// Perform geocoding for the currently selected location
  Future<void> _performGeocodingForSelectedLocation() async {
    try {
      isGeocodingLoading.value = true;
      
      LocationDetailResult result = await LocationHelper.getLocationDetails(selectedLocation.value);
      
      if (result.success) {
        selectedCity.value = result.city;
        selectedLocationDetail.value = result.locationDetail;
      } else {
        // Fallback to coordinates if geocoding fails
        selectedCity.value = 'Unknown City';
        selectedLocationDetail.value = 'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}';
      }
    } catch (e) {
      // Silent failure for geocoding - use coordinates as fallback
      selectedCity.value = 'Unknown City';
      selectedLocationDetail.value = 'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}';
    } finally {
      isGeocodingLoading.value = false;
    }
  }

  /// Move map to a specific location
  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
    selectedLocation.value = location;
    _startGeocodingTimer();
  }

  /// Move to current user location
  void moveToCurrentLocation() {
    if (hasLocationPermission.value) {
      mapController.move(currentLocation.value, 16.0);
      selectedLocation.value = currentLocation.value;
      _startGeocodingTimer();
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

      if (isEditMode) {
        final updatedPoint = EvacuationPoint(
          evacuationId: existingEvacuationPoint!.evacuationId,
          responseTeamId: existingEvacuationPoint!.responseTeamId,
          locationLat: selectedLocation.value.latitude,
          locationLng: selectedLocation.value.longitude,
          city: selectedCity.value.isNotEmpty ? selectedCity.value : 'Jakarta',
          locationDetail: selectedLocationDetail.value.isNotEmpty 
              ? selectedLocationDetail.value 
              : 'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}',
          createdAt: existingEvacuationPoint!.createdAt,
        );

        final success = await SupabaseService.modifyEvacuationPoint(updatedPoint);
        
        if (success) {
          print('Success: Evacuation point updated successfully');  

          Get.back(result: true);
        } else {
          print('Error: Failed to update evacuation point');
          Get.snackbar(
            'Error',
            'Failed to update evacuation point',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        final result = await SupabaseService.addEvacuationPoint(
          locationLat: selectedLocation.value.latitude,
          locationLng: selectedLocation.value.longitude,
          city: selectedCity.value.isNotEmpty ? selectedCity.value : 'Jakarta',
          locationDetail: selectedLocationDetail.value.isNotEmpty 
              ? selectedLocationDetail.value 
              : 'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}',
          responseTeamId: storedResponseTeam.responseTeamId,
        );
        
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
