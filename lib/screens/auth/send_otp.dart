// Send OTP Page : made by Leo on 2025/05/04

import 'package:boostseller/providers/loading.provider.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/utils/loading_overlay.dart';

class SendOTPScreen extends StatefulWidget {
  const SendOTPScreen({super.key});

  @override
  State<SendOTPScreen> createState() => _SendOTPScreenState();
}

class _SendOTPScreenState extends State<SendOTPScreen> {
  bool usePhone = false;
  int otpType = 1;

  Future<void> handleSendVerifyOTP(Map<String, dynamic> userData) async {
    String name = userData['name'] ?? '';
    String email = userData['email'] ?? '';
    String phoneNumber = userData['phoneNumber'] ?? '';
    String password = userData['password'] ?? '';

    if (name.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty) {
      ToastUtil.error("All fields are required.\nPlease check your input.");
      NavigationService.pushReplacementNamed('/register');
    }

    String address = email;
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    loadingProvider.setLoading(true);
    if (usePhone) {
      otpType = 2;
      address = phoneNumber;
    }

    final api = ApiService();
    // final token = getAuthToken();
    try {
      final response = await api.post('/api/auth/send-otp', {
        'address': address,
        'otpType': otpType,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(jsonData['message']);

        NavigationService.pushReplacementNamed(
          '/verification',
          arguments: {
            'verifyType': 1,
            'otpType': otpType,
            'address': address,
            'userData': {
              "name": name,
              "email": email,
              "phoneNumber": phoneNumber,
              "password": password,
            },
          },
        );
      } else {
        ToastUtil.error(jsonData['message']);
      }
    } catch (e) {
      ToastUtil.error("Server not found.\nPlease try again");
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final Map<String, dynamic> userInfo =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    if (userInfo.isEmpty ||
        userInfo['name'] == null ||
        userInfo['email'] == null ||
        userInfo['phone'] == null ||
        userInfo['password'] == null ||
        (userInfo['name'] as String).isEmpty ||
        (userInfo['email'] as String).isEmpty ||
        (userInfo['phone'] as String).isEmpty ||
        (userInfo['password'] as String).isEmpty) {
      ToastUtil.error("All fields are required.\nPlease complete the form.");
      NavigationService.pushReplacementNamed('/register');
    }

    final String name = userInfo['name'];
    final String email = userInfo['email'];
    final String phoneNumber = userInfo['phone'];
    final String password = userInfo['password'];
    final loadingProvider = Provider.of<LoadingProvider>(context);

    return BackOverrideWrapper(
      onBack: () {
        NavigationService.pushReplacementNamed('/register');
      },

      child: LoadingOverlay(
        isLoading: loadingProvider.isLoading,
        child: Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            backgroundColor: Config.appbarColor,
            elevation: 0,
            leading: IconButton(
              onPressed:
                  () => NavigationService.pushReplacementNamed('/register'),
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
                          ? 'Your phone number is $phoneNumber}'
                          : 'Your email is $email',
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
                      onTap:
                          () => handleSendVerifyOTP({
                            'name': name,
                            'email': email,
                            'phoneNumber': phoneNumber,
                            'password': password,
                          }),
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
        ),
      ),
    );
  }
}
