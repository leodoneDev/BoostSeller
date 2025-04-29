import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('assets/logo.png', height: isSmall ? 80 : 120),
                const SizedBox(height: 12),
                const SizedBox(height: 60),
                // Role Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hostess
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to Hostess screen
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/hostess.png',
                            height: isSmall ? 60 : 80,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50),
                    // Performer
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to Performer screen
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/performer.png',
                            height: isSmall ? 60 : 80,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
