import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  // Add any state or logic needed for the settings page here
  // For example: emergency contacts, user info, etc.
  Future<void> logoutUser(BuildContext context) async {
    // Remove userId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    print('✅ userId removed from SharedPreferences on logout');

    // Add additional logout logic if needed (e.g., Supabase sign out)
    // await Supabase.instance.client.auth.signOut();

    // Navigate to Login page
    Navigator.of(context).pushReplacementNamed('/login');
  }
}