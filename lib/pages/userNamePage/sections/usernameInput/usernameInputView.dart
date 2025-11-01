import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../components/username_field.dart';
import 'usernameInputViewModel.dart';

class UsernameInputView extends StatelessWidget {
  const UsernameInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UsernameInputViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Nama Pengguna',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nama anda akan digunakan untuk mengidentifikasikan diri anda pada fitur-fitur aplikasi.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            UsernameField(
              value: viewModel.username,
              onChanged: viewModel.handleUsernameChanged,
              isValid: viewModel.isValid,
            ),
          ],
        );
      },
    );
  }
}
