import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/components/sos_detail_modal.dart' as reusable;
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';

class SOSDetailModal extends StatelessWidget {
  final SosEvent sosEvent;

  const SOSDetailModal({
    Key? key,
    required this.sosEvent
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ResponseTeamMapViewModel>();
    
    return Obx(() {
      final _ = viewModel.sosEventsCount;
      final updatedSosEvent = viewModel.findSOSById(sosEvent.sosId) ?? sosEvent;
      
      final isNavigating = viewModel.isCurrentlyNavigatingTo(updatedSosEvent);
      final currentResponseTeamId = viewModel.getCurrentResponseTeamId();
      final isAssignedToOtherTeam = updatedSosEvent.responseTeamId != null && 
          updatedSosEvent.responseTeamId != currentResponseTeamId;
      final isRouteButtonEnabled = !isAssignedToOtherTeam;
      final distanceKm = viewModel.calculateDistanceToSos(updatedSosEvent);
      
      return reusable.SOSDetailModal(
        sosEvent: updatedSosEvent,
        onFetchUser: (userId) => viewModel.fetchUserById(userId),
        onFetchAddress: (sosEvent) => viewModel.fetchSOSAddress(sosEvent),
        formatReportTime: (timestamp) => viewModel.formatSOSReportTime(timestamp),
        onShowRoute: () {
          viewModel.showRouteToSos(updatedSosEvent);
        },
        isNavigating: isNavigating,
        distanceKm: distanceKm,
        onCancelRoute: () {
          viewModel.cancelRoute(updatedSosEvent);
        },
        currentResponseTeamId: currentResponseTeamId,
        isRouteButtonEnabled: isRouteButtonEnabled,
      );
    });
  }
}

