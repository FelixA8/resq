import 'package:flutter/material.dart';

class SOSViewModel extends ChangeNotifier {
  // Add any SOS logic here
  bool isSOSActive = false;

  void triggerSOS() {
    isSOSActive = true;
    notifyListeners();
  }

  void resetSOS() {
    isSOSActive = false;
    notifyListeners();
  }
}
