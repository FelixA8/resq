import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/userMap/components/radiant_marker.dart';
import 'package:resqapp/pages/userMap/components/navigation_arrow_marker.dart';
import 'package:resqapp/pages/userMap/components/navigation_banner.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:latlong2/latlong.dart';
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

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final user = controller.currentUser;
                  final username = user?.username ?? 'Guest';
                  return Text(
                    username,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  );
                }),
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
                    Obx(
                      () => Text(
                        controller.currentAddress.value,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: theme.colors.primary,
                        ),
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
                      final isLocationServiceEnabled =
                          controller.isLocationServiceEnabled.value;

                      final bool isDisabled =
                          isSOSActive || !isLocationServiceEnabled;

                      return SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDisabled
                                    ? Colors.grey.shade400
                                    : theme.colors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(35, 35),
                            maximumSize: const Size(double.infinity, 35),
                          ),
                          onPressed:
                              isDisabled
                                  ? () {
                                    Get.snackbar(
                                      'Layanan Lokasi Nonaktif',
                                      'Mohon aktifkan Lokasi Anda untuk menggunakan fitur ini',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: theme.colors.primary,
                                      colorText: Colors.white,
                                      animationDuration: Duration(
                                        milliseconds: 500,
                                      ),
                                      duration: Duration(seconds: 2),
                                      isDismissible: true,
                                    );
                                  }
                                  : () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      enableDrag: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (modalContext) {
                                        return const UserSOSView();
                                      },
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                    );
                                  },
                          child: const Text(
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
                UserNavigationBanner(),
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: controller.mapController.mapController,
                        options: MapOptions(
                          initialCenter: controller.currentLocation.value,
                          initialZoom: 13.0,
                          minZoom: 5.0,
                          maxZoom: 18.0,
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              controller.onMapMoved();
                            }
                          },
                          interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.disaster_map',
                            maxZoom: 19,
                          ),
                          // Route Layer - Shows remaining route
                          PolylineLayer(
                            polylines: [
                              if (controller.remainingRoutePoints.isNotEmpty)
                                Polyline(
                                  points:
                                      controller.remainingRoutePoints.toList(),
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
                                  child:
                                      controller.isNavigating.value
                                          ? NavigationArrowMarker(
                                            heading:
                                                controller.currentHeading.value,
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
                                                  color: Colors.blue
                                                      .withOpacity(0.3),
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
                                controller.evacuationPointsData.map((point) {
                                  final evacuationPoint = controller
                                      .findEvacuationPointById(point.evacuationId ?? "");
                                  return Marker(
                                    point: LatLng(point.locationLat ?? 0, point.locationLng ?? 0),
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
                                              return FractionallySizedBox(
                                                child:
                                                    EvacuationPointDetailModal(
                                                      evacuationPoint:
                                                          evacuationPoint,
                                                    ),
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
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
                          // Disasters 
                          
                          MarkerLayer(
                            markers:
                                controller.disasterPointsData.map((point) {
                                  final disaster = controller
                                      .findDisasterById(point.disasterId);
                                  return Marker(
                                    point: LatLng(disaster?.centerLat ?? 0, disaster?.centerLng ?? 0),
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
                                              return FractionallySizedBox(
                                                child: DisasterDetailModal(
                                                  disaster: disaster,
                                                ),
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
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
                        ],
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
        ),
        Obx(
          () =>
              controller.isLoading.value
                  ? Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red.shade700,
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
