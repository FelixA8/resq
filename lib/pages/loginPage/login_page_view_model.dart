import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  bool isResponseTeam = false;
  final FocusNode phoneFocus = FocusNode();

  String? phoneError;

  void toggleResponseTeam() {
    isResponseTeam = !isResponseTeam;
    notifyListeners();
  }

  void submitCredential(BuildContext context) {
    final phone = phoneController.text;
    
    if (validateUser()) {
      phoneError = null;
      notifyListeners();
      Navigator.pushNamed(
        context,
        '/otpView',
        arguments: {
          'phone': phone,
          'isResponseTeam': isResponseTeam,
        },
      );
    } else {
      phoneError = 'Nomor telepon harus numerik dan 10 - 15 angka';
      notifyListeners();
    }
  }

  bool validateUser() {
    final phone = phoneController.text;
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(phone);

    if (phone.isNotEmpty && isNumeric && phone.length >= 10 && phone.length <= 15) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocus.dispose();
    super.dispose();
  }
}
