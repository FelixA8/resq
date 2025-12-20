import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/components/disaster_detail_modal.dart' as reusable;
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';

class DisasterDetailModal extends StatelessWidget {
  final Disaster disaster;

  const DisasterDetailModal({
    Key? key,
    required this.disaster,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ResponseTeamMapViewModel>();
    
    return reusable.DisasterDetailModal(
      disaster: disaster,
      onFetchAddress: (disaster) => viewModel.fetchDisasterAddress(disaster),
      onDownloadShakeMap: (disaster) => viewModel.openDisasterShakeMap(disaster),
      formatDate: (timestamp) => viewModel.formatDisasterDate(timestamp),
      formatMagnitude: (magnitude) => viewModel.formatDisasterMagnitude(magnitude),
      getTsunamiPotential: (magnitude) => viewModel.getTsunamiPotential(magnitude),
      formatDepth: (depth) => viewModel.formatDisasterDepth(depth),
    );
  }
}

