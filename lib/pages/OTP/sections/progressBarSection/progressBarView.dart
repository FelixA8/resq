import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqapp/pages/Username/components/back_button.dart';
import 'package:resqapp/pages/Username/components/progress_bar.dart';
import 'progressBarViewModel.dart';

class ProgressBarSection extends StatelessWidget {
  const ProgressBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressBarViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Row(
              children: [
                CustomBackButton(onPressed: viewModel.handleBackPressed),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Image.asset('assets/images/logos/resq-logo.png', height: 60),
            const SizedBox(height: 10),
            ProgressBar(progress: viewModel.progress),
          ],
        );
      },
    );
  }
}
