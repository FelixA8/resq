import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

/// Dynamic button component for SOS report cards
/// Can be either red (with icon) or grey (with text)
class ReportCardButton extends StatelessWidget {
  final bool isAssigned;
  final String? assignedUnitId;
  final VoidCallback? onPressed;

  const ReportCardButton({
    Key? key,
    required this.isAssigned,
    this.assignedUnitId,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();

    if (isAssigned) {
      // Grey button showing assigned unit
      return ElevatedButton(
        onPressed: null, // Disabled when assigned
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: Text(
          'Ditangani oleh Unit $assignedUnitId',
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      );
    } else {
      // Red button with icon for viewing on map
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        icon: const Icon(
          Icons.map,
          size: 16,
        ),
        label: const Text(
          'Lihat Pada Peta',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      );
    }
  }
}

