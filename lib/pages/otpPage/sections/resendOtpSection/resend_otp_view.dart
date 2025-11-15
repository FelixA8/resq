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
            color: Colors.black,
            fontFamily: 'SF Pro',
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: canResend ? onResendPressed : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove all padding
            minimumSize: Size(0, 0), // Remove min size
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
          ),
          child: Text(
            canResend ? 'Kirim Ulang Kode OTP' : 'Tunggu $timeLeft detik',
            style: TextStyle(
              color: canResend ? Color(0xFFB71C1C) : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'SF Pro',
            ),
          ),
        ),
      ],
    );
  }
}