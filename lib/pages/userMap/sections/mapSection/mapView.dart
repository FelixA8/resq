import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Mapview extends StatefulWidget {
  const Mapview({super.key});

  @override
  State<Mapview> createState() => MapviewState();
}

class MapviewState extends State<Mapview> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          51.509364,
          -0.128928,
        ), // Center the map over London
        initialZoom: 9.2,
        minZoom: 5.0,
        maxZoom: 18.0,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.drag | InteractiveFlag.rotate,
        )
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.resq.app',
          additionalOptions: const {
            // REQUIRED: Replace with your actual app name, version, and contact email
            'User-Agent': 'ResqApp/1.0 (your-email@example.com; https://your-website.com)',
            'attribution': '© OpenStreetMap contributors',
            
            // REQUIRED: Replace with your actual website
            'Referer': 'https://your-website.com',
            
            // Good practice: Indicate this is for mobile app usage
            'X-Requested-With': 'FlutterApp',
          },
          // Add caching to reduce server load
          maxZoom: 18,
          // Add error handling for blocked requests
          errorTileCallback: (tile, error, stackTrace) {
            debugPrint('Tile loading error: $error');
          },
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              textStyle: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
