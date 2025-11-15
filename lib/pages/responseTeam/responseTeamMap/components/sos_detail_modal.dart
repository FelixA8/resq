import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/components/sos_detail_modal.dart' as reusable;
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';

class SOSDetailModal extends StatelessWidget {
  final SosEvent sosEvent;

  const SOSDetailModal({
    Key? key,
    required this.sosEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ResponseTeamMapViewModel>();
    
    return reusable.SOSDetailModal(
      sosEvent: sosEvent,
      onFetchUser: (userId) => viewModel.fetchUserById(userId),
      onFetchAddress: (sosEvent) => viewModel.fetchSOSAddress(sosEvent),
      formatReportTime: (timestamp) => viewModel.formatSOSReportTime(timestamp),
      onShowRoute: () {
        // TODO: Implement show route functionality
        print('Show route to SOS location: ${sosEvent.sosId}');
      },
    );
  }
}

