import 'package:flutter/material.dart';
import 'package:resqapp/pages/userMap/userMapView.dart';
import '../../usernameViewModel.dart';

class ConfirmationButtonViewModel extends ChangeNotifier {
  bool _isEnabled = false;
  UsernameViewModel? _usernameViewModel;

  bool get isEnabled => _isEnabled;
  UsernameViewModel? get usernameViewModel => _usernameViewModel;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }

  void setUsernameViewModel(UsernameViewModel? viewModel) {
    // Remove listener from previous view model
    _usernameViewModel?.removeListener(_updateEnabledState);

    _usernameViewModel = viewModel;

    // Add listener to new view model
    if (viewModel != null) {
      viewModel.addListener(_updateEnabledState);
      _updateEnabledState(); // Update immediately
    }

    notifyListeners();
  }

  void _updateEnabledState() {
    if (_usernameViewModel != null) {
      final newEnabled =
          _usernameViewModel!.isValid && !_usernameViewModel!.isLoading;
      if (_isEnabled != newEnabled) {
        _isEnabled = newEnabled;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _usernameViewModel?.removeListener(_updateEnabledState);
    super.dispose();
  }

  void handleConfirm(BuildContext context) {
    if (_isEnabled && _usernameViewModel != null) {
      _usernameViewModel!.saveUsername().then((success) {
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username saved successfully!')),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const UserMapView(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      });
    }
  }
}
