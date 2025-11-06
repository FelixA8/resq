import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseLoginPage/response_login_page_view_model.dart';
import 'package:resqapp/pages/responseTeam/response_team_dashboard_view.dart';
import 'package:resqapp/pages/loginPage/login_page_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Add a small delay for better UX (optional)
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if there's a saved instanceCode
    final savedInstanceCode =
        await ResponseLoginPageViewModel.getSavedInstanceCode();

    if (savedInstanceCode != null && savedInstanceCode.isNotEmpty) {
      // Navigate to Response Team Dashboard if instanceCode exists
      Get.off(
        () => ResponseTeamDashboardView(instanceCode: savedInstanceCode),
        transition: Transition.fadeIn,
      );
    } else {
      // Navigate to Login Page if no instanceCode exists
      Get.off(
        () => const LoginPageView(),
        transition: Transition.fadeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your app logo here
            Image.asset(
              'assets/images/logos/resq-logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
            ),
          ],
        ),
      ),
    );
  }
}

