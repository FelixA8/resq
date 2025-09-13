import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/back_button.dart';
import '../../components/progress_bar.dart';
import 'progressBarViewModel.dart';

class ProgressBarView extends StatelessWidget {
  const ProgressBarView({super.key});

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
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            Image.asset('assets/images/logos/resq-logo.png', height: 94),
            const SizedBox(height: 16),
            ProgressBar(progress: viewModel.progress),
          ],
        );
      },
    );
  }
}
