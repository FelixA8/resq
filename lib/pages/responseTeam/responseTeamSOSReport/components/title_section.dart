import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {
  const TitleSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Daftar Laporan SOS',
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

