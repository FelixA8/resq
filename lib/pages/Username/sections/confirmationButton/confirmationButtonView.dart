import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/confirmationButton.dart';
import 'confirmationButtonViewModel.dart';

class ConfirmationButtonView extends StatelessWidget {
  const ConfirmationButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfirmationButtonViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: ConfirmationButton(
            onPressed:
                viewModel.isEnabled
                    ? () => viewModel.handleConfirm(context)
                    : () {},
            isEnabled: viewModel.isEnabled,
            text: 'Konfirmasi',
          ),
        );
      },
    );
  }
}
