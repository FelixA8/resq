import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';

class EmergencySettingsSaveButton extends StatelessWidget {
  final Function() onSave;

  const EmergencySettingsSaveButton({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: theme.colors.primary, // Use theme primary color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        minimumSize: const Size(0, 35),
      ),
      onPressed: onSave,
      child: const Text(
        'Simpan',
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}
