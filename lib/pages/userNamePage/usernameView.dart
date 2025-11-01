import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'usernameViewModel.dart';
import 'sections/progressBarSection/progressBarView.dart';
import 'sections/progressBarSection/progressBarViewModel.dart';
import 'sections/usernameInput/usernameInputView.dart';
import 'sections/usernameInput/usernameInputViewModel.dart';
import 'sections/confirmationButton/confirmationButtonView.dart';
import 'sections/confirmationButton/confirmationButtonViewModel.dart';

class UsernameView extends StatelessWidget {
  const UsernameView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsernameViewModel(),
      child: const UsernameScreen(),
    );
  }
}

class UsernameScreen extends StatelessWidget {
  const UsernameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<UsernameViewModel>(
          builder: (context, mainViewModel, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create:
                      (context) =>
                          ProgressBarViewModel()..setOnBackPressed(
                            () => Navigator.of(context).pop(),
                          ),
                ),
                ChangeNotifierProvider(
                  create:
                      (context) =>
                          UsernameInputViewModel()
                            ..setMainViewModel(mainViewModel),
                ),
                ChangeNotifierProvider(
                  create:
                      (context) =>
                          ConfirmationButtonViewModel()
                            ..setUsernameViewModel(mainViewModel),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const ProgressBarView(),
                    const SizedBox(height: 32),
                    const UsernameInputView(),
                    const Spacer(),
                    const ConfirmationButtonView(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
