import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/components/logout_confirmation_dialog.dart';
import 'package:resqapp/pages/settings/settings_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';

class LogoutSection extends StatefulWidget {
  const LogoutSection({super.key});

  @override
  State<LogoutSection> createState() => _LogoutSectionState();
}

class _LogoutSectionState extends State<LogoutSection> {
  final theme = ResQTheme();
  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<SettingsViewModel>();

    return GestureDetector(
      onTap: () async {
        Get.dialog(
          LogoutConfirmationDialog(
            onConfirm: () {
              viewModel.logoutUser();
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opsi Lainnya',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Keluar akun',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: theme.colors.primary,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/icons/logout.png', // Use your signout icon asset
                    width: 22,
                    height: 22,
                    color: theme.colors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
