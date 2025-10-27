import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:resqapp/pages/userMap/userMapViewModel.dart';
import 'package:resqapp/theme/theme_app.dart';
class UserMapView extends StatelessWidget {
  const UserMapView({Key? key}) : super(key: key);

  static const theme = ResQTheme();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserMapViewModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Consumer<UserMapViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                onPressed: () {
                  print("Icon tapped!");
                },
                icon: Image.asset(
                  'assets/images/icons/menu-hamburger.png',
                  width: 20,
                  height: 20,
                ),
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              );
            },
          ),
          actions: [
            Consumer<UserMapViewModel>(
              builder: (context, viewModel, child) {
                return Container(
                  margin: EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(0, 32),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/icons/report.png',
                          width: 16,
                          height: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Laporkan Bencana",
                          style: TextStyle(
                            color: Color(theme.colors.primary),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/reportDisaster');
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<UserMapViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                FlutterMap(
                  mapController: viewModel.mapController,
                  options: MapOptions(
                    initialCenter: viewModel.currentLocation,
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
                        if (viewModel.hasLocationPermission && !viewModel.isLoading)
                          Marker(
                            point: viewModel.currentLocation,
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
                
                if (viewModel.isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
                    ),
                  ),
                // Error message
                if (viewModel.error != null)
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
                                  viewModel.error!.message,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red.shade700),
                                onPressed: () {
                                  viewModel.clearError();
                                },
                              ),
                            ],
                          ),
                          if (viewModel.error!.requiresUserAction)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      viewModel.getQuickLocation();
                                    },
                                    icon: Icon(Icons.location_searching, size: 16),
                                    label: Text('Quick Location'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                  if (viewModel.error!.isRetryable)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        viewModel.retryLocationRequest();
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
          },
        ),
        
        floatingActionButton: Consumer<UserMapViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.hasLocationPermission)
                  FloatingActionButton(
                    heroTag: 'location',
                    onPressed: () => viewModel.moveToLocation(viewModel.currentLocation),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    child: Icon(Icons.my_location),
                  ),
                SizedBox(height: 16)
              ],
            );
          },
        ),
      ),
    );
  }
}