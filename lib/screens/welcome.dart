// Welcome Page : made by Leo on 2025/04/30

import 'package:boostseller/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    Future<void> saveUserRole(String role) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', role);
    }

    return BackOverrideWrapper(
      onBack: () async {
        await ExitDialog.show();
      },

      child: Scaffold(
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
                    SizedBox(height: height * 0.06), // Top padding
                    // Logo
                    Image.asset(
                      'assets/logo_dark.png',
                      height: height * 0.2, // 12% of screen height
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: height * 0.06),
                    const Text(
                      'Please select your role!',
                      style: TextStyle(
                        fontSize: Config.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Config.subTitleFontColor,
                      ),
                    ),

                    SizedBox(
                      height: height * 0.06,
                    ), // Space between logo and roles
                    // Role selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EffectButton(
                          onTap: () {
                            saveUserRole('hostess');
                            NavigationService.pushReplacementNamed('/login');
                          },
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/hostess.png',
                                height: height * 0.15,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hostess',
                                style: TextStyle(
                                  fontSize: Config.subTitleFontSize,
                                  color: Config.subTitleFontColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: width * 0.1),

                        EffectButton(
                          onTap: () {
                            saveUserRole('performer');
                            NavigationService.pushReplacementNamed('/login');
                          },
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/performer.png',
                                height: height * 0.15,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Performer',
                                style: TextStyle(
                                  fontSize: Config.subTitleFontSize,
                                  color: Config.subTitleFontColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
      ),
    );
  }
}
