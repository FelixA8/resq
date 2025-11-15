import 'package:flutter/foundation.dart';
import 'models/usernameModel.dart';

class UsernameViewModel extends ChangeNotifier {
  final UsernameModel _model = UsernameModel();
  bool _isLoading = false;

  String get username => _model.username;
  bool get isValid => _model.isValid;
  bool get isLoading => _isLoading;

  void setUsername(String value) {
    _model.setUsername(value);
    notifyListeners();
  }

  Future<bool> saveUsername() async {
    if (!_model.isValid) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual Firebase implementation
      await Future.delayed(
        const Duration(seconds: 1),
      ); 

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
