import 'package:flutter/material.dart';

class SOSWaitingDescriptionSection extends StatelessWidget {
  const SOSWaitingDescriptionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive padding: 10% of screen width, but with min/max constraints
    final horizontalPadding = screenWidth * 0.1;
    final responsiveFontSize = screenWidth * 0.037; // Scales with screen width
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.clamp(16.0, 40.0),
      ),
      child: Text(
        'Sinyal SOS Anda telah berhasil dikirim ke pihak berwajib dan kontak darurat terdaftar. Tim penyelamat sedang menuju lokasi Anda, tetap tenang, jaga keselamatan diri, dan tunggu bantuan datang dalam waktu dekat.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: responsiveFontSize.clamp(13.0, 15.0),
          height: 1.2,
        ),
      ),
    );
  }
}
