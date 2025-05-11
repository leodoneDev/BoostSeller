// updated by Leo on 2025/05/07

import 'package:boostseller/providers/loading.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:boostseller/screens/welcome.dart';
import 'package:boostseller/screens/lead/hostess/lead_list.dart';
import 'package:boostseller/screens/lead/performer/lead_list.dart';
import 'package:boostseller/utils/http_override.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/screens/auth/login.dart';
import 'package:boostseller/screens/auth/register.dart';
import 'package:boostseller/screens/auth/forgot_password.dart';
import 'package:boostseller/screens/auth/send_otp.dart';
import 'package:boostseller/screens/auth/verification.dart';
import 'package:boostseller/screens/auth/change_password.dart';
import 'package:boostseller/screens/lead/performer/detail/assigned_lead_detail.dart';
import 'package:boostseller/screens/lead/hostess/lead_detail.dart';
import 'package:boostseller/screens/notification/notification.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:provider/provider.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token') ?? '';
  final role = prefs.getString('userRole')?.toLowerCase();
  final isLoggedIn = token.isNotEmpty;
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LoadingProvider())],
      child: BoostSellerApp(isLoggedIn: isLoggedIn, role: role),
    ),
  );
}

class BoostSellerApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const BoostSellerApp({
    super.key,
    required this.isLoggedIn,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoostSeller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF2C2C2C),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: '/',
      routes: {
        '/onboarding': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/performer-dashboard': (context) => PerformerDashboardScreen(),
        '/hostess-dashboard': (context) => HostessDashboardScreen(),
        '/send-otp': (context) => SendOTPScreen(),
        '/verification': (context) => VerificationScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/performer-assigned-lead-detail':
            (context) => AssignedLeadDetailScreen(),
        '/hostess-lead-detail': (context) => HostessLeadDetailScreen(),
        '/notifications': (context) => NotificationPage(),
      },
      home: isLoggedIn ? getRolePage(role) : const WelcomeScreen(),
    );
  }
}

Widget getRolePage(String? role) {
  switch (role) {
    case 'hostess':
      return HostessDashboardScreen();
    case 'performer':
      return const PerformerDashboardScreen();
    default:
      return const WelcomeScreen(); // fallback if role is invalid or missing
  }
}
