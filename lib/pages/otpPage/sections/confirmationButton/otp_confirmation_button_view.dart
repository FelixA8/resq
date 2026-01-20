import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/confirmation_button.dart';
import 'otp_confirmation_button_view_model.dart';

class OTPConfirmationButtonView extends StatelessWidget {
  const OTPConfirmationButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OTPConfirmationButtonViewModel>(
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
