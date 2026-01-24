import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';

class ContactHelpDialog extends StatelessWidget {
  const ContactHelpDialog({super.key});

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
            // Main message
            const Text(
              'Kontak darurat yang Anda daftarkan akan secara otomatis menerima pesan SMS ketika Anda berada dalam situasi darurat (Fitur SOS aktif).',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),

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
        // Cancel Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                backgroundColor: theme.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Kembali',
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
        const SizedBox(width: 12),
      ],
    );
  }
}
