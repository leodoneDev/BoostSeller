import 'package:flutter/material.dart';
import 'package:boostseller/screens/auth/change.password.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/widgets/custom.phone.field.dart';
import 'package:boostseller/widgets/custom.input.text.dart';
import 'package:boostseller/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool usePhone = false;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String fullPhoneNumber = '';

  void handleSendOTP() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
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
              Image.asset('assets/logo.png', height: height * 0.2),
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
                  setState(() => usePhone = !usePhone);
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
    );
  }
}
