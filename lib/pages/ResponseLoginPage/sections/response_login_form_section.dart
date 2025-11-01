import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseLoginPage/response_login_page_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';
import '../../../components/confirmation_button.dart';

class ResponseLoginFormSection extends StatelessWidget {
  const ResponseLoginFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ResponseLoginPageViewModel>();
    var theme = ResQTheme();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: theme.padding.m),
      padding: EdgeInsets.all(theme.padding.l),
      decoration: BoxDecoration(
        color: Color(theme.colors.neutral.light),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kode Instansi',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.codeController,
            decoration: InputDecoration(
              hintText: 'Masukkan kode instansi Anda',
              hintStyle: const TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color(0xFF9E9E9E),
              ),
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Kata Sandi',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Masukkan kata sandi instansi Anda',
              hintStyle: const TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color(0xFF9E9E9E),
              ),
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 60),

          Obx(() => ConfirmationButton(
                onPressed: () {
                  if (viewModel.isLoading.value) return;
                  FocusScope.of(context).unfocus();
                  viewModel.handleLogin();
                },
                isEnabled: !viewModel.isLoading.value,
                text: viewModel.isLoading.value ? 'Memproses...' : 'Masuk',
              )),
        ],
      ),
    );
  }
}
