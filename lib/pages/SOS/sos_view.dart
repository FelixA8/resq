import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sos_view_model.dart';
import 'sections/sos_confirmation_section.dart';
import 'sections/sos_button_section.dart';
import '../SOSWaiting/sos_waiting_view.dart';

class SOSView extends StatelessWidget {
  const SOSView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final spacing8 = screenHeight * 0.01;
    final spacing12 = screenHeight * 0.015;
    final spacing15 = screenHeight * 0.018;
    final spacing32 = screenHeight * 0.04;

    final handleBarWidth = (screenWidth * 0.11).clamp(35.0, 45.0);

    final sosViewModel = Get.put(SOSViewModel(), tag: 'sos_modal');

    // Calculate initial child size based on screen height logic previously in UserMapView
    // screenHeight < 700 ? 0.5 : 0.45
    final initialChildSize = screenHeight < 700 ? 0.5 : 0.45;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: 0.3,
      maxChildSize: initialChildSize,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              SizedBox(height: spacing12),
              // Fixed Grabber
              Container(
                width: handleBarWidth,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: spacing15),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      const SOSConfirmationSection(),
                      SizedBox(height: spacing8),
                      SOSButtonSection(
                        onPressed: () async {
                          final result = await sosViewModel.handleSOSButtonPress();

                          if (result['success'] == true) {
                            Navigator.of(context).pop();
                            sosViewModel.cleanup();
                            Get.delete<SOSViewModel>(tag: 'sos_modal');

                            final vm = result['sosWaitingViewModel'];
                            if (vm != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SOSWaitingView(viewModel: vm),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['error'] ?? 'An error occurred'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: spacing32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
