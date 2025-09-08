import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'otpViewModel.dart';
import 'sections/progressBarSection/progressBarView.dart';
import 'sections/otpInputSection/otpInputView.dart';
import 'sections/resendOtpSection/resendOtpView.dart';

class OTPView extends StatelessWidget {
  final String phoneNumber;

  const OTPView({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OTPViewModel()..initialize(phoneNumber),
      child: Scaffold(
        body: SafeArea(
          child: Consumer<OTPViewModel>(
            builder: (context, viewModel, child) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const ProgressBarSection(),
                        const SizedBox(height: 40),
                        OTPInputView(
                          phoneNumber: phoneNumber,
                          onOTPCompleted: (otp) async {
                            bool isValid = await viewModel.validateOTP(otp);
                            if (isValid) {
                              // TODO: Navigate to main page
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/main');
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                        ResendOTPSection(
                          timeLeft: viewModel.resendTimeLeft,
                          canResend: viewModel.canResendOTP,
                          onResendPressed: viewModel.resendOTP,
                        ),
                      ],
                    ),
                  ),
                  if (viewModel.isLoading)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (viewModel.errorMessage.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          viewModel.errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
