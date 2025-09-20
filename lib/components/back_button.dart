import 'package:flutter/material.dart';

// TODO: Change the back button icon

class CustomBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/icons/back-left.png',
        width: 24,
        height: 24,
        color: Colors.red,
      ),
      onPressed: onPressed,
    );
  }
}
