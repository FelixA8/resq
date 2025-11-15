import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/response_team_evacuation_point_view_model.dart';
import 'package:resqapp/pages/responseTeam/responseTeamEvacuationPointPage/components/evacuation_list_card.dart';
import 'package:resqapp/theme/theme_app.dart';

class EvacuationListView extends StatelessWidget {
  const EvacuationListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResponseTeamEvacuationPointViewModel>();
    const theme = ResQTheme();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: theme.size.m),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.padding.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daftar Poin Evakuasi",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    fontFamily: 'SF Pro',
                  ),
                ),
                SizedBox(height: theme.size.s),
                Container(
                  height: 2,
                  width: double.infinity,
                  color: Color(0x30898989), // rgba(137, 137, 137, 0.19)
                ),
                SizedBox(height: theme.size.m),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colors.primary,
                  ),
                );
              }

              if (controller.evacuationPoints.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshData,
                  color: theme.colors.primary,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Center(
                          child: Text(
                            "Tidak ada poin evakuasi",
                            style: TextStyle(
                              color: theme.colors.neutral.med,
                              fontSize: 14,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                color: theme.colors.primary,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: theme.padding.s),
                  itemCount: controller.evacuationPoints.length,
                  separatorBuilder:
                      (context, index) => SizedBox(height: theme.size.s),
                  itemBuilder: (context, index) {
                    final evacuationPoint = controller.evacuationPoints[index];
                    return EvacuationPointCard(
                      evacuationPoint: evacuationPoint,
                      onEdit:
                          () => controller.editEvacuationPoint(evacuationPoint),
                      onDelete:
                          () => controller.deleteEvacuationPoint(evacuationPoint),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
