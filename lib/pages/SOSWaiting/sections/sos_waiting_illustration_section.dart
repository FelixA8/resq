import 'package:flutter/material.dart';

class SOSWaitingIllustrationSection extends StatelessWidget {
  const SOSWaitingIllustrationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive height: 25-30% of screen height, but with constraints
    final illustrationHeight = (screenHeight * 0.25).clamp(100.0, 300.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Image.asset(
        'assets/images/illustrations/sos-running.png',
        height: illustrationHeight,
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}
