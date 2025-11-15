import 'package:flutter/material.dart';
import '../../models/otp_model.dart';

class OTPInputViewModel extends ChangeNotifier {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String) onOTPCompleted;

  OTPInputViewModel({required this.onOTPCompleted})
      : controllers = List.generate(OTPModel.otpLength, (index) => TextEditingController()),
        focusNodes = List.generate(OTPModel.otpLength, (index) => FocusNode());

  void onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < OTPModel.otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    // Check if all digits are filled
    String otp = controllers.map((c) => c.text).join();
    if (otp.length == OTPModel.otpLength) {
      onOTPCompleted(otp);
    }
  }

  void clearInput() {
    for (var controller in controllers) {
      controller.clear();
    }
    focusNodes.first.requestFocus();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
