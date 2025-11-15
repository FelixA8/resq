import 'package:flutter/material.dart';

class ProgressBarViewModel extends ChangeNotifier {
  VoidCallback? _onBackPressed;
  double _progress = 0.67; // Default 2/3 progress

  VoidCallback? get onBackPressed => _onBackPressed;
  double get progress => _progress;

  void setOnBackPressed(VoidCallback? callback) {
    _onBackPressed = callback;
    notifyListeners();
  }

  void setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void handleBackPressed() {
    if (_onBackPressed != null) {
      _onBackPressed!();
    }
  }
}
