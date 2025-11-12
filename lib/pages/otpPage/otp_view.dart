import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'otp_view_model.dart';
import 'sections/progressBarSection/progress_bar_view.dart';
import 'sections/progressBarSection/progress_bar_view_model.dart';
import 'sections/otpInputSection/otp_input_view.dart';
import 'sections/resendOtpSection/resend_otp_view.dart';
import 'sections/usernameInput/usernameInputView.dart';
import 'sections/usernameInput/usernameInputViewModel.dart';
import 'sections/confirmationButton/confirmationButtonView.dart';
import 'sections/confirmationButton/confirmationButtonViewModel.dart';
import '../userMap/user_map_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPView extends StatelessWidget {
  final String phoneNumber;

  const OTPView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = OTPViewModel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.initialize(phoneNumber);
        });
        return viewModel;
      },
      child: const OTPScreen(),
    );
  }
}

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OTPViewModel>(
      builder: (context, otpViewModel, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create:
                  (context) =>
                      ProgressBarViewModel()
                        ..setOnBackPressed(() => Navigator.of(context).pop())
                        ..setOTPViewModel(otpViewModel),
            ),
            ChangeNotifierProvider(
              create:
                  (context) =>
                      UsernameInputViewModel()..setMainViewModel(otpViewModel),
            ),
            ChangeNotifierProvider(
              create:
                  (context) =>
                      ConfirmationButtonViewModel()
                        ..setOTPViewModel(otpViewModel),
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
                    child: Stack(
                      children: [
                        if (otpViewModel.currentState == ViewState.otpInput)
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                OTPInputView(
                                  phoneNumber:
                                      otpViewModel.otpModel?.phoneNumber ?? '',
                                  onOTPCompleted: (otp) {
                                    otpViewModel.validateOTP(otp);
                                  },
                                ),
                                const SizedBox(height: 40),
                                ResendOTPSection(
                                  timeLeft: otpViewModel.resendTimeLeft,
                                  canResend: otpViewModel.canResendOTP,
                                  onResendPressed: otpViewModel.resendOTP,
                                ),
                              ],
                            ),
                          )
                        else if (otpViewModel.currentState ==
                            ViewState.usernameInput)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                const UsernameInputView(),
                                const Spacer(),
                                const ConfirmationButtonView(),
                              ],
                            ),
                          )
                        else if (otpViewModel.currentState ==
                            ViewState.authenticated)
                          // Navigate to UserMapView when authenticated
                          Builder(
                            builder: (context) {
                              // Save userId to SharedPreferences and navigate
                              WidgetsBinding.instance.addPostFrameCallback((
                                _,
                              ) async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                bool isSaved = await prefs.setString(
                                  'userId',
                                  otpViewModel.userId,
                                );

                                if (isSaved) {
                                  print(
                                    '✅ userId successfully saved to SharedPreferences: ${otpViewModel.userId}',
                                  );
                                } else {
                                  print(
                                    '❌ Failed to save userId to SharedPreferences.',
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UserMapView(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              });
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        if (otpViewModel.isLoading)
                          Container(
                            color: Colors.black26,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (otpViewModel.errorMessage.isNotEmpty)
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
                                otpViewModel.errorMessage,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
