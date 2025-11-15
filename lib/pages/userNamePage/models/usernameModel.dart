class UsernameModel {
  String _username = '';
  bool _isValid = false;

  String get username => _username;
  bool get isValid => _isValid;

  void setUsername(String value) {
    _username = value;
    _validateUsername();
  }

  void _validateUsername() {
    // Basic validation - can be expanded based on requirements
    _isValid = _username.length >= 3 && _username.length <= 30;
  }
}
