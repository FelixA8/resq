import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/LoginPage/LoginPageViewModel.dart';
import 'pages/LoginPage/LoginPageView.dart';
import 'pages/otp/otpView.dart';
import 'pages/ResponseLoginPage/ResponseLoginPageView.dart';

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
      home: ChangeNotifierProvider(
        create: (_) => LoginPageViewModel(),
        child: const LoginPageView(),
      ),
      routes: {
        '/otpView': (context) {
          // Get arguments from Navigator
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final phone = args?['phone'] ?? '';
          return OTPView(phoneNumber: phone);
        },
        '/responseLogin': (context) => const ResponseLoginPageView(),
      },
    );
  }
}
