import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';

class LocationDisabledDialog extends StatefulWidget {
  final Future<bool> Function() onRetry;

  const LocationDisabledDialog({Key? key, required this.onRetry})
    : super(key: key);

  @override
  State<LocationDisabledDialog> createState() => _LocationDisabledDialogState();
}

class _LocationDisabledDialogState extends State<LocationDisabledDialog> {
  Future<void> _handleRetry() async {
    final success = await widget.onRetry();

    if (success) {
      Get.back();
    }
  }

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
                Icons.location_off_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Layanan Lokasi Nonaktif',
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
              'Untuk menggunakan fitur ini, mohon aktifkan layanan lokasi pada perangkat Anda.',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Action Button
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  /// Build the action button
  Widget _buildActionButton() {
    const theme = ResQTheme();
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colors.primary,
      ),
      child: TextButton(
        onPressed: _handleRetry,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: theme.colors.primary,
        ),
        child: const Text(
          'Coba Lagi / Refresh',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
