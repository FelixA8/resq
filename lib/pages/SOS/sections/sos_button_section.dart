import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/components/radiant_circle_button.dart';

class SOSButtonSection extends StatelessWidget {
  final VoidCallback onPressed;
  const SOSButtonSection({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive font size for SOS button text
    final responsiveFontSize = (screenWidth * 0.12).clamp(36.0, 50.0);
    
    return RadiantCircleButton(
      mainColor: Color(theme.colors.primary),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'SOS',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w900,
            fontSize: responsiveFontSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
