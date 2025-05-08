// OTP Verification page : made and update by Leo on 2025/05/07

import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/constants.dart';
import 'package:boostseller/services/api.services.dart';
import 'dart:convert';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/screens/auth/change.password.dart';

class VerificationScreen extends StatefulWidget {
  final int otpType;
  final int verifyType;
  final String email;
  final String phoneNumber;

  const VerificationScreen({
    super.key,
    required this.otpType,
    required this.verifyType,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  void sendVerifyCode({
    required BuildContext context,
    required String otpCode,
    required String email,
  }) async {
    setState(() => _isLoading = true);
    final api = ApiService();
    // final token = getAuthToken();
    try {
      final response = await api.post(context, '/api/auth/verify-otp', {
        'code': otpCode,
        'email': email,
        // 'token': token,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(jsonData['message']);
        if (widget.verifyType == 1) {
        } else if (widget.verifyType == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordScreen(email: email),
            ),
          );
        }
      } else {
        ToastUtil.error(jsonData['message']);
      }
    } catch (e) {
      ToastUtil.error("Server not found. Please try again");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void handleVerify(BuildContext context) {
    final otpCode = getOtpCode();
    sendVerifyCode(context: context, otpCode: otpCode, email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Config.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Config.appbarColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(0),
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
              const SizedBox(height: 16),
              const Text(
                'Verification',
                style: TextStyle(
                  fontSize: Config.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Config.titleFontColor,
                ),
              ),
              if (widget.otpType == 1) ...[
                const SizedBox(height: 6),
                const Text(
                  'Please enter the verification code sent \n to your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Config.subTitleFontSize,
                    color: Config.subTitleFontColor,
                  ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email OTP',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                const Text(
                  'Please enter the verification code sent \n to your phone number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Config.subTitleFontSize,
                    color: Config.subTitleFontColor,
                  ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mobile OTP',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _buildOtpRow(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: EffectButton(
                  onTap: () => handleVerify(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Config.activeButtonColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        'Verify',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "If you didn't receive a code,",
                    style: TextStyle(
                      color: Config.guideTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  EffectButton(
                    onTap: () {
                      // TODO: Implement resend
                    },
                    child: const Text(
                      "Resend",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 44,
          child: TextField(
            controller: _otpControllers[index],
            maxLength: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
