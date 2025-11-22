import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/userMap/components/radiant_marker.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/pages/SOS/sos_view.dart';
import 'package:resqapp/pages/userMap/components/sos_active_banner.dart';
import 'package:resqapp/pages/userMap/components/disaster_detail_modal.dart';
import 'package:resqapp/pages/userMap/components/evacuation_point_detail_modal.dart';

class UserMapView extends GetView<UserMapViewModel> {
  const UserMapView({Key? key}) : super(key: key);

  static const theme = ResQTheme();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserMapViewModel>()) {
      Get.put(UserMapViewModel(), permanent: true);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'John Doe', // Placeholder, ideally from user profile
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/icons/annotation-app-bar.png',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  'Tangerang Selatan', // Placeholder
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: theme.colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(35, 35),
                      maximumSize: Size(35, 35),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Image.asset(
                      'assets/images/icons/settings.png',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Obx(() {
                  final isSOSActive = controller.isSOSActive;
                  return SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSOSActive
                                ? Colors.grey.shade400
                                : theme.colors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: Size(35, 35),
                        maximumSize: Size(double.infinity, 35),
                      ),
                      onPressed:
                          isSOSActive
                              ? null
                              : () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (modalContext) {
                                    final screenHeight =
                                        MediaQuery.of(context).size.height;
                                    final heightFactor =
                                        screenHeight < 700 ? 0.5 : 0.45;

                                    return FractionallySizedBox(
                                      heightFactor: heightFactor,
                                      child: SOSView(),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                );
                              },
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            SOSActiveBanner(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: controller.mapController,
                    options: MapOptions(
                      initialCenter: controller.currentLocation.value,
                      initialZoom: 13.0,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                      interactionOptions: InteractionOptions(
                        flags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.disaster_map',
                        maxZoom: 19,
                      ),
                      // Route Layer
                      PolylineLayer(
                        polylines: [
                          if (controller.routePoints.isNotEmpty)
                            Polyline(
                              points: controller.routePoints.toList(),
                              color: Colors.blue,
                              strokeWidth: 5.0,
                              borderColor: Colors.blue.withOpacity(0.3),
                              borderStrokeWidth: 2.0,
                            ),
                        ],
                      ),
                      // User marker layer
                      MarkerLayer(
                        markers: [
                          if (controller.hasLocationPermission.value &&
                              !controller.isLoading.value)
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
                      // Evacuation Points
                      MarkerLayer(
                        markers:
                            controller.evacuationPoints
                                .map(
                                  (point) {
                                    final evacuationPoint = controller.findEvacuationPointByLocation(point);
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
                                                // Logic to adjust height based on whether we are navigating or just viewing details could go here
                                                final screenHeight = MediaQuery.of(context).size.height;
                                                final heightFactor = screenHeight < 700 ? 0.4 : 0.35;

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
                                  },
                                )
                                .toList(),
                      ),
                      // Disasters
                      MarkerLayer(
                        markers:
                            controller.disasterPoints
                                .map(
                                  (point) {
                                    final disaster = controller.findDisasterByLocation(point);
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
                                  },
                                )
                                .toList(),
                      ),
                    ],
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
                    () =>
                        controller.moveToLocation(controller.currentLocation.value),
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