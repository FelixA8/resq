import 'package:flutter/material.dart';
import 'package:resqapp/pages/userMap/models/disaster.dart';
import 'package:resqapp/theme/theme_app.dart';

class MapBottomModalView extends StatelessWidget {
  final Disaster disaster;

  const MapBottomModalView({
    Key? key,
    required this.disaster,
  }) : super(key: key);

  static const theme = ResQTheme();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              margin: EdgeInsets.only(top: 9, bottom: 18),
              width: 70,
              height: 5,
              decoration: BoxDecoration(
                color: Color(theme.colors.neutral.low),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  disaster.displayName,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.19,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 4),
            
            // Address
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  disaster.address ?? 'Alamat tidak tersedia',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(theme.colors.neutral.med),
                    height: 1.19,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 22),
            
            // Divider line
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Container(
                height: 2,
                color: Color(0x30898989),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Details Section - Type-specific properties in vertical layout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildDisasterSpecificDetails(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build disaster-specific details based on type matching Figma designs exactly
  List<Widget> _buildDisasterSpecificDetails() {
    if (disaster is EarthquakeDisaster) {
      final earthquake = disaster as EarthquakeDisaster;
      return [
        // Radius Area Terdampak
        buildDetailRow(
          iconPath: 'assets/images/icons/radius.png',
          label: 'Radius Area Terdampak',
          value: '${earthquake.impactedRadius.toStringAsFixed(0)} Km',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Kekuatan Gempa
        buildDetailRow(
          iconPath: 'assets/images/icons/earthquake-scale.png',
          label: 'Kekuatan Gempa',
          value: '${earthquake.strength.toStringAsFixed(2)} SR',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Potensi Terjadinya Tsunami
        buildDetailRow(
          iconPath: 'assets/images/icons/tsunami.png',
          label: 'Potensi Terjadinya Tsunami',
          value: earthquake.tsunamiPotential ? 'Berpotensi' : 'Tidak Berpotensi',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Status Siaga
        buildDetailRow(
          iconPath: 'assets/images/icons/warning.png',
          label: 'Status Siaga',
          value: earthquake.alertStatus,
        ),
      ];
    } else if (disaster is FloodDisaster) {
      final flood = disaster as FloodDisaster;
      return [
        // Radius Area Terdampak
        buildDetailRow(
          iconPath: 'assets/images/icons/radius.png',
          label: 'Radius Area Terdampak',
          value: '${flood.impactedRadius.toStringAsFixed(0)} Km',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Ketinggian Air
        buildDetailRow(
          iconPath: 'assets/images/icons/water-height.png',
          label: 'Ketinggian Air',
          value: '${flood.waterHeight.toStringAsFixed(1)} M',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Kecepatan Aliran Air
        buildDetailRow(
          iconPath: 'assets/images/icons/water-speed.png',
          label: 'Kecepatan Aliran Air',
          value: '${flood.waterFlowSpeed.toStringAsFixed(0)} ms',
        ),
      ];
    } else if (disaster is TsunamiDisaster) {
      final tsunami = disaster as TsunamiDisaster;
      return [
        // Radius Area Terdampak
        buildDetailRow(
          iconPath: 'assets/images/icons/radius.png',
          label: 'Radius Area Terdampak',
          value: '${tsunami.impactedRadius.toStringAsFixed(0)} Km',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Kekuatan Gempa Pemicu
        buildDetailRow(
          iconPath: 'assets/images/icons/earthquake-scale.png',
          label: 'Kekuatan Gempa Pemicu',
          value: '${tsunami.waveHeight.toStringAsFixed(1)} SR',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        buildDetailRow(
          iconPath: 'assets/images/icons/navbar-disaster-grey.png',
          label: 'Tinggi Gelombang',
          value: tsunami.alertStatus,
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Status Siaga
        buildDetailRow(
          iconPath: 'assets/images/icons/warning.png',
          label: 'Status Siaga',
          value: tsunami.alertStatus,
        ),
      ];
    } else if (disaster is VolcanoDisaster) {
      final volcano = disaster as VolcanoDisaster;
      return [
        // Radius Area Terdampak
        buildDetailRow(
          iconPath: 'assets/images/icons/radius.png',
          label: 'Radius Area Terdampak',
          value: '${volcano.impactedRadius.toStringAsFixed(0)} Km',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Status Siaga
        buildDetailRow(
          iconPath: 'assets/images/icons/warning.png',
          label: 'Status Siaga',
          value: volcano.alertStatus,
        ),
      ];
    } else if (disaster is LandslideDisaster) {
      final landslide = disaster as LandslideDisaster;
      return [
        // Radius Area Terdampak
        buildDetailRow(
          iconPath: 'assets/images/icons/radius.png',
          label: 'Radius Area Terdampak',
          value: '${landslide.impactedRadius.toStringAsFixed(0)} Km',
        ),
        SizedBox(height: 13),
        buildDivider(),
        SizedBox(height: 13),
        // Status Siaga
        buildDetailRow(
          iconPath: 'assets/images/icons/warning.png',
          label: 'Status Siaga',
          value: landslide.alertStatus,
        ),
      ];
    }
    
    // Fallback
    return [
      buildDetailRow(
        iconPath: 'assets/images/icons/radius.png',
        label: 'Radius Area Terdampak',
        value: '${disaster.impactedRadius.toStringAsFixed(0)} Km',
      ),
    ];
  }

  Widget buildDetailRow({
    String? iconPath,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        if (iconPath != null)
          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(
              iconPath
            ),
          ),
        if (iconPath != null) SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(theme.colors.neutral.med),
                height: 1.19,
              ),
            ),
            SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.19,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDivider() {
    return Container(
      height: 1,
      color: Color(theme.colors.neutral.low),
    );
  }
}
