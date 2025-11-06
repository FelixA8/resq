import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sos_waiting_view_model.dart';
import 'sections/sos_waiting_header_section.dart';
import 'sections/sos_waiting_description_section.dart';
import 'sections/sos_waiting_timer_section.dart';
import 'sections/sos_waiting_illustration_section.dart';
import 'sections/sos_waiting_cancel_button_section.dart';

class SOSWaitingView extends StatelessWidget {
  final SOSWaitingViewModel? viewModel;
  
  const SOSWaitingView({Key? key, this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use existing ViewModel if provided, otherwise create new one
    return viewModel != null
        ? ChangeNotifierProvider<SOSWaitingViewModel>.value(
            value: viewModel!,
            child: _SOSWaitingContent(),
          )
        : ChangeNotifierProvider(
            create: (_) => SOSWaitingViewModel(),
            child: _SOSWaitingContent(),
          );
  }
}

class _SOSWaitingContent extends StatelessWidget {
  const _SOSWaitingContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive spacing based on screen height
    final spacing8 = screenHeight * 0.01;
    final spacing16 = screenHeight * 0.02;
    final spacing24 = screenHeight * 0.03;
    final spacing32 = screenHeight * 0.04;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content column
            Column(
              children: [
                SizedBox(height: spacing16),
                const SOSWaitingHeaderSection(),
                SizedBox(height: spacing24),
                const SOSWaitingDescriptionSection(),
                SizedBox(height: spacing32),
                // Timer section
                SOSWaitingTimerSection(),
                SizedBox(height: spacing8),
                SOSWaitingCancelButtonSection(),
                // Spacer to push illustration down
                Spacer(),
              ],
            ),
            // Illustration positioned at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: spacing16,
              child: const SOSWaitingIllustrationSection(),
            ),
          ],
        ),
      ),
    );
  }
}
