import 'package:flutter/material.dart';

class ResponseLoginPageViewModel extends ChangeNotifier {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleLogin(BuildContext context) {
    // TODO: Implement actual login logic
    if (codeController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }
    // Navigate or handle login success here
  }

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
