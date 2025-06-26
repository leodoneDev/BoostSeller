// Send OTP Page : made by Leo on 2025/05/04

import 'package:boostseller/providers/loading_provider.dart';
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
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';

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
    int adminId = userData['adminId'] ?? 0;
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;

    if (name.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        adminId == 0 ||
        password.isEmpty) {
      ToastUtil.error(
        getText("All fields are required. Please check your input.", langCode),
      );
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
        ToastUtil.success(getText("send_otp_success_message", langCode));

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
              "adminId": adminId,
            },
          },
        );
      } else {
        ToastUtil.error(getText("send_otp_fail_message", langCode));
      }
    } catch (e) {
      ToastUtil.error(getText("ajax_error_message", langCode));
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
    String langCode = context.watch<LanguageProvider>().languageCode;

    if (userInfo.isEmpty ||
        userInfo['name'] == null ||
        userInfo['email'] == null ||
        userInfo['phone'] == null ||
        userInfo['password'] == null ||
        userInfo['adminId'] == null ||
        (userInfo['name'] as String).isEmpty ||
        (userInfo['email'] as String).isEmpty ||
        (userInfo['phone'] as String).isEmpty ||
        (userInfo['password'] as String).isEmpty) {
      ToastUtil.error(
        getText("All fields are required. Please check your input.", langCode),
      );
      NavigationService.pushReplacementNamed('/register');
    }

    final String name = userInfo['name'];
    final String email = userInfo['email'];
    final String phoneNumber = userInfo['phone'];
    final String password = userInfo['password'];
    final adminId = userInfo['adminId'];
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
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () async {
                  NavigationService.pushReplacementNamed('/register');
                },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Config.activeButtonColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back,
                    size: Config.appBarBackIconSize,
                    color: Config.iconDefaultColor,
                  ),
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

                  Text(
                    getText("Verification", langCode),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usePhone
                        ? getText("verify_phone_message", langCode)
                        : getText("verify_email_message", langCode),
                    style: const TextStyle(
                      fontSize: Config.subTitleFontSize,
                      color: Config.subTitleFontColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Align(
                  //   child: Text(
                  //     usePhone
                  //         ? getText(
                  //           context,
                  //           'Your phone number is {number}',
                  //           args: {'number': phoneNumber},
                  //         )
                  //         : getText(
                  //           context,
                  //           'Your email is {email}',
                  //           args: {'email': email},
                  //         ),

                  //     style: const TextStyle(
                  //       color: Colors.white,
                  //       fontSize: Config.subTitleFontSize,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  Align(
                    child: Consumer<LanguageProvider>(
                      builder: (context, langProvider, _) {
                        return Text(
                          usePhone
                              ? getText(
                                'Your phone number is {number}',
                                langCode,
                                args: {'number': phoneNumber},
                              )
                              : getText(
                                'Your email is {email}',
                                langCode,
                                args: {'email': email},
                              ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: Config.subTitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
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
                            'adminId': adminId,
                          }),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Config.activeButtonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            getText("Send OTP", langCode),
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
                      usePhone
                          ? getText("Use Email Instead", langCode)
                          : getText("Use Phone Instead", langCode),
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
