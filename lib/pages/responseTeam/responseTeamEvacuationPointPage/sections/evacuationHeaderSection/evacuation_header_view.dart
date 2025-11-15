import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/response_team_evacuation_point_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';

class EvacuationHeaderView extends StatelessWidget {
  const EvacuationHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();
    final viewModel = Get.find<ResponseTeamEvacuationPointViewModel>();

    return Container(
      padding: EdgeInsets.all(theme.padding.ms),
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(1, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jumlah Poin Evakuasi",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  fontFamily: 'SF Pro',
                ),
              ),
              SizedBox(height: 4),
              Obx(() => Text(
                "${viewModel.totalEvacuationPoints.value} Poin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  fontFamily: 'SF Pro',
                ),
              )),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () => viewModel.addEvacuationPoint(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.padding.s,
                vertical: theme.padding.s + 1,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: Offset(1, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: theme.colors.primary,
                    size: 19,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Tambahkan",
                    style: TextStyle(
                      color: theme.colors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
