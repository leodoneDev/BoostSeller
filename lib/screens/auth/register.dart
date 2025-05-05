// Register Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/screens/auth/send.otp.dart';
import 'package:boostseller/widgets/custom.input.text.dart';
import 'package:boostseller/widgets/custom.phone.field.dart';
import 'package:boostseller/widgets/custom.password.field.dart';
import 'package:boostseller/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/api.services.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

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

  void registerUser({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final api = ApiService();

    try {
      final response = await api.post('/api/auth/register', {
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'password': password,
      });

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        showToast(context, "Success");
      }
    } catch (e) {
      showToast(context, "error", isError: true);
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
            // showToast(context, "Successfully Sign Up!");
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder:
            //         (context) => SendOTPScreen(
            //           email: email,
            //           phoneNumber: phoneNumber,
            //           role: widget.role,
            //         ),
            //   ),
            // );
          } else {
            showToast(context, "Passwords do not match.", isError: true);
          }
        } else {
          showToast(
            context,
            "Password must be at least 6 characters.",
            isError: true,
          );
        }
      } else {
        showToast(context, "Please enter a valid email.", isError: true);
      }
    } else {
      showToast(context, "Please fill all fields.", isError: true);
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
                    onTap: () => Navigator.pop(context),
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
