import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/loginPage/lower_case_view_model.dart';
import 'package:resqapp/pages/otpPage/otp_view.dart';
import 'package:resqapp/pages/userMap/userMapView.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/loginPage/login_page_view.dart';
import 'pages/responseLoginPage/response_login_page_view.dart';

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
    return GetMaterialApp(
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
      getPages: [
        GetPage(
          name: '/otpView',
          page: () {
            final args = Get.arguments as Map?;
            final phone = args?['phone'] ?? '';
            return OTPView(phoneNumber: phone);
          },
        ),
        GetPage(
          name: '/usermapview',
          page: () => UserMapView(),
        ),
        GetPage(
          name: '/responseLogin',
          page: () => const ResponseLoginPageView(),
        ),
      ],
      // Keep MaterialApp routes for backward compatibility with other pages
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
