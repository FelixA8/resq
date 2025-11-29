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
       // If number is null/empty, we might want to delete it? 
       // For now, let's just update it to null or handle deletion if needed.
       // The current UI logic seems to just set it.
       // If we want to "delete", we can use the same upsert logic or a delete method.
       // But the UI sends a valid number or null.
       // If it's null, we probably want to delete the contact entry.
       // Let's assume we delete if null.
       // But wait, upsertContact deletes then inserts. If we pass null phone, it might be weird.
       // Actually, let's just not support "deleting" via null in this simple pass unless requested.
       // But the UI allows clearing? The UI code shows: phoneNumbers[index] = newNumber.isEmpty ? null : newNumber;
       // So yes, it can be null.
       
       // If it is null, we should delete the contact from DB.
       // We need a deleteContact method or just use upsert with null? 
       // The Contact model allows null phoneNumber.
       // Let's stick to upserting with null or the new number.
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