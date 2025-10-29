import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final theme = ResQTheme();
  bool isEditing = false;
  String username = 'Budiman Setianto';
  String previousUsername = 'Budiman Setianto';
  final phone = '+62 81338327789';
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = username;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showSaveConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Username Change'),
        content: Text('Are you sure you want to change your username to "${_controller.text}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
    if (result == true) {
      setState(() {
        username = _controller.text;
        isEditing = false;
      });
    } else {
      setState(() {
        _controller.text = previousUsername;
        isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEditing
            ? Color(0xFFF1C8C8)
            : Color(theme.colors.primary),
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
                    backgroundColor: Color(theme.colors.primary),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 1),
                    minimumSize: Size(0, 35),
                  ),
                  onPressed: () {
                    _showSaveConfirmation();
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
                    setState(() {
                      isEditing = true;
                      previousUsername = username;
                      _controller.text = username;
                    });
                    Future.delayed(Duration(milliseconds: 100), () {
                      _focusNode.requestFocus();
                    });
                  },
                  icon: Icon(Icons.edit, color: Color(theme.colors.primary)),
                  label: Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(theme.colors.primary),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
