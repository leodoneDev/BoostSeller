// Verification Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import '../lead/hostess/lead.list.dart';
import '../lead/performer/lead.list.dart';

class VerificationScreen extends StatelessWidget {
  final String role;
  final String email;

  const VerificationScreen({
    super.key,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3C3C3C),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(0),
          icon: Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF42A5F5), // light blue
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
              // Logo
              Image.asset('assets/logo.png', height: height * 0.2),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Messenger has send a code to\nverify your account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.white60),
              ),

              const SizedBox(height: 30),

              // Email OTP label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email OTP',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              _buildOtpRow(),

              const SizedBox(height: 24),

              // Mobile OTP label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mobile OTP',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              _buildOtpRow(),

              const SizedBox(height: 40),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (role == 'hostess') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeadListScreen(),
                        ),
                      );
                    } else if (role == 'performer') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeadAssignedScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Unknown role")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E90FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend text
              GestureDetector(
                onTap: () {
                  // resend verification request.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP resent successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Resend',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
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
