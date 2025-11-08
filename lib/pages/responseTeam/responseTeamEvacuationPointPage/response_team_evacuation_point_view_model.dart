import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/add_evacuation_point_view.dart';

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
      
      // TODO: Replace with actual API call to fetch evacuation points
      // For now, using mock data based on Figma design
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
      
      final mockData = _generateMockEvacuationPoints();
      evacuationPoints.value = mockData;
      totalEvacuationPoints.value = mockData.length;
      
    } catch (e) {
      errorMessage.value = 'Failed to load evacuation points: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to load evacuation points',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate mock evacuation points based on Figma design
  List<EvacuationPoint> _generateMockEvacuationPoints() {
    return [
      
    ];
  }

  /// Refresh evacuation points data
  Future<void> refreshData() async {
    await _loadEvacuationPoints();
  }

  /// Add new evacuation point
  void addEvacuationPoint() {
    Get.to(AddEvacuationPointView());
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