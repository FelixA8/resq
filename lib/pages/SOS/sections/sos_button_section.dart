import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/components/radiant_circle_button.dart';

class SOSButtonSection extends StatelessWidget {
  final VoidCallback onPressed;
  const SOSButtonSection({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    return RadiantCircleButton(
      mainColor: Color(theme.colors.primary),
      onPressed: onPressed,
      child: Text(
        'SOS',
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w900,
          fontSize: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}
