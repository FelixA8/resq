import 'package:flutter/material.dart';

class SOSConfirmationSection extends StatelessWidget {
  const SOSConfirmationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive padding: 10% of screen width with constraints
    final horizontalPadding = (screenWidth * 0.1).clamp(20.0, 40.0);
    final verticalPadding = screenHeight * 0.01;
    
    // Responsive font size
    final responsiveFontSize = (screenWidth * 0.05).clamp(16.0, 20.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Apakah Anda sedang dalam keadaan darurat?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: responsiveFontSize,
              color: Color(0xFF7B7B7D),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
