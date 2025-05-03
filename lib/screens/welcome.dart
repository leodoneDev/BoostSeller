// Welcome Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/screens/auth/login.dart';
import 'package:boostseller/widgets/button.effect.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: height * 0.08), // Top padding
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    height: height * 0.2, // 12% of screen height
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: height * 0.08,
                  ), // Space between logo and roles
                  // Role selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EffectButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => LoginScreen(role: 'hostess'),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/hostess.png',
                              height: height * 0.15,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      SizedBox(width: width * 0.1),

                      // Performer
                      EffectButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => LoginScreen(role: 'performer'),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/performer.png',
                              height: height * 0.15,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.08), // Bottom breathing space
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
