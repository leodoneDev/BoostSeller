// Change Password Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/custom.password.field.dart';
import 'package:boostseller/constants.dart';
import 'package:boostseller/utils/toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void handleChangePwd() {
    final password = newPasswordController.text.trim();
    final passwordConfirm = confirmPasswordController.text.trim();

    if (isValidPassword(password)) {
      if (password == passwordConfirm) {
        showToast(context, "Successfully passwrod changed!");
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
              // Logo
              Image.asset('assets/logo.png', height: height * 0.18),
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
