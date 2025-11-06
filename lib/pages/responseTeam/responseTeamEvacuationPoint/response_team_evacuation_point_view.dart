import 'package:flutter/material.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPoint/response_team_evacuation_point_view_model.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPoint/sections/evacuationHeaderSection/evacuation_header_view.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPoint/sections/evacuationListSection/evacuation_list_view.dart';
import 'package:get/get.dart';

class ResponseTeamEvacuationPointView extends StatelessWidget {
  const ResponseTeamEvacuationPointView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ResponseTeamEvacuationPointViewModel>()) {
      Get.put(ResponseTeamEvacuationPointViewModel());
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(children: [EvacuationHeaderView(), EvacuationListView()]),
      ),
    );
  }
}
