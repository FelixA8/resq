import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    Navigator.of(context).pushReplacementNamed('/login');
  }
}