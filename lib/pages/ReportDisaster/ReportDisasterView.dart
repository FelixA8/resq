import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ReportDisasterViewModel.dart';
import 'sections/report_disaster_type_section.dart';
import 'sections/report_disaster_camera_section.dart';
import 'sections/report_disaster_description_section.dart';
import '../../components/confirmation_button.dart';

class ReportDisasterView extends StatelessWidget {
  const ReportDisasterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportDisasterViewModel(),
      child: const _ReportDisasterBody(),
    );
  }
}

class _ReportDisasterBody extends StatelessWidget {
  const _ReportDisasterBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB71C1C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Laporkan Bencana',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Color(0xFFB71C1C),
          ),
        ),
        centerTitle: false,
      ),
      resizeToAvoidBottomInset: true, // <-- important for keyboard
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReportDisasterTypeSection(),
                    const SizedBox(height: 24),
                    const ReportDisasterCameraSection(),
                    const SizedBox(height: 24),
                    const ReportDisasterDescriptionSection(),
                    Expanded(child: Container()),
                    ConfirmationButton(
                      onPressed: () {},
                      isEnabled: true,
                      text: 'Laporkan',
                    ),
                    SizedBox(height: 35 + MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
