import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';

class ResponseTeamDashboardViewModel extends GetxController {
  final String instanceCode;

  final RxInt selectedIndex = 1.obs;

  ResponseTeamDashboardViewModel({required this.instanceCode});

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }

  // Get current address from the map view model
  RxString get currentAddress {
    if (Get.isRegistered<ResponseTeamMapViewModel>()) {
      final mapViewModel = Get.find<ResponseTeamMapViewModel>();
      return mapViewModel.currentAddress;
    }
    return 'Loading...'.obs;
  }
}

