import 'package:flutter/material.dart';
import '../../otp_view_model.dart';

class ProgressBarViewModel extends ChangeNotifier {
  VoidCallback? _onBackPressed;
  double _progress = 0.33;
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
    _otpViewModel?.removeListener(_updateProgress);

    _otpViewModel = viewModel;

    if (viewModel != null) {
      viewModel.addListener(_updateProgress);
      _updateProgress();
    }

    notifyListeners();
  }

  void _updateProgress() {
    if (_otpViewModel != null) {
      double newProgress;
      switch (_otpViewModel!.currentState) {
        case ViewState.otpInput:
          newProgress = 0.33;
          break;
        case ViewState.usernameInput:
          newProgress = 0.66;
          break;
        case ViewState.authenticated:
          newProgress = 1;
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
