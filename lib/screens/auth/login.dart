// Login Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/widgets/custom_input_text.dart';
import 'package:boostseller/widgets/custom_password_field.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/widgets/exit_dialog.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:boostseller/providers/user_provider.dart';
import 'package:boostseller/model/user_model.dart';
import 'package:boostseller/services/firebase_notification_service.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> saveIsApproved(bool isApproved) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isApproved', isApproved);
  }

  void reset() {
    emailController.clear();
    pwdController.clear();
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    loadingProvider.setLoading(true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String selectedLangCode = languageProvider.languageCode;
    final api = ApiService();
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole')?.toLowerCase() ?? '';
    final fcmToken = await FirebaseNotificationService().getDeviceToken();
    if (role.isEmpty) {
      ToastUtil.error(getText("role_empty_message", selectedLangCode));
      await Future.delayed(Duration(seconds: 1));
      NavigationService.pushReplacementNamed('/onboarding');
    }
    try {
      final response = await api.post('/api/auth/login', {
        'email': email,
        'password': password,
        'fcmToken': fcmToken,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (role == jsonData['user']['role']) {
          final user = UserModel.fromJson(jsonData['user']);
          userProvider.setUser(user);
          await saveToken(jsonData['token']);
          await saveIsApproved(user.isApproved);
          if (user.isApproved) {
            ToastUtil.success(
              getText("login_success_message", selectedLangCode),
            );
            if (user.role == 'hostess') {
              NavigationService.pushReplacementNamed('/hostess-dashboard');
            } else if (user.role == 'performer') {
              NavigationService.pushReplacementNamed('/performer-dashboard');
            }
          } else {
            ToastUtil.info(getText("pendding_message", selectedLangCode));
            NavigationService.pushReplacementNamed('/pendding-approval');
          }
        } else {
          ToastUtil.error(getText("role_invalid_message", selectedLangCode));
          await Future.delayed(Duration(seconds: 1));
          NavigationService.pushReplacementNamed('/onboarding');
        }
      } else {
        if (jsonData['message'] == 'user-not-found') {
          ToastUtil.error(getText("user_not_found_message", selectedLangCode));
        } else if (jsonData['message'] == 'password-mismatch') {
          ToastUtil.error(
            getText("password_mismatch_message", selectedLangCode),
          );
        }
        reset();
      }
    } catch (e) {
      debugPrint('Error: $e');
      ToastUtil.error(getText("ajax_error_message", selectedLangCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  void handleLogin() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    String selectedLangCode = languageProvider.languageCode;

    final email = emailController.text.trim();
    final password = pwdController.text.trim();

    if (email.isEmpty) {
      ToastUtil.error(getText("email_empty_message", selectedLangCode));
    } else if (!isValidEmail(email)) {
      ToastUtil.error(getText("email_invalid_message", selectedLangCode));
    } else if (!isValidPassword(password)) {
      ToastUtil.error(getText("password_invalid_message", selectedLangCode));
    } else {
      loginUser(email: email, password: password);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final loadingProvider = Provider.of<LoadingProvider>(context);
    String langCode = context.watch<LanguageProvider>().languageCode;
    return BackOverrideWrapper(
      onBack: () async {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('userRole')?.toLowerCase() ?? '';
        if (role.isNotEmpty) {
          await ExitDialog.show();
        } else {
          NavigationService.pushReplacementNamed('/onboarding');
        }
      },
      child: LoadingOverlay(
        isLoading: loadingProvider.isLoading,
        child: Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final role = prefs.getString('userRole')?.toLowerCase() ?? '';
                  if (role.isNotEmpty) {
                    await ExitDialog.show();
                  } else {
                    NavigationService.pushReplacementNamed('/onboarding');
                  }
                },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Config.activeButtonColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back,
                    size: Config.appBarBackIconSize,
                    color: Config.iconDefaultColor,
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.04),
                  // Logo
                  Image.asset('assets/logo_dark.png', height: height * 0.2),
                  SizedBox(height: height * 0.04), // add more breathing space
                  // Welcome Text
                  Text(
                    // 'Welcome',
                    getText('Welcome', langCode),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // 'Login to your account',
                    getText('Login to your account', langCode),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Config.subTitleFontSize,
                      color: Config.subTitleFontColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      // 'Email',
                      getText('Email', langCode),
                      style: TextStyle(
                        color: Config.inputLabelColor,
                        fontSize: Config.inputLabelFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: emailController,
                    // hint: 'Email',
                    hint: getText('Email', langCode),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 6),

                  // Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      // 'Password',
                      getText('Password', langCode),
                      style: TextStyle(
                        color: Config.inputLabelColor,
                        fontSize: Config.inputLabelFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // PasswordField(controller: pwdController, hint: 'Passwrod'),
                  PasswordField(
                    controller: pwdController,
                    hint: getText('Password', langCode),
                  ),
                  const SizedBox(height: 20),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: EffectButton(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/forgot-password',
                        );
                      },
                      child: Text(
                        // 'Forgot Password?',
                        getText('Forgot Password?', langCode),
                        style: TextStyle(color: Config.stressColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: EffectButton(
                      onTap: handleLogin,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Config.activeButtonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            // 'Login',
                            getText('Login', langCode),
                            style: TextStyle(
                              fontSize: Config.buttonTextFontSize,
                              color: Config.buttonTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // "Don’t have account? ",
                        getText('Don’t have account?', langCode),
                        style: TextStyle(color: Colors.white38),
                      ),
                      SizedBox(width: 10),
                      EffectButton(
                        onTap: () {
                          NavigationService.pushReplacementNamed('/register');
                        },
                        child: Text(
                          // "Create Now",
                          getText('Create Now', langCode),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
