import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sos_view_model.dart';
import 'sections/sos_confirmation_section.dart';
import 'sections/sos_button_section.dart';
import '../SOSWaiting/sos_waiting_view.dart';
import '../SOSWaiting/sos_waiting_view_model.dart';
import '../userMap/userMapViewModel.dart';

class SOSView extends StatelessWidget {
  const SOSView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive spacing based on screen height
    final spacing8 = screenHeight * 0.01;
    final spacing12 = screenHeight * 0.015;
    final spacing15 = screenHeight * 0.018;
    final spacing32 = screenHeight * 0.04;
    
    // Responsive handle bar width
    final handleBarWidth = (screenWidth * 0.11).clamp(35.0, 45.0);
    
    return ChangeNotifierProvider(
      create: (_) => SOSViewModel(),
      child: Consumer<SOSViewModel>(
        builder: (context, viewModel, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: spacing12),
                  Container(
                    width: handleBarWidth,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: spacing15),
                  SOSConfirmationSection(),
                  SizedBox(height: spacing8),
                  SOSButtonSection(
                    onPressed: () {
                      viewModel.triggerSOS();
                      
                      // Get UserMapViewModel from parent context
                      final userMapViewModel = Provider.of<UserMapViewModel>(context, listen: false);
                      userMapViewModel.startSOS();
                      
                      // Close the bottom sheet first
                      Navigator.of(context).pop();
                      
                      // Then navigate to SOS waiting view with the ViewModel instance
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider<UserMapViewModel>.value(
                                value: userMapViewModel,
                              ),
                              ChangeNotifierProvider<SOSWaitingViewModel>.value(
                                value: userMapViewModel.sosWaitingViewModel!,
                              ),
                            ],
                            child: SOSWaitingView(
                              viewModel: userMapViewModel.sosWaitingViewModel,
                            ),
                          ),
                        ),
                      );
                      // TODO: Add SOS logic here
                    },
                  ),
                  SizedBox(height: spacing32),
                ],
              ),
            );
        },
      ),
    );
  }
}
