import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class ReportCardButton extends StatelessWidget {
  final bool isAssigned;
  final String? assignedUnitId;
  final VoidCallback? onPressed;

  const ReportCardButton({
    super.key,
    required this.isAssigned,
    this.assignedUnitId,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();

    if (isAssigned) {
      return ElevatedButton(
        onPressed: null,
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
          'Ditangani oleh Unit ${assignedUnitId?.substring(0, 5)}',
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      );
    } else {
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
        icon: const Icon(Icons.map, size: 16),
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
