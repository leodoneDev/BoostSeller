// Send OTP Page : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:boostseller/screens/auth/verification.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/constants.dart';

class SendOTPScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;

  const SendOTPScreen({
    super.key,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<SendOTPScreen> createState() => _SendOTPScreenState();
}

class _SendOTPScreenState extends State<SendOTPScreen> {
  bool usePhone = false;
  int otpType = 1;

  void handleSendVerifyOTP() {
    if (usePhone) {
      otpType = 2;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => VerificationScreen(
              otpType: otpType,
              email: widget.email,
              phoneNumber: widget.phoneNumber,
              verifyType: 1,
            ),
      ),
    );
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
                'Verification',
                style: TextStyle(
                  fontSize: Config.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Config.titleFontColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                usePhone
                    ? 'Verify your phone number to continue \n We will send OTP to your phone number'
                    : 'Verify your email to continue \n We will send OTP to your email',
                style: const TextStyle(
                  fontSize: Config.subTitleFontSize,
                  color: Config.subTitleFontColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Align(
                child: Text(
                  usePhone
                      ? 'Your phone number is ${widget.phoneNumber}'
                      : 'Your email is ${widget.email}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: Config.subTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: EffectButton(
                  onTap: handleSendVerifyOTP,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Config.activeButtonColor,
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
                  setState(() => usePhone = !usePhone);
                },
                child: Text(
                  usePhone ? 'Use Email Instead' : 'Use Phone Instead',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
