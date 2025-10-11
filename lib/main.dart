import 'package:flutter/material.dart';
import 'package:resqapp/pages/userMap/userMapView.dart';
import 'pages/otp/otpView.dart';
import 'package:provider/provider.dart';
import 'pages/LoginPage/LoginPageViewModel.dart';
import 'pages/LoginPage/LoginPageView.dart';
import 'pages/ResponseLoginPage/ResponseLoginPageView.dart';
import 'pages/ReportDisaster/ReportDisasterView.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  
  //supabase initialization.
  await Supabase.initialize(
    url: "https://mirisslaptcomtnuuzeh.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pcmlzc2xhcHRjb210bnV1emVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwOTk1ODMsImV4cCI6MjA3NTY3NTU4M30.rkeON8pzcUCwxk4dxio36oAIUxp7oNxS7xQtR1p0pOc",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/usermapview': (context) {
          return UserMapView();
        },
        '/responseLogin': (context) => const ResponseLoginPageView(),
        '/reportDisaster': (context) => const ReportDisasterView(),
      },
    );
  }
}
