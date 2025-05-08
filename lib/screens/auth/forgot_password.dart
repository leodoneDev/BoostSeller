// Forgot Password Page : made by Leo on 2025/05/08

import 'package:boostseller/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/widgets/custom_phone_field.dart';
import 'package:boostseller/widgets/custom_input_text.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/api_services.dart';
import 'package:boostseller/utils/validation.dart';
import 'dart:convert';
import 'package:boostseller/screens/auth/verification.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool usePhone = false;
  int otpType = 1;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String fullPhoneNumber = '';
  bool _isLoading = false;

  void sendOTP({required BuildContext context, required String email}) async {
    setState(() => _isLoading = true);
    final api = ApiService();
    // final token = getAuthToken();
    try {
      final response = await api.post('/api/auth/send-otp', {'email': email});
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(jsonData['message']);
        if (usePhone) {
          otpType = 2;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => VerificationScreen(
                  otpType: otpType,
                  email: email,
                  phoneNumber: fullPhoneNumber,
                  verifyType: 2,
                ),
          ),
        );
      } else {
        ToastUtil.error(jsonData['message']);
      }
    } catch (e) {
      ToastUtil.error("Server not found. Please try again");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void handleSendOTP() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ToastUtil.error("Please enter a email.");
    } else if (!isValidEmail(email)) {
      ToastUtil.error("Please enter a valid email.");
    } else {
      sendOTP(context: context, email: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return BackOverrideWrapper(
      onBack: () {
        NavigationService.pushReplacementNamed('/login');
      },
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                NavigationService.pushReplacementNamed('/login');
              },
              padding: EdgeInsets.zero,
              icon: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Config.activeButtonColor,
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
                  Image.asset('assets/logo_dark.png', height: height * 0.2),
                  SizedBox(height: height * 0.04),

                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usePhone
                        ? 'Enter your phone number to reset password'
                        : 'Enter your email to reset password',
                    style: const TextStyle(
                      fontSize: Config.subTitleFontSize,
                      color: Config.subTitleFontColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      usePhone ? 'Phone Number' : 'Email',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 6),

                  usePhone
                      ? CustomPhoneField(
                        controller: phoneController,
                        onChanged: (value) {
                          fullPhoneNumber = value;
                        },
                      )
                      : CustomTextField(
                        controller: emailController,
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: EffectButton(
                      onTap: handleSendOTP,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E90FF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: Config.buttonTextFontSize,
                              color: Config.buttonTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  EffectButton(
                    onTap: () {
                      //setState(() => usePhone = !usePhone);
                      ToastUtil.success("Developing...");
                    },
                    child: Text(
                      usePhone ? 'Use Email Instead' : 'Use Phone Instead',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
