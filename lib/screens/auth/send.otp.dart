// Send OTP Page : made by Leo on 2025/05/04

import 'package:flutter/material.dart';
import 'package:boostseller/screens/auth/verification.dart';
import 'package:boostseller/widgets/button.effect.dart';

class SendOTPScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String role;

  const SendOTPScreen({
    super.key,
    required this.email,
    required this.phoneNumber,
    required this.role,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                VerificationScreen(role: widget.role, otpType: otpType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C3C3C),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF42A5F5),
            ),
            child: const Icon(Icons.arrow_back, size: 14, color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: height * 0.2),
              SizedBox(height: height * 0.04),

              const Text(
                'Verification',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                usePhone
                    ? 'Verify your phone number to continue \n We will send OTP to your phone number'
                    : 'Verify your email to continue \n We will send OTP to your email',
                style: const TextStyle(fontSize: 16, color: Colors.white60),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                      color: const Color(0xFF1E90FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        'Send OTP',
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
