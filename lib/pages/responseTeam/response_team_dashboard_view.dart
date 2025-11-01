import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/response_team_dashboard_view_model.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPoint/response_team_evacuation_point_view.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view.dart';
import 'package:resqapp/pages/responseTeam/responseTeamSOSReport/response_team_sos_report_view.dart';
import 'package:resqapp/pages/responseLoginPage/response_login_page_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';

class ResponseTeamDashboardView
    extends GetView<ResponseTeamDashboardViewModel> {
  final String instanceCode;

  const ResponseTeamDashboardView({super.key, required this.instanceCode});

  static const theme = ResQTheme();

  @override
  Widget build(BuildContext context) {
    // Register the controller if not already registered
    if (!Get.isRegistered<ResponseTeamDashboardViewModel>()) {
      Get.put(ResponseTeamDashboardViewModel(instanceCode: instanceCode));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              instanceCode,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/icons/annotation-app-bar.png',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  'Tangerang Selatan',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Color(theme.colors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Settings button (white rounded square)
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(35, 35),
                      maximumSize: Size(35, 35),
                    ),
                    onPressed: () async {
                      // Clear saved instanceCode from shared preferences
                      await ResponseLoginPageViewModel.clearInstanceCode();
                      // Navigate back to login page
                      Get.offAllNamed('/responseLogin');
                    },
                    child: Image.asset(
                      'assets/images/icons/logout.png',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Switch between views based on selected index
        switch (controller.selectedIndex.value) {
          case 0:
            return const ResponseTeamEvacuationPointView();
          case 1:
            return ResponseTeamMapView(instanceCode: instanceCode);
          case 2:
            return const ResponseTeamSOSReportView();
          default:
            return ResponseTeamMapView(instanceCode: instanceCode);
        }
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.onTabChanged,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Color(theme.colors.primary),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    'assets/images/icons/navbar-evacuation-point-red.png',
                    width: 24,
                    height: 24,
                    color:
                        controller.selectedIndex.value == 0
                            ? Color(theme.colors.primary)
                            : Colors.grey,
                  ),
                ),
                label: 'Poin Evakuasi',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    'assets/images/icons/navbar-map-red.png',
                    width: 24,
                    height: 24,
                    color:
                        controller.selectedIndex.value == 1
                            ? Color(theme.colors.primary)
                            : Colors.grey,
                  ),
                ),
                label: 'Peta',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    'assets/images/icons/sos-gray.png',
                    width: 24,
                    height: 24,
                    color:
                        controller.selectedIndex.value == 2
                            ? Color(theme.colors.primary)
                            : Colors.grey,
                  ),
                ),
                label: 'Peta',
              ),
            ],
          ),
        );
      }),
    );
  }
}
