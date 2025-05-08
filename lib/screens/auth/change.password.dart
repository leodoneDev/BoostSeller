// Change Password Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/custom.password.field.dart';
import 'package:boostseller/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/api.services.dart';
import 'dart:convert';
import 'package:boostseller/screens/auth/login.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  const ChangePasswordScreen({super.key, required this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void changePassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    setState(() => _isLoading = true);
    final api = ApiService();
    // final token = getAuthToken();
    try {
      final response = await api.post(context, '/api/auth/change-password', {
        'email': email,
        "password": password,
        // 'token': token,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(context, jsonData['message']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ToastUtil.error(context, jsonData['message']);
      }
    } catch (e) {
      ToastUtil.error(context, "Server not found. Please try again");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void handleChangePwd() {
    final password = newPasswordController.text.trim();
    final passwordConfirm = confirmPasswordController.text.trim();

    if (isValidPassword(password)) {
      if (password == passwordConfirm) {
        // ToastUtil.success(context, "Successfully passwrod changed!");
        changePassword(
          context: context,
          email: widget.email,
          password: password,
        );
      } else {
        ToastUtil.error(context, "Passwords do not match.");
      }
    } else {
      ToastUtil.error(context, "Password must be at least 6 characters.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              SizedBox(height: height * 0.04),
              // Logo
              Image.asset('assets/logo_dark.png', height: height * 0.18),
              const SizedBox(height: 20),

              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: Config.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Config.titleFontColor,
                ),
              ),

              const SizedBox(height: 30),

              _buildLabel('Enter your new password'),
              const SizedBox(height: 6),
              PasswordField(
                controller: newPasswordController,
                hint: 'Password',
              ),
              _buildLabel('Enter your confirmation password'),
              const SizedBox(height: 6),
              PasswordField(
                controller: confirmPasswordController,
                hint: 'Password Confirm',
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: EffectButton(
                  onTap: handleChangePwd,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Config.activeButtonColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: Config.buttonTextFontSize,
                          color: Config.buttonTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
