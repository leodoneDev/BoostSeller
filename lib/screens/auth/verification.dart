// Verification Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/screens/lead/hostess/lead.list.dart';
import 'package:boostseller/screens/lead/performer/lead.list.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/constants.dart';

class VerificationScreen extends StatelessWidget {
  final String role;
  final int otpType;

  const VerificationScreen({
    super.key,
    required this.role,
    required this.otpType,
  });

  void handleVerify(context) {
    if (role == 'hostess') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeadListScreen()),
      );
    } else if (role == 'performer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeadAssignedScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unknown role")));
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
              const SizedBox(height: 16),

              // Title
              const Text(
                'Verification',
                style: TextStyle(
                  fontSize: Config.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Config.titleFontColor,
                ),
              ),

              if (otpType == 1) ...[
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
                const SizedBox(height: 10),
                _buildOtpRow(),
              ] else if (otpType == 2) ...[
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
                const SizedBox(height: 10),
                _buildOtpRow(),
              ],

              const SizedBox(height: 40),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: EffectButton(
                  onTap: () => handleVerify(context),
                  child: Container(
                    width: double.infinity,
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
                  SizedBox(width: 10),
                  EffectButton(
                    onTap: () {},
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

  // Reusable OTP Row Widget
  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 44,
          child: TextField(
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
          ),
        );
      }),
    );
  }
}
