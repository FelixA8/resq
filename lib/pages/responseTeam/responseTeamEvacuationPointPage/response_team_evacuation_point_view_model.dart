import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/add_evacuation_point_view.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/components/evacuation_delete_dialog.dart';
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
      
      final response = await SupabaseService.getEvacuationPoints();
      evacuationPoints.value = response;
      totalEvacuationPoints.value = response.length;
      
      print('Loaded ${response.length} evacuation points');
      
    } catch (e) {
      print('Error loading evacuation points: $e');
      errorMessage.value = 'Error: ${e.toString()}';
      
      // Only show snackbar if this is not a silent refresh
      if (isLoading.value) {
        Get.snackbar(
          'Error',
          'Gagal memuat poin evakuasi',
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
    print('Refreshing evacuation points data');
    await _loadEvacuationPoints();
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
  void editEvacuationPoint(EvacuationPoint point) async {
    final result = await Get.to(() => AddEvacuationPointView(
      instanceCode: instanceCode,
      existingEvacuationPoint: point,
    ));
    
    // If result is true, it means the evacuation point was updated successfully
    if (result == true) {
      print('Refreshing evacuation points after successful edit');
      await refreshData();
    }
  }

  /// Delete evacuation point with confirmation dialog
  void deleteEvacuationPoint(EvacuationPoint point) {
    EvacuationDeleteDialog.show(
      evacuationPoint: point,
      onConfirmDelete: () => _performDelete(point),
    );
  }

  /// Perform the actual deletion
  Future<void> _performDelete(EvacuationPoint point) async {
    try {
      isLoading.value = true;
      
      final success = await SupabaseService.deleteEvacuationPoint(point.evacuationId!);
      
      if (success) {
        // Remove from local list
        evacuationPoints.removeWhere((p) => p.evacuationId == point.evacuationId);
        totalEvacuationPoints.value = evacuationPoints.length;
        
        Get.snackbar(
          'Berhasil',
          'Poin evakuasi berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        print('Successfully deleted evacuation point: ${point.evacuationId}');
      } else {
        Get.snackbar(
          'Error',
          'Gagal menghapus poin evakuasi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting evacuation point: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}