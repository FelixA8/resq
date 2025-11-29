import 'package:flutter/animation.dart';

class MapAnimationConfig {
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve fastCurve = Curves.easeOut;
  
  static const Duration initialCenterDuration = Duration(milliseconds: 1200);
  static const Duration userTriggeredDuration = Duration(milliseconds: 800);
  static const Duration autoCenterDuration = Duration(milliseconds: 600);
  static const Duration recenterAfterIdleDuration = Duration(milliseconds: 1000);
  
  static const double initialZoom = 15.0;
  static const double navigationZoom = 17.0;
  static const double manualLocationZoom = 16.0;
}
