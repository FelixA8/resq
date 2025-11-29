import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/models/supabase_models.dart';

class SettingsViewModel extends ChangeNotifier {
  ResqUser? user;
  // Fixed size list for 3 contact slots
  List<String?> contactNumbers = [null, null, null];
  bool isLoading = false;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        // Fetch user
        user = await SupabaseService.getUserById(userId);

        // Fetch contacts
        final contacts = await SupabaseService.getUserContacts(userId);
        
        // Map contacts to slots based on name "Contact 1", "Contact 2", "Contact 3"
        // Reset contacts first
        contactNumbers = [null, null, null];
        
        for (var contact in contacts) {
          if (contact.contactName == 'Contact 1') {
            contactNumbers[0] = contact.phoneNumber;
          } else if (contact.contactName == 'Contact 2') {
            contactNumbers[1] = contact.phoneNumber;
          } else if (contact.contactName == 'Contact 3') {
            contactNumbers[2] = contact.phoneNumber;
          }
        }
      }
    } catch (e) {
      print('Error loading settings data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUsername(String newName) async {
    if (user == null) return;

    final updatedUser = user!.copyWith(username: newName);
    final success = await SupabaseService.updateUser(updatedUser);

    if (success) {
      user = updatedUser;
      notifyListeners();
    }
  }

  Future<void> updateContact(int index, String? number) async {
    if (user == null) return;
    
    // 1-based index for contact name
    final contactName = 'Contact ${index + 1}';
    
    if (number == null || number.isEmpty) {
      final success = await SupabaseService.deleteContact(user!.userId, contactName);
      if (success) {
        contactNumbers[index] = null;
        notifyListeners();
      }
      return;
    }

    final contact = Contact(
      userId: user!.userId,
      contactName: contactName,
      phoneNumber: number,
    );

    final success = await SupabaseService.upsertContact(contact);

    if (success) {
      contactNumbers[index] = number;
      notifyListeners();
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    Navigator.of(context).pushReplacementNamed('/login');
  }
}