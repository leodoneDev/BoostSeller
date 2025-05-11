// Change Password Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/custom_password_field.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/services/navigation_services.dart';

class ChangePasswordScreen extends StatefulWidget {
  // final String email;
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void changePassword({
    required int otpType,
    required String address,
    required String password,
  }) async {
    setState(() => _isLoading = true);
    final api = ApiService();
    // final token = getAuthToken();
    try {
      final response = await api.post('/api/auth/change-password', {
        'otpType': otpType,
        'address': address,
        "password": password,
        // 'token': token,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(jsonData['message']);
        NavigationService.pushReplacementNamed('/login');
      } else {
        ToastUtil.error(jsonData['message']);
      }
    } catch (e) {
      ToastUtil.error("Server not found.\nPlease try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void handleChangePwd({required int otpType, required String address}) {
    final password = newPasswordController.text.trim();
    final passwordConfirm = confirmPasswordController.text.trim();

    if (isValidPassword(password)) {
      if (password == passwordConfirm) {
        changePassword(otpType: otpType, address: address, password: password);
      } else {
        ToastUtil.error("Passwords do not match.");
      }
    } else {
      ToastUtil.error("Password must be at least 6 characters.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    int otpType = args['otpType'];
    String address = args['address'];

    return BackOverrideWrapper(
      onBack: () {},
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
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
                      onTap:
                          () => handleChangePwd(
                            otpType: otpType,
                            address: address,
                          ),
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
