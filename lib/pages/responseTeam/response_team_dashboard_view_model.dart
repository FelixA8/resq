import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/loginPage/login_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponseTeamDashboardViewModel extends GetxController {
  final String instanceCode;

  final RxInt selectedIndex = 1.obs;

  ResponseTeamDashboardViewModel({required this.instanceCode});

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    Get.offAll(LoginPageView());
  }
}