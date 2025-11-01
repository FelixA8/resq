import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';

class ResponseTeamMapView extends GetView<ResponseTeamMapViewModel> {
  final String instanceCode;
  
  const ResponseTeamMapView({super.key, required this.instanceCode});

  static const theme = ResQTheme();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ResponseTeamMapViewModel>()) {
      Get.put(ResponseTeamMapViewModel(instanceCode: instanceCode), permanent: false);
    }

    return Scaffold(
        body: Obx(() {
          return Stack(
            children: [
              FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.currentLocation.value,
                  initialZoom: 13.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  interactionOptions: InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.disaster_map',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      // User location marker
                      if (controller.hasLocationPermission.value && !controller.isLoading.value)
                        Marker(
                          point: controller.currentLocation.value,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              if (controller.isLoading.value)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
                  ),
                ),
              // Error message
              if (controller.error.value != null)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.error.value!.message,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red.shade700),
                              onPressed: () {
                                controller.clearError();
                              },
                            ),
                          ],
                        ),
                        if (controller.error.value!.requiresUserAction)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    controller.getQuickLocation();
                                  },
                                  icon: Icon(Icons.location_searching, size: 16),
                                  label: Text('Quick Location'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                                if (controller.error.value!.isRetryable)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.retryLocationRequest();
                                    },
                                    icon: Icon(Icons.refresh, size: 16),
                                    label: Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade700,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
        
        floatingActionButton: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.hasLocationPermission.value)
                FloatingActionButton(
                  heroTag: 'location',
                  onPressed: () => controller.moveToLocation(controller.currentLocation.value),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  child: Icon(Icons.my_location),
                ),
              SizedBox(height: 16)
            ],
          );
        }),
    );
  }
}