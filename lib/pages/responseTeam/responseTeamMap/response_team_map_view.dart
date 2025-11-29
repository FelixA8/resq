import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/response_team_map_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/pages/userMap/components/radiant_marker.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/components/disaster_detail_modal.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/components/evacuation_point_detail_modal.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/components/sos_detail_modal.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/components/navigation_arrow_marker.dart';
import 'package:resqapp/pages/responseTeam/responseTeamMap/components/navigation_banner.dart';
import 'package:latlong2/latlong.dart';

class ResponseTeamMapView extends GetView<ResponseTeamMapViewModel> {
  final String instanceCode;

  const ResponseTeamMapView({super.key, required this.instanceCode});

  static const theme = ResQTheme();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ResponseTeamMapViewModel>()) {
      Get.put(
        ResponseTeamMapViewModel(instanceCode: instanceCode),
        permanent: false,
      );
    }

    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController.mapController,
              options: MapOptions(
                initialCenter: controller.currentLocation.value,
                initialZoom: 13.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onMapEvent: (MapEvent event) {
                  if (event is MapEventMoveEnd ||
                      event is MapEventFlingAnimationEnd) {
                    controller.onMapMoved();
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.disaster_map',
                  maxZoom: 19,
                ),
                PolylineLayer(
                  polylines: [
                    if (controller.isNavigating.value &&
                        controller.remainingRoutePoints.isNotEmpty)
                      Polyline(
                        points: controller.remainingRoutePoints.toList(),
                        color: const Color(0xFF4285F4),
                        strokeWidth: 6.0,
                        borderColor: const Color(0xFF1967D2),
                        borderStrokeWidth: 2.0,
                      )
                    else if (!controller.isNavigating.value &&
                        controller.routePoints.isNotEmpty)
                      Polyline(
                        points: controller.routePoints.toList(),
                        color: Colors.blue,
                        strokeWidth: 5.0,
                        borderColor: Colors.blue.withOpacity(0.3),
                        borderStrokeWidth: 2.0,
                      ),
                  ],
                ),
                // User location marker layer
                MarkerLayer(
                  markers: [
                    if (controller.hasLocationPermission.value &&
                        !controller.isLoading.value)
                      Marker(
                        point: controller.currentLocation.value,
                        width: 42,
                        height: 42,
                        child:
                            controller.isNavigating.value
                                ? NavigationArrowMarker(
                                  heading: controller.currentHeading.value,
                                  size: 42,
                                )
                                : Container(
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
                                  child: const Icon(
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
                  markers:
                      controller.evacuationPoints.map((point) {
                        // Find the evacuation point data for this point
                        final evacuationPoint = controller
                            .findEvacuationPointByLocation(point);
                        return Marker(
                          point: point,
                          width: 42,
                          height: 42,
                          child: GestureDetector(
                            onTap: () {
                              if (evacuationPoint != null) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (modalContext) {
                                    final screenHeight =
                                        MediaQuery.of(context).size.height;
                                    // Responsive height: adjust based on screen size
                                    final heightFactor =
                                        screenHeight < 700 ? 0.30 : 0.28;

                                    return FractionallySizedBox(
                                      heightFactor: heightFactor,
                                      child: EvacuationPointDetailModal(
                                        evacuationPoint: evacuationPoint,
                                      ),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Image.asset(
                              'assets/images/icons/map-evacuation-point.png',
                              width: 42,
                              height: 42,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                // Disaster (earthquake) points layer
                MarkerLayer(
                  markers:
                      controller.disasterPoints.map((point) {
                        // Find the disaster data for this point
                        final disaster = controller.findDisasterByLocation(
                          point,
                        );
                        return Marker(
                          point: point,
                          width: 42,
                          height: 42,
                          child: GestureDetector(
                            onTap: () {
                              if (disaster != null) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (modalContext) {
                                    final screenHeight =
                                        MediaQuery.of(context).size.height;
                                    // Responsive height: adjust based on screen size
                                    final heightFactor =
                                        screenHeight < 700 ? 0.6 : 0.5;

                                    return FractionallySizedBox(
                                      heightFactor: heightFactor,
                                      child: DisasterDetailModal(
                                        disaster: disaster,
                                      ),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: RadiantMarker(
                              color: Colors.redAccent,
                              child: Image.asset(
                                'assets/images/icons/map-disaster-earthquake.png',
                                width: 42,
                                height: 42,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                Obx(() {
                  return MarkerLayer(
                    markers:
                        controller.sosPoints.map((point) {
                          final sosEvent = controller.findSOSByLocation(point);
                          return Marker(
                            point: point,
                            width: 42,
                            height: 42,
                            child: GestureDetector(
                              onTap: () {
                                if (sosEvent != null) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (modalContext) {
                                      final screenHeight =
                                          MediaQuery.of(context).size.height;
                                      final heightFactor =
                                          screenHeight < 700 ? 0.45 : 0.41;
                                      return FractionallySizedBox(
                                        heightFactor: heightFactor,
                                        child: SOSDetailModal(
                                          sosEvent: sosEvent,
                                        ),
                                      );
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                  );
                                }
                              },

                              child: RadiantMarker(
                                color: Colors.redAccent,
                                child: Image.asset(
                                  'assets/images/icons/sos-logo.png',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                }),
              ],
            ),

            // Navigation Banner
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: NavigationBanner(),
              ),
            ),

            if (controller.isLoading.value)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.red.shade700,
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
                onPressed:
                    () => controller.moveToLocation(
                      controller.currentLocation.value,
                    ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                child: Icon(Icons.my_location),
              ),
            SizedBox(height: 16),
          ],
        );
      }),
    );
  }
}
