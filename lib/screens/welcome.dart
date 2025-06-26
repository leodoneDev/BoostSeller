// Welcome Page : made by Leo on 2025/04/30

import 'package:boostseller/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/language_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
  }

  // void _showLanguageSelector() {
  //   String langCode =
  //       Provider.of<LanguageProvider>(context, listen: false).languageCode;
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: const Color(0xFF444444),
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.language, color: Colors.white),
  //             title: Text(
  //               // 'English',
  //               getText('English', langCode),
  //               textAlign: TextAlign.center,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             onTap: () {
  //               Provider.of<LanguageProvider>(
  //                 context,
  //                 listen: false,
  //               ).setLanguage("en");
  //               Navigator.pop(context);
  //             },
  //           ),

  //           ListTile(
  //             leading: const Icon(Icons.language, color: Colors.white),
  //             title: Text(
  //               // 'Russian',
  //               getText('Russian', langCode),
  //               textAlign: TextAlign.center,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             onTap: () {
  //               Provider.of<LanguageProvider>(
  //                 context,
  //                 listen: false,
  //               ).setLanguage("ru");
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String langCode = context.watch<LanguageProvider>().languageCode;
    return BackOverrideWrapper(
      onBack: () async {
        await ExitDialog.show();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF333333),
        body: SafeArea(
          child: Stack(
            children: [
              // Language Button
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    final newLang =
                        languageProvider.languageCode == 'en' ? 'ru' : 'en';
                    languageProvider.setLanguage(newLang);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          languageProvider.languageCode.toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: height * 0.06),
                        Image.asset(
                          'assets/logo_dark.png',
                          height: height * 0.2,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: height * 0.06),
                        Text(
                          // 'Please select your role!',
                          getText('Please select your role!', langCode),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Config.subTitleFontColor,
                          ),
                        ),
                        SizedBox(height: height * 0.06),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EffectButton(
                              onTap: () {
                                saveUserRole('hostess');
                                NavigationService.pushReplacementNamed(
                                  '/login',
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
                                  Text(
                                    // 'Hostess',
                                    getText('Hostess', langCode),
                                    textAlign: TextAlign.center,
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
                                NavigationService.pushReplacementNamed(
                                  '/login',
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
                                  Text(
                                    // 'Sales Person',
                                    getText('Sales Person', langCode),
                                    textAlign: TextAlign.center,
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
                        SizedBox(height: height * 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
