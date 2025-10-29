import 'package:flutter/material.dart';
import 'package:resqapp/pages/LoginPage/lower_case_view_model.dart';
import 'package:resqapp/pages/OTP/otp_view.dart';
import 'package:resqapp/pages/userMap/userMapView.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/LoginPage/login_page_view.dart';
import 'pages/ResponseLoginPage/ResponseLoginPageView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? "",
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? "",
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
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final phone = args?['phone'] ?? '';
          return OTPView(phoneNumber: phone);
        },
        '/usermapview': (context) {
          return UserMapView();
        },
        '/responseLogin': (context) => const ResponseLoginPageView(),
      },
    );
  }
}
