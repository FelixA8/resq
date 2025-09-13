import 'package:flutter/material.dart';

class ProgressBarSection extends StatelessWidget {
  const ProgressBarSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Image.asset(
            'assets/images/logos/resq-logo.png',
            height: 60,
          ),
        ),
        const SizedBox(height: 20),
        const LinearProgressIndicator(
          value: 0.33, // 1/3 progress
          backgroundColor: Colors.black38,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ],
    );
  }
}