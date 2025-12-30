import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sos_view_model.dart';
import 'sections/sos_confirmation_section.dart';
import 'sections/sos_button_section.dart';
import '../SOSWaiting/sos_waiting_view.dart';

class SOSView extends StatelessWidget {
  const SOSView({super.key});

  @override
  Widget build(BuildContext context) {
    final sosViewModel = Get.put(SOSViewModel(), tag: 'sos_modal');

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(color: Colors.transparent),
        ),

        DraggableScrollableSheet(
          initialChildSize:
              MediaQuery.of(context).size.height < 700 ? 0.5 : 0.45,
          minChildSize: 0.3,
          maxChildSize: MediaQuery.of(context).size.height < 700 ? 0.5 : 0.45,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          SOSConfirmationSection(),
                          SOSButtonSection(
                            onPressed: () async {
                              final result =
                                  await sosViewModel.handleSOSButtonPress();

                              if (result['success'] == true) {
                                Navigator.of(context).pop();
                                sosViewModel.cleanup();
                                Get.delete<SOSViewModel>(tag: 'sos_modal');

                                final vm = result['sosWaitingViewModel'];
                                if (vm != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => SOSWaitingView(viewModel: vm),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['error'] ?? 'An error occurred',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
