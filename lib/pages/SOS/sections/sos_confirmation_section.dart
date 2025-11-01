import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class SOSConfirmationSection extends StatelessWidget {
  const SOSConfirmationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Apakah Anda sedang dalam keadaan darurat?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF7B7B7D),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
