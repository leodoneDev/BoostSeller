import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/language_provider.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  String _status = "";

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _status = getText("Starting...", langCode);
    _startInitialization(langCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startInitialization(langCode) async {
    await _updateProgress(0.1, getText("Loading preferences...", langCode));
    final prefs = await SharedPreferences.getInstance();
    await _updateProgress(0.4, getText("Checking login token...", langCode));
    final token = prefs.getString('auth_token') ?? '';
    final isApproved = prefs.getBool('isApproved') ?? false;
    final role = prefs.getString('userRole')?.toLowerCase();
    await _updateProgress(0.6, getText("Initializaing firebase...", langCode));
    await Future.delayed(const Duration(milliseconds: 500));

    await _updateProgress(0.9, getText("Preparing data...", langCode));
    await Future.delayed(const Duration(milliseconds: 500));
    await _updateProgress(1.0, getText("Launching...", langCode));

    if (token.isNotEmpty) {
      if (isApproved) {
        Navigator.pushReplacementNamed(
          context,
          role == 'hostess' ? '/hostess-dashboard' : '/performer-dashboard',
        );
      } else {
        Navigator.pushReplacementNamed(context, '/pendding-approval');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  Future<void> _updateProgress(double value, String status) async {
    setState(() {
      _progress = value;
      _status = status;
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _controller,
                  child: Image.asset(
                    'assets/loader_ring.png',
                    width: 300,
                    height: 300,
                  ),
                ),
                Image.asset('assets/logo_dark.png', width: 200, height: 200),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'BoostSeller',
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 4,
                backgroundColor: Colors.white12,
                color: Colors.blueAccent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _status,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
