import 'package:flutter/material.dart';
import 'package:resqapp/pages/userMap/userMapView.dart';
import '../../otp_view_model.dart';

class ConfirmationButtonViewModel extends ChangeNotifier {
  bool _isEnabled = false;
  OTPViewModel? _otpViewModel;

  bool get isEnabled => _isEnabled;
  OTPViewModel? get otpViewModel => _otpViewModel;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }

  void setOTPViewModel(OTPViewModel? viewModel) {
    // Remove listener from previous view model
    _otpViewModel?.removeListener(_updateEnabledState);

    _otpViewModel = viewModel;

    // Add listener to new view model
    if (viewModel != null) {
      viewModel.addListener(_updateEnabledState);
      _updateEnabledState(); // Update immediately
    }

    notifyListeners();
  }

  void _updateEnabledState() {
    if (_otpViewModel != null) {
      final newEnabled =
          _otpViewModel!.isUsernameValid && !_otpViewModel!.isLoading;
      if (_isEnabled != newEnabled) {
        _isEnabled = newEnabled;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _otpViewModel?.removeListener(_updateEnabledState);
    super.dispose();
  }

  void handleConfirm(BuildContext context) {
    if (_isEnabled && _otpViewModel != null) {
      _otpViewModel!.saveUsername().then((success) {
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username saved successfully!')),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UserMapView()),
            (Route<dynamic> route) => false,
          );
        }
      });
    }
  }
}
