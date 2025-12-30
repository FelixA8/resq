import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseLoginPage/response_login_page_view.dart';
import 'package:resqapp/pages/responseLoginPage/sections/response_login_form_section.dart';
import 'dart:developer' as developer;

import 'package:resqapp/pages/settings/settings_view.dart';
import 'package:resqapp/pages/otpPage/otp_view.dart';
import 'package:resqapp/pages/userMap/user_map_view.dart';
import 'package:resqapp/pages/splash/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/loginPage/login_page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    developer.log(
      'Please create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY',
    );
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? "";
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? "";

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  developer.log('Supabase client initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResQ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
        fontFamily: 'SF Pro',
      ),
      home: const SplashScreen(),

      //New Routing Method
      getPages: [
        GetPage(
          name: '/otpView',
          page: () {
            final args = Get.arguments as Map?;
            final phone = args?['phone'] ?? '';
            return OTPView(phoneNumber: phone);
          },
        ),
        GetPage(name: '/usermapview', page: () => UserMapView()),
      ],

      //Old Routing Method (Still need /login, hence do not delete).
      routes: {
        '/login': (context) => const LoginPageView(),
        '/responseLogin': (context) => const ResponseLoginPageView(),
        '/otpView': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final phone = args?['phone'] ?? '';
          return OTPView(phoneNumber: phone);
        },
        '/usermapview': (context) {
          return UserMapView();
        },
        '/settings': (context) => const SettingsView(),
      },
    );
  }
}
