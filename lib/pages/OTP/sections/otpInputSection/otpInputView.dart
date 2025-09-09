import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/otp_input_box.dart';
import '../../models/otp_model.dart';
import 'otpInputViewModel.dart';

class OTPInputView extends StatelessWidget {
  final String phoneNumber;
  final Function(String) onOTPCompleted;

  const OTPInputView({
    Key? key,
    required this.phoneNumber,
    required this.onOTPCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OTPInputViewModel(onOTPCompleted: onOTPCompleted),
      child: Consumer<OTPInputViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              const Text(
                'Verifikasi Nomor Anda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan kode OTP yang telah dikirimkan\nkepada anda melalui pesan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  OTPModel.otpLength,
                  (index) => OTPInputBox(
                    controller: viewModel.controllers[index],
                    focusNode: viewModel.focusNodes[index],
                    autoFocus: index == 0,
                    onChanged: (value) => viewModel.onDigitChanged(index, value),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}