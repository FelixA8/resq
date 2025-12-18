import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class LoginPageViewModel extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  bool isResponseTeam = false;
  final FocusNode phoneFocus = FocusNode();
  final theme = ResQTheme();

  String? phoneError;

  void toggleResponseTeam() {
    isResponseTeam = !isResponseTeam;
    notifyListeners();
  }

  void validate(BuildContext context) {
    final phone = phoneController.text;
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(phone);

    if (phone.isNotEmpty && isNumeric && phone.length >= 12 && phone.length <= 15) {
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
      phoneError = 'Nomor telepon harus numerik dan 12 - 15 angka';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocus.dispose();
    super.dispose();
  }
}
