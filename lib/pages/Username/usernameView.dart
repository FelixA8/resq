import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'usernameViewModel.dart';
import 'sections/progress_bar_section.dart';
import 'sections/username_input_section.dart';
import 'sections/confirmation_button_section.dart';

class UsernameView extends StatelessWidget {
  const UsernameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsernameViewModel(),
      child: const UsernameScreen(),
    );
  }
}

class UsernameScreen extends StatelessWidget {
  const UsernameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<UsernameViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProgressBarSection(
                        onBackPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 32),
                      UsernameInputSection(
                        username: viewModel.username,
                        onUsernameChanged: viewModel.setUsername,
                        isValid: viewModel.isValid,
                      ),
                      const Spacer(),
                      ConfirmationButtonSection(
                        onConfirm: () async {
                          if (await viewModel.saveUsername()) {
                            // Navigate to next screen or show success message
                            if (context.mounted) {
                              // TODO: Navigate to next screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Username saved successfully!'),
                                ),
                              );
                            }
                          }
                        },
                        isEnabled: viewModel.isValid && !viewModel.isLoading,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
