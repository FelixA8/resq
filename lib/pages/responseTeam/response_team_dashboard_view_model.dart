import 'package:get/get.dart';

class ResponseTeamDashboardViewModel extends GetxController {
  final String instanceCode;

  final RxInt selectedIndex = 1.obs;

  ResponseTeamDashboardViewModel({required this.instanceCode});

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }
}

