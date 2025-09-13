import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/OTP/otpView.dart'; // <-- Update this line

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
        fontFamily: 'SF Pro',
      ),
      home: const LoginPage(),
      routes: {
        '/otpView': (context) {
          // Get arguments from Navigator
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final phone = args?['phone'] ?? '';
          return OTPView(phoneNumber: phone);
        },
      },
    );
  }
}
