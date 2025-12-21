import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';

class EvacuationDeletedDialog extends StatelessWidget {
  const EvacuationDeletedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Poin Evakuasi Dihapus',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Main message
            const Text(
              'Poin evakuasi tujuan Anda sudah tidak aktif. Navigasi akan dihentikan.',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Build the action buttons row
  Widget _buildActionButtons() {
    const theme = ResQTheme();
    return Row(
      children: [
        // OK Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colors.primary,
            ),
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void show() {
    Get.dialog(
      const EvacuationDeletedDialog(),
      barrierDismissible: false,
    );
  }
}
