import 'package:flutter/material.dart';
import '../../otp_view_model.dart';

class ProgressBarViewModel extends ChangeNotifier {
  VoidCallback? _onBackPressed;
  double _progress = 0.33; // Default 1/3 progress for OTP
  OTPViewModel? _otpViewModel;

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

  void setOTPViewModel(OTPViewModel? viewModel) {
    // Remove listener from previous view model
    _otpViewModel?.removeListener(_updateProgress);

    _otpViewModel = viewModel;

    // Add listener to new view model
    if (viewModel != null) {
      viewModel.addListener(_updateProgress);
      _updateProgress(); // Update immediately
    }

    notifyListeners();
  }

  void _updateProgress() {
    if (_otpViewModel != null) {
      double newProgress;
      switch (_otpViewModel!.currentState) {
        case ViewState.otpInput:
          newProgress = 0.33; // 1/3 progress for OTP input
          break;
        case ViewState.usernameInput:
          newProgress = 0.66; // 2/3 progress for username input
          break;
      }

      if (_progress != newProgress) {
        _progress = newProgress;
        notifyListeners();
      }
    }
  }

  void handleBackPressed() {
    if (_onBackPressed != null) {
      _onBackPressed!();
    }
  }

  @override
  void dispose() {
    _otpViewModel?.removeListener(_updateProgress);
    super.dispose();
  }
}
