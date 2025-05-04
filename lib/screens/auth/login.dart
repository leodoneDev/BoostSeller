// Login Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/screens/auth/register.dart';
import 'package:boostseller/screens/auth/forgot.password.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/constants.dart';
import 'package:boostseller/widgets/custom.input.text.dart';
import 'package:boostseller/widgets/custom.password.field.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();

  void handleLogin() {
    final email = emailController.text.trim();
    final password = pwdController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email.")));
    } else if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
    } else if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters."),
        ),
      );
    } else {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder:
      //         (context) => VerificationScreen(role: widget.role, email: email),
      //   ),
      // );
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
          onPressed: () => Navigator.pop(context),
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
              Image.asset('assets/logo.png', height: height * 0.2),
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
                          builder:
                              (context) => RegisterScreen(role: widget.role),
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
