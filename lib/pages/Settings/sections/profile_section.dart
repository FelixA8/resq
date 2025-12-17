import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';
import '../settings_view_model.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final theme = ResQTheme();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<SettingsViewModel>();

    return Obx(() {
      final username = viewModel.user?.username ?? 'Loading...';
      final phone = viewModel.user?.phoneNumber ?? 'Loading...';
      final isEditing = viewModel.isEditingUsername.value;

      if (!isEditing && _controller.text != username) {
        _controller.text = username;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEditing
              ? Color(0xFFF1C8C8)
              : theme.colors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isEditing
                      ? SizedBox(
                          height: 28, // Match static text height
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.black, // Black when editing
                              height: 1.0, // Match Text widget line height
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            cursorColor: Colors.black,
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        )
                      : Text(
                          username,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.white, // White when not editing
                          ),
                        ),
                  SizedBox(height: 3),
                  Text(
                    phone,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            isEditing
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 1),
                      minimumSize: Size(0, 35),
                    ),
                    onPressed: () {
                      viewModel.showUsernameConfirmationDialog(_controller.text);
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      minimumSize: Size(0, 35),
                    ),
                    onPressed: () {
                      viewModel.startEditingUsername();
                      _controller.text = username;
                      Future.delayed(Duration(milliseconds: 100), () {
                        _focusNode.requestFocus();
                      });
                    },
                    icon: Icon(Icons.edit, color: theme.colors.primary),
                    label: Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: theme.colors.primary,
                      ),
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
