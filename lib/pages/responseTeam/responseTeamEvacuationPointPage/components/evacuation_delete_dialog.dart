import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/theme/theme_app.dart';

class EvacuationDeleteDialog extends StatelessWidget {
  final EvacuationPoint evacuationPoint;
  final VoidCallback onConfirmDelete;

  const EvacuationDeleteDialog({
    super.key,
    required this.evacuationPoint,
    required this.onConfirmDelete,
  });

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
            // Warning Icon
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
              'Hapus Poin Evakuasi',
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
              'Apakah Anda yakin ingin menghapus poin evakuasi ini?',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Location Details Card
            if (_hasLocationDetails()) _buildLocationDetailsCard(),

            if (_hasLocationDetails()) const SizedBox(height: 20),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Check if evacuation point has location details to display
  bool _hasLocationDetails() {
    return (evacuationPoint.locationDetail != null &&
            evacuationPoint.locationDetail!.isNotEmpty) ||
        (evacuationPoint.city != null && evacuationPoint.city!.isNotEmpty);
  }

  /// Build the location details card
  Widget _buildLocationDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              const Text(
                'Detail Lokasi',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (evacuationPoint.locationDetail != null &&
              evacuationPoint.locationDetail!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                evacuationPoint.locationDetail!,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          if (evacuationPoint.city != null && evacuationPoint.city!.isNotEmpty)
            Row(
              children: [
                Icon(
                  Icons.location_city_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  evacuationPoint.city!,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
        ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Delete Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colors.primary,
            ),
            child: TextButton(
              onPressed: () {
                Get.back();
                onConfirmDelete();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Hapus',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Static method to show the dialog
  static void show({
    required EvacuationPoint evacuationPoint,
    required VoidCallback onConfirmDelete,
  }) {
    Get.dialog(
      EvacuationDeleteDialog(
        evacuationPoint: evacuationPoint,
        onConfirmDelete: onConfirmDelete,
      ),
      barrierDismissible: false,
    );
  }
}
