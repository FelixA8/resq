import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/services/location_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEvacuationPointViewModel extends GetxController {
  final String instanceCode;
  final MapController mapController = MapController();
  
  // Reactive state
  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs; // Jakarta default
  final Rx<LatLng> selectedLocation = LatLng(-6.2088, 106.8456).obs; // Selected evacuation point location
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;

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
  void onConfirmPressed() {
    
  }

  /// Navigate back
  void onBackPressed() {
    Get.back();
  }
}