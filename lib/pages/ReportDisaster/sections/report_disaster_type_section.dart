import 'package:flutter/material.dart';
import '../ReportDisasterViewModel.dart';
import 'package:provider/provider.dart';
import '../../../components/dropdown_component.dart';

class ReportDisasterTypeSection extends StatelessWidget {
  const ReportDisasterTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportDisasterViewModel>(context);
    final disasterTypes = [
      'Gempa Bumi',
      'Banjir',
      'Tsunami',
      'Tanah Longsor',
      'Erupsi Gunung Api'
    ];
    return DropdownComponent(
      options: disasterTypes,
      value: viewModel.selectedDisasterType ?? disasterTypes[0],
      onChanged: (value) => viewModel.setDisasterType(value),
      label: 'Tipe Bencana',
    );
  }
}
