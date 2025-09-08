import 'package:flutter/material.dart';

class ResendOTPSection extends StatelessWidget {
  final int timeLeft;
  final VoidCallback onResendPressed;
  final bool canResend;

  const ResendOTPSection({
    Key? key,
    required this.timeLeft,
    required this.onResendPressed,
    required this.canResend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tidak menerima kode OTP anda?',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: canResend ? onResendPressed : null,
          child: Text(
            canResend ? 'Kirim Ulang Kode OTP' : 'Tunggu $timeLeft detik',
            style: TextStyle(
              color: canResend ? Colors.red : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}