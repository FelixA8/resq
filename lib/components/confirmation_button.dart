import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class ConfirmationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final String text; // Add text parameter

  static const theme = ResQTheme();

  const ConfirmationButton({
    super.key,
    required this.onPressed,
    required this.isEnabled,
    required this.text, // Require text parameter
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFB71C1C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text, // Use the text parameter
          style: TextStyle(
            fontSize: 16,
            fontWeight: theme.font.semibold,
            fontFamily: 'SF Pro',
          ),
        ),
      ),
    );
  }
}
