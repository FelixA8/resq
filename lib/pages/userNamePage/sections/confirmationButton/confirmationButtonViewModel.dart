import 'package:flutter/material.dart';
import 'package:resqapp/pages/userMap/user_map_view.dart';
import '../../usernameViewModel.dart';
import 'package:get/get.dart';

class UsernameConfirmationButtonViewModel extends ChangeNotifier {
  bool _isEnabled = false;
  UsernameViewModel? _usernameViewModel;

  bool get isEnabled => _isEnabled;
  UsernameViewModel? get usernameViewModel => _usernameViewModel;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }

  void setUsernameViewModel(UsernameViewModel? viewModel) {
    _usernameViewModel?.removeListener(_updateEnabledState);

    _usernameViewModel = viewModel;

    if (viewModel != null) {
      viewModel.addListener(_updateEnabledState);
      _updateEnabledState();
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
