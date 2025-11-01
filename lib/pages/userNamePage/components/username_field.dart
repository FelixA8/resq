import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool isValid;

  const UsernameField({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.isValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      // controller: TextEditingController(text: value),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorText: !isValid && value.isNotEmpty ? 'Invalid username' : null,
      ),
    );
  }
}
