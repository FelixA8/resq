import 'package:flutter/material.dart';
import '../components/username_field.dart';

class UsernameInputSection extends StatelessWidget {
  final String username;
  final ValueChanged<String> onUsernameChanged;
  final bool isValid;

  const UsernameInputSection({
    Key? key,
    required this.username,
    required this.onUsernameChanged,
    required this.isValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Pengguna',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nama anda akan digunakan untuk mengidentifikasikan diri anda pada fitur-fitur aplikasi.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
        UsernameField(
          value: username,
          onChanged: onUsernameChanged,
          isValid: isValid,
        ),
      ],
    );
  }
}
