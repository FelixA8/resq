import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseLoginPage/response_login_page_view.dart';
import 'package:resqapp/pages/settings/SettingsView.dart';
import 'package:resqapp/pages/otpPage/otp_view.dart';
import 'package:resqapp/pages/userMap/user_map_view.dart';
import 'package:resqapp/pages/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'service/supabase_service.dart'; // Uncomment if using testConnection in main
import 'pages/loginPage/login_page_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('❌ Error loading .env file: $e');
    print(
      '🚨 Please create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY',
    );
  }

  // Initialize Supabase with environment variables
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? "";
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? "";

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('❌ Missing Supabase credentials in .env file');
    print('📋 Required: SUPABASE_URL and SUPABASE_ANON_KEY');
  } else {
    print('🔄 Initializing Supabase...');
    print('🌐 URL: ${supabaseUrl.substring(0, 20)}...');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  print('✅ Supabase client initialized successfully');
  print('📝 Note: Initialization only sets up the client.');
  print(
    '🌐 Actual network connectivity will be tested on first database operation.',
  );

  // Optional: Test connection immediately (comment out if you want lazy testing)
  // try {
  //   final connectionOk = await SupabaseService.testConnection();
  //   if (connectionOk) {
  //     print('✅ Network connection to Supabase verified');
  //   }
  // } catch (e) {
  //   print('⚠️ Connection test skipped: $e');
  // }

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
        GetPage(
          name: '/responseLogin',
          page: () => const ResponseLoginPageView(),
        ),
      ],
      // Keep MaterialApp routes for backward compatibility with other pages
      routes: {
        '/login': (context) => const LoginPageView(),
        '/otpView': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          final phone = args?['phone'] ?? '';
          return OTPView(phoneNumber: phone);
        },
        '/usermapview': (context) {
          return UserMapView();
        },
        '/responseLogin': (context) => const ResponseLoginPageView(),
        '/settings': (context) => const SettingsView(),
      },
    );
  }
}
