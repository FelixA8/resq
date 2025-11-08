import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/add_evacuation_point_view.dart';
import 'package:resqapp/service/supabase_service.dart';

class ResponseTeamEvacuationPointViewModel extends GetxController {
  final String instanceCode;
  
  // Reactive state
  final RxList<EvacuationPoint> evacuationPoints = <EvacuationPoint>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalEvacuationPoints = 0.obs;

  ResponseTeamEvacuationPointViewModel({required this.instanceCode});

  @override
  void onInit() {
    super.onInit();
    _loadEvacuationPoints();
  }

  /// Load evacuation points from the database
  Future<void> _loadEvacuationPoints() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print('Loading evacuation points from database...');
      final response = await SupabaseService.getEvacuationPoints();
      evacuationPoints.value = response;
      totalEvacuationPoints.value = response.length;
      
      print('Loaded ${response.length} evacuation points');
      
    } catch (e) {
      print('Error loading evacuation points: $e');
      errorMessage.value = 'Failed to load evacuation points: ${e.toString()}';
      
      // Only show snackbar if this is not a silent refresh
      if (isLoading.value) {
        Get.snackbar(
          'Error',
          'Failed to load evacuation points',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh evacuation points data
  Future<void> refreshData() async {
    print('Refreshing evacuation points data...');
    await _loadEvacuationPoints();
  }

  /// Manual refresh with user feedback
  Future<void> manualRefresh() async {
    try {
      await refreshData();
      Get.snackbar(
        'Success',
        'Evacuation points refreshed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Add new evacuation point
  void addEvacuationPoint() async {
    final result = await Get.to(() => const AddEvacuationPointView());
    
    // If result is true, it means a new evacuation point was added successfully
    if (result == true) {
      print('Refreshing evacuation points after successful addition');
      await refreshData();
    }
  }

  /// Edit evacuation point
  void editEvacuationPoint(EvacuationPoint point) {
    // TODO: Navigate to edit evacuation point screen
    Get.snackbar(
      'Edit Evacuation Point',
      'Edit ${point.evacuationId}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Delete evacuation point
  void deleteEvacuationPoint(EvacuationPoint point) {
    try {
      evacuationPoints.removeWhere((p) => p.evacuationId == point.evacuationId);
      totalEvacuationPoints.value = evacuationPoints.length;
      
      Get.snackbar(
        'Success',
        'Evacuation point ${point.evacuationId} deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete evacuation point',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate to map view
  void navigateToMap() {
    // TODO: Navigate to map view
    Get.snackbar(
      'Map',
      'Navigate to map view',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Navigate to SOS reports
  void navigateToSosReports() {
    // TODO: Navigate to SOS reports
    Get.snackbar(
      'SOS Reports',
      'Navigate to SOS reports',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Logout functionality
  void logout() {
    // TODO: Implement logout logic
    Get.snackbar(
      'Logout',
      'Logout functionality',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}