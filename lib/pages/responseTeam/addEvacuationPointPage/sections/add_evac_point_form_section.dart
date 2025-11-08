import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/add_evacuation_point_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';

class AddEvacPointFormSection extends GetView<AddEvacuationPointViewModel> {
  const AddEvacPointFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();
    
    return Expanded(
      child: Column(
        children: [
          // Map Section
          Expanded(
            child: Container(
              width: double.infinity,
              child: Obx(() {
                return Stack(
                  children: [
                    // Map
                    FlutterMap(
                      mapController: controller.mapController,
                      options: MapOptions(
                        initialCenter: controller.currentLocation.value,
                        initialZoom: 15.0,
                        minZoom: 5.0,
                        maxZoom: 18.0,
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                        onPositionChanged: (MapCamera camera, bool hasGesture) {
                          if (hasGesture) {
                            controller.onMapPositionChanged(camera);
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.resqapp',
                          maxZoom: 19,
                        ),
                        MarkerLayer(
                          markers: [
                            // User location marker (if permission granted)
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
                    
                    // Center annotation marker (fixed at center of screen)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            child: 
                            // TODO: Replace with Image.asset("assets/images/icons/annotation.png") when asset is available
                            Icon(
                              Icons.location_on,
                              color: Color(theme.colors.primary),
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Floating action button for current location
                    if (controller.hasLocationPermission.value)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          heroTag: 'current_location',
                          onPressed: controller.moveToCurrentLocation,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          mini: true,
                          child: Icon(Icons.my_location),
                        ),
                      ),
                    
                    // Loading indicator
                    if (controller.isLoading.value)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(theme.colors.primary),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
          
          // Bottom section with confirmation button
          Container(
            height: 87,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: Offset(1, 1),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.padding.lm),
              child: Center(
                child: Container(
                  width: 350,
                  height: 51,
                  child: ElevatedButton(
                    onPressed: controller.onConfirmPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(theme.colors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Konfirmasi',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}