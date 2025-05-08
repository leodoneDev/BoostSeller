// Register Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';

import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/custom_input_text.dart';
import 'package:boostseller/widgets/custom_phone_field.dart';
import 'package:boostseller/widgets/custom_password_field.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/screens/auth/login.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/loading.provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final TextEditingController pwdConfirmController = TextEditingController();
  String phoneNumber = '';
  String role = '';

  void reset() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    pwdController.clear();
    pwdConfirmController.clear();
  }

  void registerUser({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String phone,
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
      ToastUtil.error("Your role do not selected. Please your select role.");
      NavigationService.pushReplacementNamed('/onboarding');
    }
    try {
      final response = await api.post('/api/auth/register', {
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'password': password,
        'role': role,
      });

      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (!mounted) return;
        ToastUtil.success(jsonData['message']);
        NavigationService.pushReplacementNamed('/login');
      } else {
        ToastUtil.error(jsonData['message']);
        reset();
      }
    } catch (e) {
      ToastUtil.error("Server not found. Please try again");
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  void handleRegister() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = pwdController.text.trim();
    final passwordConfirm = pwdConfirmController.text.trim();
    final phone = phoneController.text.trim();
    if ((name.isNotEmpty) &&
        (email.isNotEmpty) &&
        (phoneNumber.isNotEmpty) &&
        (password.isNotEmpty) &&
        (passwordConfirm.isNotEmpty) &&
        (phoneNumber.isNotEmpty) &&
        (phone.isNotEmpty)) {
      if (isValidEmail(email)) {
        if (isValidPassword(password)) {
          if (password == passwordConfirm) {
            registerUser(
              context: context,
              name: name,
              email: email,
              phone: phoneNumber,
              password: password,
            );
          } else {
            ToastUtil.error("Passwords do not match.");
          }
        } else {
          ToastUtil.error("Password must be at least 6 characters.");
        }
      } else {
        ToastUtil.error("Please enter a valid email.");
      }
    } else {
      ToastUtil.error("Please fill all fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final loadingProvider = Provider.of<LoadingProvider>(context);

    return BackOverrideWrapper(
      onBack: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      },
      child: LoadingOverlay(
        isLoading: loadingProvider.isLoading,
        child: Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
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
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.04),
                  // Logo
                  Image.asset('assets/logo_dark.png', height: height * 0.2),
                  SizedBox(height: height * 0.04),

                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create a new account',
                    style: TextStyle(
                      fontSize: Config.subTitleFontSize,
                      color: Config.subTitleFontColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Username
                  const SizedBox(height: 12),

                  // Email
                  _buildLabel('Name'),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: nameController,
                    hint: 'Name',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 6),
                  // Email
                  _buildLabel('Email'),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: emailController,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 6),
                  // Phone Number
                  _buildLabel('Phone Number'),
                  const SizedBox(height: 6),
                  CustomPhoneField(
                    controller: phoneController,
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                  ),

                  const SizedBox(height: 6),

                  // Password
                  _buildLabel('Password'),
                  const SizedBox(height: 6),
                  PasswordField(controller: pwdController, hint: 'Password'),

                  const SizedBox(height: 6),

                  // paswird confirm
                  _buildLabel('Password Confirm'),
                  const SizedBox(height: 6),
                  PasswordField(
                    controller: pwdConfirmController,
                    hint: 'Password Confirm',
                  ),

                  const SizedBox(height: 30),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: EffectButton(
                      onTap: handleRegister,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Config.activeButtonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Register',
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
                        "Already have account? ",
                        style: TextStyle(color: Config.guideTextColor),
                      ),
                      SizedBox(width: 10),
                      EffectButton(
                        onTap: () {
                          NavigationService.pushReplacementNamed('/login');
                        },

                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
