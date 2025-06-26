// updated by Leo on 2025/05/19

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/utils/http_override.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/screens/welcome.dart';
import 'package:boostseller/screens/auth/login.dart';
import 'package:boostseller/screens/auth/register.dart';
import 'package:boostseller/screens/auth/forgot_password.dart';
import 'package:boostseller/screens/auth/send_otp.dart';
import 'package:boostseller/screens/auth/verification.dart';
import 'package:boostseller/screens/auth/change_password.dart';
import 'package:boostseller/screens/hostess/lead_list.dart';
import 'package:boostseller/screens/hostess/lead_detail.dart';
import 'package:boostseller/screens/hostess/add_lead.dart';
import 'package:boostseller/screens/performer/lead_list.dart';
import 'package:boostseller/screens/performer/assigned_lead_detail.dart';
import 'package:boostseller/screens/notification/notification.dart';
import 'package:boostseller/providers/notification_provider.dart';
import 'package:boostseller/screens/performer/sales_stage.dart';
import 'package:boostseller/screens/performer/lead_completed.dart';
import 'package:boostseller/screens/performer/lead-closed.dart';
import 'package:boostseller/screens/auth/pendding_approval.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/services/firebase_notification_service.dart';
import 'package:boostseller/screens/splash_screen.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseNotificationService.initFCM();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token') ?? '';
  final isApproved = prefs.getBool('isApproved') ?? false;
  final role = prefs.getString('userRole')?.toLowerCase();
  final userProvider = UserProvider();
  await userProvider.loadUser();
  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage();
  final isLoggedIn = token.isNotEmpty;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoadingProvider()),
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => languageProvider),
      ],
      child: BoostSellerApp(
        isLoggedIn: isLoggedIn,
        isApproved: isApproved,
        role: role,
      ),
    ),
  );
}

class BoostSellerApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? role;
  final bool isApproved;

  const BoostSellerApp({
    super.key,
    required this.isLoggedIn,
    required this.isApproved,
    required this.role,
  });

  @override
  State<BoostSellerApp> createState() => _BoostSellerAppState();
}

class _BoostSellerAppState extends State<BoostSellerApp> {
  @override
  void initState() {
    super.initState();
  }

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
        '/add-lead': (context) => AddLeadScreen(),
        '/sales-stage': (context) => SalesStageScreen(),
        '/lead-completed': (context) => LeadCompletedScreen(),
        '/lead-closed': (context) => LeadClosedScreen(),
        '/pendding-approval': (context) => ApproveScreen(),
      },

      // home:
      //     widget.isLoggedIn
      //         ? (widget.isApproved
      //             ? getRolePage(widget.role, context)
      //             : const ApproveScreen())
      //         : const WelcomeScreen(),
      home: const CustomSplashScreen(),
    );
  }
}

Widget getRolePage(String? role, BuildContext context) {
  switch (role) {
    case 'hostess':
      return HostessDashboardScreen();
    case 'performer':
      return const PerformerDashboardScreen();
    default:
      return const WelcomeScreen(); // fallback if role is invalid or missing
  }
}
