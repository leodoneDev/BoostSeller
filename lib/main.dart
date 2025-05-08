// updated by Leo on 2025/05/07

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:boostseller/screens/welcome.dart';
import 'package:boostseller/screens/lead/hostess/lead.list.dart';
import 'package:boostseller/screens/lead/performer/lead.list.dart';
import 'package:boostseller/utils/http.override.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/screens/auth/login.dart';
import 'package:boostseller/screens/auth/register.dart';
import 'package:boostseller/screens/auth/forgot.password.dart';

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
  runApp(BoostSellerApp(isLoggedIn: isLoggedIn, role: role));
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
      initialRoute: '/',
      routes: {
        '/onboarding': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/performer-dashboard': (context) => PerformerDashboardScreen(),
        '/hostess-dashboard': (context) => HostessDashboardScreen(),
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
