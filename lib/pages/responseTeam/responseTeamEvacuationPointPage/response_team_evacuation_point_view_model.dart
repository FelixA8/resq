import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/add_evacuation_point_view.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/components/evacuation_delete_dialog.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/theme/theme_app.dart';

class ResponseTeamEvacuationPointViewModel extends GetxController {
  final String instanceCode;
  final theme = ResQTheme();

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

  Future<void> _loadEvacuationPoints() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await SupabaseService.getEvacuationPoints();
      evacuationPoints.value = response;
      totalEvacuationPoints.value = response.length;
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';

      if (isLoading.value) {
        Get.snackbar(
          'Error',
          'Gagal memuat poin evakuasi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.colors.primary,
          colorText: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _loadEvacuationPoints();
  }

  void addEvacuationPoint() async {
    final result = await Get.to(() => const AddEvacuationPointView());

    if (result == true) {
      await refreshData();
    }
  }

  void editEvacuationPoint(EvacuationPoint point) async {
    final result = await Get.to(
      () => AddEvacuationPointView(
        instanceCode: instanceCode,
        existingEvacuationPoint: point,
      ),
    );

    if (result == true) {
      await refreshData();
    }
  }

  void deleteEvacuationPoint(EvacuationPoint point) {
    EvacuationDeleteDialog.show(
      evacuationPoint: point,
      onConfirmDelete: () => _performDelete(point),
    );
  }

  Future<void> _performDelete(EvacuationPoint point) async {
    try {
      isLoading.value = true;

      final success = await SupabaseService.deleteEvacuationPoint(
        point.evacuationId!,
      );

      if (success) {
        evacuationPoints.removeWhere(
          (p) => p.evacuationId == point.evacuationId,
        );
        totalEvacuationPoints.value = evacuationPoints.length;

        Get.snackbar(
          'Berhasil',
          'Poin evakuasi berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.colors.primary,
          colorText: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Gagal menghapus poin evakuasi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.colors.primary,
          colorText: Colors.white,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
