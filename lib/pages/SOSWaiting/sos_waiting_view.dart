import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'sos_waiting_view_model.dart';
import 'sections/sos_waiting_header_section.dart';
import 'sections/sos_waiting_description_section.dart';
import 'sections/sos_waiting_timer_section.dart';
import 'sections/sos_waiting_illustration_section.dart';
import 'sections/sos_waiting_cancel_button_section.dart';
import '../userMap/user_map_view_model.dart';

class SOSWaitingView extends StatelessWidget {
  final SOSWaitingViewModel? viewModel;
  
  const SOSWaitingView({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Callback for when SOS is cancelled (isCurrent becomes false)
    void handleSOSCancellation() {
      // Reset SOS state in UserMapViewModel
      try {
        final userMapViewModel = Get.find<UserMapViewModel>();
        userMapViewModel.stopSOS();
      } catch (e) {
        print('⚠️ Could not find UserMapViewModel: $e');
      }
      
      // Exit the SOSWaitingView
      Navigator.of(context).pop();
    }

    // Use existing ViewModel if provided, otherwise create new one
    if (viewModel != null) {
      // Set callback on existing viewModel
      viewModel!.setSOSCancelledCallback(handleSOSCancellation);
      return ChangeNotifierProvider<SOSWaitingViewModel>.value(
        value: viewModel!,
        child: _SOSWaitingContent(),
      );
    } else {
      return ChangeNotifierProvider(
        create: (_) => SOSWaitingViewModel(
          onSOSCancelled: handleSOSCancellation,
        ),
        child: _SOSWaitingContent(),
      );
    }
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
    
    return Consumer<SOSWaitingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: spacing16),
                    SOSWaitingHeaderSection(
                      isResponseTeamAssigned: viewModel.isResponseTeamAssigned,
                    ),
                    SizedBox(height: spacing24),
                    SOSWaitingDescriptionSection(
                      isResponseTeamAssigned: viewModel.isResponseTeamAssigned,
                    ),
                    SizedBox(height: spacing32),
                    SOSWaitingTimerSection(),
                    SizedBox(height: spacing8),
                    SOSWaitingCancelButtonSection(),
                    Spacer(),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: spacing16,
                  child: SOSWaitingIllustrationSection(
                    isResponseTeamAssigned: viewModel.isResponseTeamAssigned,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
