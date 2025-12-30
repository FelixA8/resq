import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/settings/components/settings_error_dialog.dart';
import 'package:resqapp/pages/settings/sections/change_username_confirmation_dialog.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resqapp/service/supabase_service.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'dart:developer' as developer;

class SettingsViewModel extends GetxController {
  final Rx<ResqUser?> _user = Rx<ResqUser?>(null);
  ResqUser? get user => _user.value;
  final theme = ResQTheme();

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

  void validateUsername(String username) {
    final trimmedUsername = username.trim();
    final RegExp alphaHyphen = RegExp(r'^[a-zA-Z-]+$');
    if (trimmedUsername.length >= 3 && alphaHyphen.hasMatch(trimmedUsername)) {
      showUsernameConfirmationDialog(trimmedUsername);
    } else {
      Get.snackbar(
        'Username tidak valid',
        'Username harus minimal 3 karakter dan berupa huruf',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
        animationDuration: Duration(milliseconds: 500),
        backgroundColor: theme.colors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> showUsernameConfirmationDialog(String newUsername) async {
    final result = await Get.dialog<bool>(
      ConfirmationDialog(
        onConfirm: () {
          Get.back(result: true);
        },
        title: 'Konfirmasi perubahan nama',
        caption: 'Apakah kamu yakin ingin mengubah nama?',
      ),
    );

    if (result == true) {
      await updateUsername(newUsername);
    }
    isEditingUsername.value = false;
  }

  Future<void> updateContact(int index, String? number) async {
    if (user == null) return;

    final contactName = 'Contact ${index + 1}';

    if (number == null || number.isEmpty) {
      final success = await SupabaseService.deleteContact(
        user!.userId,
        contactName,
      );
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

  void validateAndSaveContact(
    int index,
    String rawNumber,
    Function() onSuccess,
  ) {
    String newNumber = rawNumber.trim();

    if (newNumber.startsWith('+')) {
      newNumber = newNumber.substring(1);
    }

    if (newNumber.startsWith('0')) {
      newNumber = '62${newNumber.substring(1)}';
    } else if (!newNumber.startsWith('62')) {
      newNumber = '62$newNumber';
    }

    bool isValidLength = newNumber.length >= 12;

    if (!isValidLength) {
      Get.dialog(
        const SettingsErrorDialog(
          icon: Icons.warning_rounded,
          title: 'Nomor tidak valid',
          description: 'Nomor telepon harus minimal 10 digit',
        ),
      );
      return;
    }

    for (int i = 0; i < contactNumbers.length; i++) {
      if (i != index && contactNumbers[i] == newNumber) {
        Get.dialog(
          const SettingsErrorDialog(
            icon: Icons.copy_rounded,
            title: 'Nomor sudah terdaftar',
            description: 'Nomor ini sudah digunakan di kontak darurat lainnya.',
          ),
        );
        return;
      }
    }

    Get.dialog(
      ConfirmationDialog(
        onConfirm: () {
          updateContact(index, newNumber).then((_) {
            onSuccess();
            Get.back();
          });
        },
        title: 'Apakah kamu yakin?',
        caption:
            'Penekanan tombol SOS akan menyebabkan nomor telepon terhubung dengan pihak terkait.',
      ),
    );
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Get.deleteAll(force: true);
    Get.offAllNamed('/login');
  }
}
