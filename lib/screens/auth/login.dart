// Login Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/screens/auth/register.dart';
import 'package:boostseller/screens/auth/forgot.password.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/constants.dart';
import 'package:boostseller/widgets/custom.input.text.dart';
import 'package:boostseller/widgets/custom.password.field.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/services/api.services.dart';
import 'dart:convert';
import 'package:boostseller/screens/lead/hostess/lead.list.dart';
import 'package:boostseller/screens/lead/performer/lead.list.dart';
import 'package:boostseller/screens/welcome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  void loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final api = ApiService();
    String? role = await getUserRole();
    if ((role == '') && (role == null)) {
      showToast(
        context,
        "Your role do not selected.\n Please your select role.",
        isError: true,
      );
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
    try {
      final response = await api.post(context, '/api/auth/login', {
        'email': email,
        'password': password,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        if (role == jsonData['user']['role']) {
          showToast(context, jsonData['message']);
          if (jsonData['user']['role'] == 'hostess') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeadListScreen()),
            );
          } else if (jsonData['user']['role'] == 'performer') {
            await Future.delayed(Duration(seconds: 1));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeadAssignedScreen()),
            );
          }
        } else {
          showToast(
            context,
            "This is not your role.\n Please select your correct role.",
            isError: true,
          );
          await Future.delayed(Duration(seconds: 1));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      } else {
        showToast(context, jsonData['message'], isError: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      showToast(context, "Server not found. Please try again", isError: true);
    }
  }

  void handleLogin() {
    final email = emailController.text.trim();
    final password = pwdController.text.trim();

    if (email.isEmpty) {
      showToast(context, "Please enter a email.", isError: true);
    } else if (!isValidEmail(email)) {
      showToast(context, "Please enter a valid email.", isError: true);
    } else if (!isValidPassword(password)) {
      showToast(
        context,
        "Password must be at least 6 characters.",
        isError: true,
      );
    } else {
      loginUser(context: context, email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Config.backgroundColor,
      appBar: AppBar(
        backgroundColor: Config.appbarColor,
        elevation: 0,
        leading: IconButton(
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
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
              // Logo
              Image.asset('assets/logo.ico', height: height * 0.2),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
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
    );
  }
}
