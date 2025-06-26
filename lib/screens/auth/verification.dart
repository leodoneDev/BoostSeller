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
import 'package:boostseller/providers/loading_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/services/websocket_service.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';

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
  final socketService = SocketService();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData();
    });
  }

  Future<void> initializeData() async {
    await Future.delayed(Duration.zero);
    try {
      await Future.wait([connectServer()]);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> connectServer() async {
    socketService.initContext(context);
    String notRegisterUserId = '0';
    socketService.connect(notRegisterUserId);
  }

  @override
  void dispose() {
    socketService.disconnect();
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
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    loadingProvider.setLoading(true);
    final api = ApiService();
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
        //ToastUtil.success(jsonData['message']);
        if (verifyType == 1) {
          final api = ApiService();
          final prefs = await SharedPreferences.getInstance();
          final role = prefs.getString('userRole')?.toLowerCase() ?? '';

          if (role.isEmpty) {
            ToastUtil.error(getText("role_empty_message", langCode));
            NavigationService.pushReplacementNamed('/onboarding');
          }
          try {
            final registerResponse = await api.post('/api/auth/register', {
              'name': userData?['name'],
              'email': userData?['email'],
              'phoneNumber': userData?['phoneNumber'],
              'password': userData?['password'],
              'role': role,
              'adminId': userData?['adminId'],
            });

            Map<String, dynamic> registerJsonData = jsonDecode(
              registerResponse?.data,
            );

            if ((registerResponse?.statusCode == 200 ||
                    registerResponse?.statusCode == 201) &&
                !registerJsonData['error']) {
              ToastUtil.success(getText("register_success_message", langCode));
              socketService.userRegister({
                "userName": userData?['name'],
                "userEmail": userData?['email'],
                "adminId": userData?['adminId'],
                "userRole": role,
              });
              NavigationService.pushReplacementNamed('/login');
            } else {
              if (registerJsonData['exist']) {
                ToastUtil.info(getText("user_exist_message", langCode));
                NavigationService.pushReplacementNamed('/login');
              } else {
                ToastUtil.error(getText("register_fail_message", langCode));
                NavigationService.pushReplacementNamed('/register');
              }
            }
          } catch (e) {
            ToastUtil.error(getText("ajax_error_message", langCode));
          } finally {
            loadingProvider.setLoading(false);
          }
        } else if (verifyType == 2) {
          NavigationService.pushReplacementNamed(
            '/change-password',
            arguments: {'otpType': otpType, 'address': address},
          );
        }
      } else {
        if (jsonData['expire']) {
          ToastUtil.info(getText("expire_message", langCode));
        } else {
          ToastUtil.error(getText("verify_error_message", langCode));
        }
      }
    } catch (e) {
      ToastUtil.error("Server not found. Please try again");
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
    String langCode = context.watch<LanguageProvider>().languageCode;
    // argunments validation check
    if (args.isEmpty ||
        args['otpType'] == null ||
        args['verifyType'] == null ||
        args['address'] == null ||
        args['userData'] == null) {
      ToastUtil.error("Missing required information. Please try again.");
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
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () async {
                  if (verifyType == 1) {
                    NavigationService.pushReplacementNamed('/send-otp');
                  } else if (verifyType == 2) {
                    NavigationService.pushReplacementNamed('/forgot-password');
                  }
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
                  const SizedBox(height: 16),
                  Text(
                    getText("Verification", langCode),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  if (otpType == 1) ...[
                    const SizedBox(height: 6),
                    Text(
                      getText("otp_verify_message", langCode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Config.subTitleFontSize,
                        color: Config.subTitleFontColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        getText("Email OTP", langCode),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text(
                      getText("otp_verify_message", langCode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Config.subTitleFontSize,
                        color: Config.subTitleFontColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        getText("Mobile OTP", langCode),
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
                        child: Center(
                          child: Text(
                            getText("Verify", langCode),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Text(
                      //   getText(context, "If you didn't receive a code,"),
                      //   style: TextStyle(
                      //     color: Config.guideTextColor,
                      //     fontSize: 16,
                      //   ),
                      // ),
                      // const SizedBox(width: 10),
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
                              reset();
                            } else {
                              ToastUtil.error(jsonData['message']);
                            }
                          } catch (e) {
                            ToastUtil.error(
                              getText("ajax_error_message", langCode),
                            );
                          } finally {
                            loadingProvider.setLoading(false);
                          }
                        },
                        child: Text(
                          getText("Resend", langCode),
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
