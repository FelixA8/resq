import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SOSViewModel.dart';
import 'sections/sos_confirmation_section.dart';
import 'sections/sos_button_section.dart';

class SOSView extends StatelessWidget {
  const SOSView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 15),
                SOSConfirmationSection(),
                SOSButtonSection(
                  onPressed: () {
                    viewModel.triggerSOS();
                    // TODO: Add SOS logic here
                  },
                ),
                SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
