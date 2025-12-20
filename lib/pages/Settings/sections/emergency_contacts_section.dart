import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';
import '../settings_view_model.dart';

class EmergencyContactsSection extends StatefulWidget {
  const EmergencyContactsSection({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsSection> createState() =>
      _EmergencyContactsSectionState();
}

class _EmergencyContactsSectionState extends State<EmergencyContactsSection> {
  final theme = ResQTheme();
  final List<bool> isEditing = [false, false, false];
  final List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<FocusNode> focusNodes = [FocusNode(), FocusNode(), FocusNode()];

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<SettingsViewModel>();
    // final phoneNumbers = viewModel.contactNumbers; // Accessed inside Obx

    final phoneIcons = [
      'assets/images/icons/phone-one.png',
      'assets/images/icons/phone-two.png',
      'assets/images/icons/phone-three.png',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontak Darurat',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Obx(() {
          final phoneNumbers = viewModel.contactNumbers;
          return Column(
            children: List.generate(3, (index) {
              final isFilled = phoneNumbers[index] != null;
              final isEdit = isEditing[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (isEdit) {
                      setState(() {
                        controllers[index].text = phoneNumbers[index] ?? '';
                        isEditing[index] = false;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          if (!isEdit)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    phoneIcons[index],
                                    width: 28,
                                    height: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 2,
                                    height: 28,
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: isEdit ? 16 : 2,
                                right: 2,
                              ),
                              child:
                                  isEdit
                                      ? TextField(
                                        controller: controllers[index],
                                        focusNode: focusNodes[index],
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: theme.colors.primary,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '',
                                        ),
                                        keyboardType:
                                            Platform.isIOS
                                                ? const TextInputType.numberWithOptions(
                                                  signed: true,
                                                  decimal: true,
                                                )
                                                : TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        cursorColor: theme.colors.primary,
                                        onTap: () {
                                          controllers[index].selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset:
                                                      controllers[index]
                                                          .text
                                                          .length,
                                                ),
                                              );
                                        },
                                      )
                                      : Text(
                                        isFilled
                                            ? phoneNumbers[index]!
                                            : 'Tambahkan Nomor Telepon',
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color:
                                              isFilled
                                                  ? Colors.black
                                                  : Color(0xFF9E9E9E),
                                        ),
                                      ),
                            ),
                          ),
                          isEdit
                              ? TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      theme
                                          .colors
                                          .primary, // Use theme primary color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 1,
                                  ),
                                  minimumSize: Size(0, 35),
                                ),
                                onPressed: () async {
                                  String newNumber =
                                      controllers[index].text.trim();

                                  // Remove any leading + if present
                                  if (newNumber.startsWith('+')) {
                                    newNumber = newNumber.substring(1);
                                  }

                                  // Convert leading 0 to 62
                                  if (newNumber.startsWith('0')) {
                                    newNumber = '62${newNumber.substring(1)}';
                                  }
                                  // Add 62 prefix if it doesn't already start with 62
                                  else if (!newNumber.startsWith('62')) {
                                    newNumber = '62$newNumber';
                                  }

                                  // Validate: must be at least 12 characters (62 + 10 digits minimum)
                                  bool isValid = newNumber.length >= 12;

                                  if (!isValid) {
                                    Get.dialog(
                                      Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        elevation: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.warning_rounded,
                                                  size: 40,
                                                  color: Colors.red.shade400,
                                                ),
                                              ),
                                              const SizedBox(height: 20),

                                              // Title
                                              const Text(
                                                'Nomor tidak valid',
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1A1A1A),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 12),

                                              // Main message
                                              const Text(
                                                'Nomor telepon harus minimal 10 digit',
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 16,
                                                  color: Color(0xFF666666),
                                                  height: 1.4,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // Save the contact with 62 prefix
                                  await viewModel.updateContact(
                                    index,
                                    newNumber,
                                  );

                                  // Exit edit mode
                                  setState(() {
                                    isEditing[index] = false;
                                  });
                                },
                                child: Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              : IconButton(
                                icon: Image.asset(
                                  'assets/images/icons/edit.png',
                                  width: 22,
                                  height: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    for (int i = 0; i < isEditing.length; i++) {
                                      isEditing[i] = false;
                                    }
                                    isEditing[index] = true;
                                    if (phoneNumbers[index] == null) {
                                      controllers[index].text = '';
                                    } else {
                                      controllers[index].text =
                                          phoneNumbers[index]!;
                                    }
                                  });
                                  Future.delayed(
                                    Duration(milliseconds: 100),
                                    () {
                                      focusNodes[index].requestFocus();
                                      controllers[index].selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  controllers[index]
                                                      .text
                                                      .length,
                                            ),
                                          );
                                    },
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
