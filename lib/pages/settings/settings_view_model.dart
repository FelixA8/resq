import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'dart:developer' as developer;

class SettingsViewModel extends GetxController {
  final Rx<ResqUser?> _user = Rx<ResqUser?>(null);
  ResqUser? get user => _user.value;

  final RxList<String?> contactNumbers = <String?>[null, null, null].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditingUsername = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        _user.value = await SupabaseService.getUserById(userId);

        final contacts = await SupabaseService.getUserContacts(userId);
        
        contactNumbers.value = [null, null, null];
        
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
      developer.log('Error loading settings data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUsername(String newName) async {
    if (user == null) return;

    final updatedUser = user!.copyWith(username: newName);
    final success = await SupabaseService.updateUser(updatedUser);

    if (success) {
      _user.value = updatedUser;
    }
  }

  void startEditingUsername() {
    isEditingUsername.value = true;
  }

  void cancelEditingUsername() {
    isEditingUsername.value = false;
  }

  Future<void> showUsernameConfirmationDialog(String newUsername) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirm Username Change'),
        content: Text('Are you sure you want to change your username to "$newUsername"?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (result == true) {
      await updateUsername(newUsername);
    }
    isEditingUsername.value = false;
  }

  Future<void> updateContact(int index, String? number) async {
    if (user == null) return;
    
    // 1-based index for contact name
    final contactName = 'Contact ${index + 1}';
    
    if (number == null || number.isEmpty) {
      final success = await SupabaseService.deleteContact(user!.userId, contactName);
      if (success) {
        contactNumbers[index] = null;
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
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    Get.delete<UserMapViewModel>(force: true);
    Get.offAllNamed('/login');
  }
}