import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/components/evacuation_point_detail_modal.dart'
    as reusable;
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';

class EvacuationPointDetailModal extends StatelessWidget {
  final EvacuationPoint evacuationPoint;

  const EvacuationPointDetailModal({Key? key, required this.evacuationPoint})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ResponseTeamMapViewModel>();

    return Obx(() {

      final _ = viewModel.sosEventsCount;
      final isNavigating = viewModel.isCurrentlyNavigatingToEvacuationPoint(evacuationPoint);
      final distanceKm = viewModel.calculateDistanceToEvacuationPoint(evacuationPoint);

      return reusable.EvacuationPointDetailModal(
        evacuationPoint: evacuationPoint,
        isNavigating: isNavigating,
        distanceKm: distanceKm,
        onCancelRoute: () => viewModel.cancelEvacuationRoute(),
        onShowRoute: () {
          viewModel.showRouteToEvacuationPoint(evacuationPoint);
        },
      );
    });
  }
}
