import 'package:flutter/material.dart';
import '../../otp_view_model.dart';

class UsernameInputViewModel extends ChangeNotifier {
  String _username = '';
  bool _isValid = false;
  OTPViewModel? _mainViewModel;

  String get username => _username;
  bool get isValid => _isValid;
  OTPViewModel? get mainViewModel => _mainViewModel;

  void setUsername(String username) {
    _username = username;
    _validateUsername();
    notifyListeners();

    // Update main view model
    if (_mainViewModel != null) {
      _mainViewModel!.setUsername(username);
    }
  }

  void setMainViewModel(OTPViewModel? viewModel) {
    _mainViewModel = viewModel;
    if (viewModel != null) {
      _username = viewModel.username;
      _isValid = viewModel.isUsernameValid;
    }
    notifyListeners();
  }

  void _validateUsername() {
    final RegExp alpha = RegExp(r'^[a-zA-Z]+$');
    _isValid = _username.trim().isNotEmpty && _username.trim().length >= 3 && alpha.hasMatch(_username.trim());
  }

  void handleUsernameChanged(String value) {
    setUsername(value);
  }
}
