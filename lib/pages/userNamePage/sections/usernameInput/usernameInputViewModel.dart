import 'package:flutter/material.dart';
import '../../usernameViewModel.dart';

class UsernameInputViewModel extends ChangeNotifier {
  String _username = '';
  bool _isValid = false;
  UsernameViewModel? _mainViewModel;

  String get username => _username;
  bool get isValid => _isValid;
  UsernameViewModel? get mainViewModel => _mainViewModel;

  void setUsername(String username) {
    _username = username;
    _validateUsername();
    notifyListeners();

    // Update main view model
    if (_mainViewModel != null) {
      _mainViewModel!.setUsername(username);
    }
  }

  void setMainViewModel(UsernameViewModel? viewModel) {
    _mainViewModel = viewModel;
    if (viewModel != null) {
      _username = viewModel.username;
      _isValid = viewModel.isValid;
    }
    notifyListeners();
  }

  void _validateUsername() {
    // Basic validation - username should not be empty and should be at least 3 characters
    _isValid = _username.trim().isNotEmpty && _username.trim().length >= 3;
  }

  void handleUsernameChanged(String value) {
    setUsername(value);
  }
}
