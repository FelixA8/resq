import 'package:flutter/material.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/response_team_evacuation_point_view_model.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/sections/evacuationHeaderSection/evacuation_header_view.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/sections/evacuationListSection/evacuation_list_view.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:get/get.dart';

class ResponseTeamEvacuationPointView extends StatelessWidget {
  final String? instanceCode;

  const ResponseTeamEvacuationPointView({super.key, this.instanceCode});

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();

    if (!Get.isRegistered<ResponseTeamEvacuationPointViewModel>()) {
      Get.put(
        ResponseTeamEvacuationPointViewModel(
          instanceCode: instanceCode ?? 'Unit305',
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.padding.m),
                  child: EvacuationHeaderView(),
                ),
                EvacuationListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
