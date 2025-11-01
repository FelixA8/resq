import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/service/login_service.dart';
import 'package:resqapp/services/supabase_service.dart';

class ResponseLoginPageViewModel extends GetxController {
  // Controllers
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Reactive state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  bool get isFormValid => 
      codeController.text.trim().isNotEmpty && 
      passwordController.text.isNotEmpty;

  /// Handle login authentication
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
      final user = await LoginService().responseTeamLogin(
        code, password
      );

      if (user == null) {
        _showErrorSnackbar('Kode instansi atau kata sandi salah');
        isLoading.value = false;
        return;
      }
      _showSuccessSnackbar('Berhasil masuk sebagai response team');
      
      Get.offNamed('/usermapview');
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

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    codeController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
