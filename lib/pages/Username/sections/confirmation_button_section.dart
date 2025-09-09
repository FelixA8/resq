import 'package:flutter/material.dart';
import '../components/confirmation_button.dart';

class ConfirmationButtonSection extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isEnabled;

  const ConfirmationButtonSection({
    Key? key,
    required this.onConfirm,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ConfirmationButton(
        onPressed: onConfirm,
        isEnabled: isEnabled,
      ),
    );
  }
}
