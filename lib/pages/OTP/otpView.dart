import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'otpViewModel.dart';
import 'sections/progressBarSection/progressBarView.dart';
import 'sections/progressBarSection/progressBarViewModel.dart';
import 'sections/otpInputSection/otpInputView.dart';
import 'sections/resendOtpSection/resendOtpView.dart';
import '../Username/usernameView.dart';

class OTPView extends StatelessWidget {
  final String phoneNumber;

  const OTPView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OTPViewModel()..initialize(phoneNumber),
        ),
        ChangeNotifierProvider(
          create:
              (context) =>
                  ProgressBarViewModel()
                    ..setOnBackPressed(() => Navigator.of(context).pop()),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: ProgressBarSection(),
              ),
              Expanded(
                child: Consumer<OTPViewModel>(
                  builder: (context, viewModel, child) {
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              OTPInputView(
                                phoneNumber: phoneNumber,
                                onOTPCompleted: (otp) {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const UsernameView(),
                                      ),
                                    );
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
            ],
          ),
        ),
      ),
    );
  }
}
