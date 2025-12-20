import 'package:flutter/material.dart';

class SettingsCancelButton extends StatelessWidget {
  final Function() onCancel;
  const SettingsCancelButton({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey, // Use theme primary color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
        minimumSize: const Size(0, 35),
      ),
      onPressed: onCancel,
      child: const Text(
        'Batal',
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}
