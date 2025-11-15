import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/add_evacuation_point_view_model.dart';

class EvacPointAlertBanner extends StatelessWidget {
  final AddEvacuationPointViewModel viewModel;
  
  const EvacPointAlertBanner({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: theme.colors.primary),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPaint(
            size: Size(50, 50),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFF1C8C8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/icons/annotation-app-bar.png",
                  height: 40,
                  width: 40,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          SizedBox(width: 12),
          // Text Content - Reactive to address changes
          Expanded(
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (viewModel.isGeocodingLoading.value)
                    Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading address...',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      viewModel.selectedLocationDetail.value.isNotEmpty 
                          ? viewModel.selectedLocationDetail.value
                          : 'Address not available',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
