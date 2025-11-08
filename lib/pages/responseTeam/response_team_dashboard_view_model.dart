import 'package:get/get.dart';

class ResponseTeamDashboardViewModel extends GetxController {
  final String instanceCode;
  
  // Observable state for selected index
  final RxInt selectedIndex = 1.obs; // Start with map view (index 1)

  ResponseTeamDashboardViewModel({required this.instanceCode});

  /// Change the selected tab
  void onTabChanged(int index) {
    selectedIndex.value = index;
  }
}

