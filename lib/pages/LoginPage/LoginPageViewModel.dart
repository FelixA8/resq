import 'package:flutter/material.dart';

class LoginPageViewModel extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  bool isResponseTeam = false;

  void toggleResponseTeam() {
    isResponseTeam = !isResponseTeam;
    notifyListeners();
  }

  void handleSendOTP(BuildContext context) {
    if (phoneController.text.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/otpView',
        arguments: {
          'phone': phoneController.text,
          'isResponseTeam': isResponseTeam,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
