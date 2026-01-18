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
  final EvacuationPoint? existingEvacuationPoint;
  final MapController mapController = MapController();

  final Rx<LatLng> currentLocation = LatLng(-6.2088, 106.8456).obs;
  final Rx<LatLng> selectedLocation = LatLng(-6.2088, 106.8456).obs;
  final RxBool isLoading = false.obs;
  final RxBool hasLocationPermission = false.obs;
  final RxString selectedCity = 'Jakarta'.obs;
  final RxString selectedLocationDetail = ''.obs;
  final RxBool isGeocodingLoading = false.obs;

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

  bool get isEditMode => existingEvacuationPoint != null;

  @override
  void onClose() {
    _geocodingTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;

      if (isEditMode && existingEvacuationPoint!.hasLocation()) {
        await _getDetails(existingEvacuationPoint!.evacuationId!);
        hasLocationPermission.value = true;
        
        mapController.move(currentLocation.value, 15.0);
      } else {
        LocationResult result = await LocationHelper.getCurrentLocation();

        currentLocation.value = result.location;
        selectedLocation.value = result.location;
        hasLocationPermission.value = result.hasPermission;

        mapController.move(currentLocation.value, 15.0);

        _performGeocodingForSelectedLocation();
      }
    } catch (e) {
      hasLocationPermission.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void onMapPositionChanged(MapCamera camera) {
    selectedLocation.value = camera.center;
    _startGeocodingTimer();
  }

  void _startGeocodingTimer() {
    _geocodingTimer?.cancel();

    _geocodingTimer = Timer(Duration(milliseconds: 500), () {
      _performGeocodingForSelectedLocation();
    });
  }

  Future<void> _performGeocodingForSelectedLocation() async {
    try {
      isGeocodingLoading.value = true;

      LocationDetailResult result = await LocationHelper.getLocationDetails(
        selectedLocation.value,
      );

      if (result.success) {
        selectedCity.value = result.city;
        selectedLocationDetail.value = result.locationDetail;
      } else {
        selectedCity.value = 'Unknown City';
        selectedLocationDetail.value =
            'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}';
      }
    } catch (e) {
      selectedCity.value = 'Unknown City';
      selectedLocationDetail.value =
          'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}';
    } finally {
      isGeocodingLoading.value = false;
    }
  }

  void moveToLocation(LatLng location) {
    mapController.move(location, 16.0);
    selectedLocation.value = location;
    _startGeocodingTimer();
  }

  void moveToCurrentLocation() {
    if (hasLocationPermission.value) {
      mapController.move(currentLocation.value, 16.0);
      selectedLocation.value = currentLocation.value;
      _startGeocodingTimer();
    }
  }

  Future<void> refreshCurrentLocation() async {
    if (!hasLocationPermission.value) return;

    try {
      isLoading.value = true;
      LocationResult result = await LocationHelper.getCurrentLocationSilent();

      if (result.hasPermission) {
        currentLocation.value = result.location;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retryLocationRequest() async {
    await _initializeLocation();
  }

  Future<void> _getDetails(String evacuationId) async {
    try {
      final point = await SupabaseService.getEvacuationPointById(evacuationId);
      
      if (point != null) {
        currentLocation.value = LatLng(
          point.locationLat ?? 0.0,
          point.locationLng ?? 0.0,
        );
        selectedLocation.value = currentLocation.value;
        selectedCity.value = point.city ?? 'Unknown City';
        selectedLocationDetail.value = point.locationDetail ?? '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil detail poin evakuasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool validateUpdatedData(EvacuationPoint data) {
    if (data.locationLat == null || data.locationLng == null) {
        Get.snackbar(
          'Error',
          'Lokasi tidak valid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
    }
    if ((data.city?.isEmpty ?? true) && (data.locationDetail?.isEmpty ?? true)) {
       Get.snackbar(
          'Error',
          'Detail lokasi harus diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      return false;
    }
    return true;
  }

  Future<void> modifyEvacuationPoint() async {
    try {
      isLoading.value = true;
      final storedResponseTeam = await SupabaseService.getStoredResponseTeam();
      
      if (storedResponseTeam == null) {
        Get.snackbar(
          'Error',
          'Response team not logged in. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
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
          locationDetail:
              selectedLocationDetail.value.isNotEmpty
                  ? selectedLocationDetail.value
                  : 'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}',
          createdAt: existingEvacuationPoint!.createdAt,
        );

        if (!validateUpdatedData(updatedPoint)) {
          isLoading.value = false;
          return;
        }

        final success = await SupabaseService.updateEvacuationPoint(
          updatedPoint,
        );

        if (success) {
          Get.back(result: true);
        } else {
          Get.snackbar(
            'Error',
            'Gagal memperbarui poin evakuasi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 2),
          );
        }
      } else {
        await _addNewEvacuationPoint();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        '${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addNewEvacuationPoint() async {
     final storedResponseTeam = await SupabaseService.getStoredResponseTeam();

    final result = await SupabaseService.saveNewEvacuationPoint(
      locationLat: selectedLocation.value.latitude,
      locationLng: selectedLocation.value.longitude,
      city: selectedCity.value.isNotEmpty ? selectedCity.value : 'Jakarta',
      locationDetail:
          selectedLocationDetail.value.isNotEmpty
              ? selectedLocationDetail.value
              : 'Lat: ${selectedLocation.value.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.value.longitude.toStringAsFixed(6)}',
      responseTeamId: storedResponseTeam?.responseTeamId ?? "",
    );

    if (result != null) {
      Get.back(result: true);
    } else {
      Get.snackbar(
        'Error',
        'Gagal menambahkan poin evakuasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );
      throw("Error adding new location. Please try again");
    }
  }

  void onBackPressed() {
    Get.back(result: false);
  }
}
