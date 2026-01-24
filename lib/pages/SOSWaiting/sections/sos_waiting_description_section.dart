import 'package:flutter/material.dart';

class SOSWaitingDescriptionSection extends StatelessWidget {
  final bool isResponseTeamAssigned;

  const SOSWaitingDescriptionSection({
    super.key,
    this.isResponseTeamAssigned = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.1;
    final responsiveFontSize = screenWidth * 0.037;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.clamp(16.0, 40.0),
      ),
      child: Text(
        isResponseTeamAssigned
            ? 'Response team telah menerima sinyal SOS Anda dan sedang dalam perjalanan menuju lokasi. Tetap tenang dan berada di tempat aman, bantuan akan segera tiba untuk memastikan keselamatan Anda.'
            : 'Sinyal SOS Anda telah berhasil dikirim ke pihak berwajib dan kontak darurat terdaftar. Tim penyelamat sedang menuju lokasi Anda, tetap tenang, jaga keselamatan diri, dan tunggu bantuan datang dalam waktu dekat.',
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
