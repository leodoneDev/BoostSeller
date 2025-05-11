// OTP Verification page : made and update by Leo on 2025/05/07

import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/providers/loading.provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

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

  void reset() {
    for (final c in _otpControllers) {
      c.clear();
    }
  }

  Future<void> handleVerify({
    required int otpType,
    required int verifyType,
    required String address,
    required Map<String, dynamic>? userData,
  }) async {
    final otpCode = getOtpCode();
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    loadingProvider.setLoading(true);
    final api = ApiService();
    // final token = getAuthToken();

    try {
      final response = await api.post('/api/auth/verify-otp', {
        'code': otpCode,
        'otpType': otpType,
        'address': address,
        // 'token': token,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(jsonData['message']);
        if (verifyType == 1) {
          final api = ApiService();
          final prefs = await SharedPreferences.getInstance();
          final role = prefs.getString('userRole')?.toLowerCase() ?? '';

          if (role.isEmpty) {
            ToastUtil.error(
              "Your role do not selected. Please your select role.",
            );
            NavigationService.pushReplacementNamed('/onboarding');
          }
          try {
            final response = await api.post('/api/auth/register', {
              'name': userData?['name'],
              'email': userData?['email'],
              'phoneNumber': userData?['phoneNumber'],
              'password': userData?['password'],
              'role': role,
            });

            Map<String, dynamic> jsonData = jsonDecode(response?.data);

            if ((response?.statusCode == 200 || response?.statusCode == 201) &&
                !jsonData['error']) {
              ToastUtil.success(jsonData['message']);
            } else {
              ToastUtil.error(jsonData['message']);
              NavigationService.pushReplacementNamed('/register');
            }
          } catch (e) {
            ToastUtil.error("Server not found.\nPlease try again");
          } finally {
            loadingProvider.setLoading(false);
          }
        } else if (verifyType == 2) {
          NavigationService.pushReplacementNamed(
            '/change-password',
            arguments: {'otpType': otpType, 'address': address},
          );
        }
      } else if (jsonData['expire']) {
        ToastUtil.info('Please send your code again.');
        reset();
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
    final loadingProvider = Provider.of<LoadingProvider>(context);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // argunments validation check
    if (args.isEmpty ||
        args['otpType'] == null ||
        args['verifyType'] == null ||
        args['address'] == null ||
        args['userData'] == null) {
      ToastUtil.error("Missing required information.\nPlease try again.");
      NavigationService.pushReplacementNamed('/send-otp');
    }

    int otpType = args['otpType'];
    int verifyType = args['verifyType'];
    String address = args['address'];
    Map<String, dynamic>? userData = args['userData'];
    return BackOverrideWrapper(
      onBack: () {
        if (verifyType == 1) {
          NavigationService.pushReplacementNamed('/send-otp');
        } else if (verifyType == 2) {
          NavigationService.pushReplacementNamed('/forgot-password');
        }
      },
      child: LoadingOverlay(
        isLoading: loadingProvider.isLoading,
        child: Scaffold(
          backgroundColor: Config.backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Config.appbarColor,
            leading: IconButton(
              onPressed: () {
                if (verifyType == 1) {
                  NavigationService.pushReplacementNamed('/send-otp');
                } else if (verifyType == 2) {
                  NavigationService.pushReplacementNamed('/forgot-password');
                }
              },
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
                      onTap:
                          () => handleVerify(
                            otpType: otpType,
                            verifyType: verifyType,
                            address: address,
                            userData: userData,
                          ),
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
                        onTap: () async {
                          loadingProvider.setLoading(true);
                          final api = ApiService();
                          // final token = getAuthToken();
                          try {
                            final response = await api.post(
                              '/api/auth/send-otp',
                              {'address': address, 'otpType': otpType},
                            );
                            Map<String, dynamic> jsonData = jsonDecode(
                              response?.data,
                            );

                            if ((response?.statusCode == 200 ||
                                    response?.statusCode == 201) &&
                                !jsonData['error']) {
                              ToastUtil.success(jsonData['message']);
                            } else {
                              ToastUtil.error(jsonData['message']);
                            }
                          } catch (e) {
                            ToastUtil.error(
                              "Server not found. Please try again",
                            );
                          } finally {
                            loadingProvider.setLoading(false);
                          }
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
