import 'package:flutter/material.dart';
import '../components/back_button.dart';
import '../components/progress_bar.dart';

class ProgressBarSection extends StatelessWidget {
  final VoidCallback onBackPressed;

  const ProgressBarSection({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CustomBackButton(onPressed: onBackPressed),
            Expanded(
              child: Image.asset(
                'assets/images/Logo.png',
                height: 40,
              ),
            ),
            const SizedBox(width: 48), // To balance the back button
          ],
        ),
        const SizedBox(height: 16),
        const ProgressBar(progress: 0.67), // 2/3 progress
      ],
    );
  }
}
