import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/pages/userMap/components/radiant_marker.dart';

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
                  // User location marker layer
                  MarkerLayer(
                    markers: [
                      // User location marker
                      if (controller.hasLocationPermission.value && !controller.isLoading.value)
                        Marker(
                          point: controller.currentLocation.value,
                          width: 42,
                          height: 42,
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
                  // Evacuation points layer
                  MarkerLayer(
                    markers: controller.evacuationPoints
                        .map(
                          (point) => Marker(
                            point: point,
                            width: 42,
                            height: 42,
                            child: Image.asset(
                              'assets/images/icons/map-evacuation-point.png',
                              width: 42,
                              height: 42,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  // Disaster (earthquake) points layer
                  MarkerLayer(
                    markers: controller.disasterPoints
                        .map(
                          (point) => Marker(
                            point: point,
                            width: 42,
                            height: 42,
                            child: RadiantMarker(
                              color: Colors.redAccent,
                              child: Image.asset(
                                'assets/images/icons/map-disaster-earthquake.png',
                                width: 42,
                                height: 42,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  // SOS points layer (sent by users when they press SOS button)
                  MarkerLayer(
                    markers: controller.sosPoints
                        .map(
                          (point) => Marker(
                            point: point,
                            width: 42,
                            height: 42,
                            child: RadiantMarker(
                              color: Colors.redAccent,
                              child: Image.asset(
                                'assets/images/icons/sos-logo.png',
                                width: 42,
                                height: 42,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              
              if (controller.isLoading.value)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
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