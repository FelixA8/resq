import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/settings/components/settings_cancel_button.dart';
import 'package:resqapp/theme/theme_app.dart';
import '../settings_view_model.dart';
import '../components/emergency_settings_save_button.dart';

class EmergencyContactsSection extends StatefulWidget {
  const EmergencyContactsSection({super.key});

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
                              ? Row(
                                children: [
                                  EmergencySettingsSaveButton(
                                    onSave: () {
                                      viewModel.validateAndSaveContact(
                                        index,
                                        controllers[index].text,
                                        () {
                                          setState(() {
                                            isEditing[index] = false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  
                                  SizedBox(width: 4),
                                  
                                  SettingsCancelButton(
                                    onCancel: () {
                                      focusNodes[index].unfocus();
                                      setState(() {
                                        isEditing[index] = false;
                                      });
                                    },
                                  ),
                                ],
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
