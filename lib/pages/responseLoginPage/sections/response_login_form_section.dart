import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/components/confirmation_button.dart';
import 'package:resqapp/pages/responseLoginPage/response_login_page_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';

class ResponseLoginFormSection extends StatelessWidget {
  const ResponseLoginFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ResponseLoginPageViewModel>();
    var theme = ResQTheme();

    final isPasswordVisible = false.obs;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: theme.padding.m),
      padding: EdgeInsets.all(theme.padding.l),
      decoration: BoxDecoration(
        color: theme.colors.neutral.light,
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
              fontSize: 15,
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
                fontSize: 13,
                color: Color(0xFF9E9E9E),
              ),
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
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
              fontSize: 16,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Obx(
            () => TextField(
              controller: viewModel.passwordController,
              obscureText: !isPasswordVisible.value,
              decoration: InputDecoration(
                hintText: 'Masukkan kata sandi instansi Anda',
                hintStyle: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                ),
                filled: true,
                fillColor: const Color(0xFFD9D9D9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey[700],
                  ),
                  onPressed: () {
                    isPasswordVisible.value = !isPasswordVisible.value;
                  },
                ),
              ),
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 60),

          Obx(
            () => ConfirmationButton(
              onPressed: () {
                if (viewModel.isLoading.value) return;
                FocusScope.of(context).unfocus();
                viewModel.submitLoginCredential();
              },
              isEnabled: !viewModel.isLoading.value,
              text: viewModel.isLoading.value ? 'Memproses...' : 'Masuk',
            ),
          ),
        ],
      ),
    );
  }
}
