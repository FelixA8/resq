import 'package:flutter/material.dart';
import '../../models/otp_model.dart';

class OTPInputViewModel extends ChangeNotifier {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String) onOTPCompleted;

  OTPInputViewModel({required this.onOTPCompleted})
      : controllers = List.generate(OTPModel.otpLength, (index) => TextEditingController()),
        focusNodes = List.generate(OTPModel.otpLength, (index) => FocusNode());

  // otp_input_view_model.dart

void onDigitChanged(int index, String value) {
  // If a digit was entered (value is not empty)
  if (value.isNotEmpty) {
    // 1. Move to the next box if not at the end
    if (index < OTPModel.otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }
  }

  // 2. Collect the full OTP string
  String otp = controllers.map((c) => c.text).join();
  
  // 3. If the OTP is complete, trigger the callback
  if (otp.length == OTPModel.otpLength) {
    onOTPCompleted(otp);
  }
}

  void onBackspacePrevious(int index) {
    if (index > 0) {
      controllers[index - 1].clear();
      focusNodes[index - 1].requestFocus();
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
