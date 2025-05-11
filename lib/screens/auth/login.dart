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
import 'package:boostseller/providers/loading.provider.dart';

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
    final api = ApiService();
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole')?.toLowerCase() ?? '';
    if (role.isEmpty) {
      ToastUtil.error("Your role do not selected.\nPlease your select role.");
      await Future.delayed(Duration(seconds: 1));
      NavigationService.pushReplacementNamed('/onboarding');
    }
    try {
      final response = await api.post('/api/auth/login', {
        'email': email,
        'password': password,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (role == jsonData['user']['role']) {
          ToastUtil.success(jsonData['message']);
          await saveToken(jsonData['token']);
          if (jsonData['user']['role'] == 'hostess') {
            NavigationService.pushReplacementNamed('/hostess-dashboard');
          } else if (jsonData['user']['role'] == 'performer') {
            await Future.delayed(Duration(seconds: 1));
            NavigationService.pushReplacementNamed('/performer-dashboard');
          }
        } else {
          ToastUtil.error(
            "This is not your role.\n Please select your correct role.",
          );
          await Future.delayed(Duration(seconds: 1));
          NavigationService.pushReplacementNamed('/onboarding');
        }
      } else {
        ToastUtil.error(jsonData['message']);
        reset();
      }
    } catch (e) {
      ToastUtil.error("Server not found.\nPlease try again");
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  void handleLogin() {
    final email = emailController.text.trim();
    final password = pwdController.text.trim();

    if (email.isEmpty) {
      ToastUtil.error("Please enter a email.");
    } else if (!isValidEmail(email)) {
      ToastUtil.error("Please enter a valid email.");
    } else if (!isValidPassword(password)) {
      ToastUtil.error("Password must be at least 6 characters.");
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
            leading: IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final role = prefs.getString('userRole')?.toLowerCase() ?? '';
                if (role.isNotEmpty) {
                  await ExitDialog.show();
                } else {
                  NavigationService.pushReplacementNamed('/onboarding');
                }
              },
              padding: const EdgeInsets.all(0),
              icon: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Config.activeButtonColor, // light blue
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: Config.iconDefaultColor,
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
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Login to your account',
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
                      'Email',
                      style: TextStyle(
                        color: Config.inputLabelColor,
                        fontSize: Config.inputLabelFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: emailController,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 6),

                  // Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Config.inputLabelColor,
                        fontSize: Config.inputLabelFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  PasswordField(controller: pwdController, hint: 'Passwrod'),

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
                      child: const Text(
                        'Forgot Password?',
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
                        child: const Center(
                          child: Text(
                            'Login',
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
                      const Text(
                        "Don’t have account? ",
                        style: TextStyle(color: Colors.white38),
                      ),
                      SizedBox(width: 10),
                      EffectButton(
                        onTap: () {
                          NavigationService.pushReplacementNamed('/register');
                        },
                        child: const Text(
                          "Create Now",
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
