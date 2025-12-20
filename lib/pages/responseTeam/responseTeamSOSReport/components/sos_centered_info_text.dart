import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class SosCenteredInfoText extends StatelessWidget {
  final String text;
  const SosCenteredInfoText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: theme.font.semibold,
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }
}
