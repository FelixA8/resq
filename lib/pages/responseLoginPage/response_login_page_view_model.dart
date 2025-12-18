import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/response_team_dashboard_view.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponseLoginPageViewModel extends GetxController {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isFormValid =>
      codeController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty;

  Future<void> handleLogin() async {
    final code = codeController.text.trim();
    final password = passwordController.text;

    if (code.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Semua field harus diisi');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await SupabaseService.loginResponseTeam(code, password);
      if (user == null) {
        _showErrorSnackbar('Kode instansi atau kata sandi salah');
        isLoading.value = false;
        return;
      }

      await _saveInstanceCode(code);

      Get.off(() => ResponseTeamDashboardView(instanceCode: code));
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan saat masuk. Silakan coba lagi.');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xFFB71C1C),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _saveInstanceCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('instanceCode', code);
  }

  static Future<String?> getSavedInstanceCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('instanceCode');
  }

  @override
  void onClose() {
    codeController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
