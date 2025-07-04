// Change Password Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/custom_password_field.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  // final String email;
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> changePassword({
    required int otpType,
    required String address,
    required String password,
  }) async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    loadingProvider.setLoading(false);
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    final api = ApiService();

    try {
      final response = await api.post('/api/auth/change-password', {
        'otpType': otpType,
        'address': address,
        "password": password,
        // 'token': token,
      });
      Map<String, dynamic> jsonData = jsonDecode(response?.data);

      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          !jsonData['error']) {
        ToastUtil.success(getText("change_password_success_message", langCode));
        NavigationService.pushReplacementNamed('/login');
      } else {
        if (jsonData['message'] == 'user-not-found') {
          ToastUtil.error(getText("user_not_found_message", langCode));
        } else if (jsonData['message'] == 'change-password-error') {
          ToastUtil.error(getText("change_password_error_message", langCode));
        }
      }
    } catch (e) {
      ToastUtil.error(getText("ajax_error_message", langCode));
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  void handleChangePwd({required int otpType, required String address}) {
    final password = newPasswordController.text.trim();
    final passwordConfirm = confirmPasswordController.text.trim();
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;

    if (isValidPassword(password)) {
      if (password == passwordConfirm) {
        changePassword(otpType: otpType, address: address, password: password);
      } else {
        ToastUtil.error(getText("password_match_error_message", langCode));
      }
    } else {
      ToastUtil.error(getText("password_invalid_message", langCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    int otpType = args['otpType'];
    String address = args['address'];
    final loadingProvider = Provider.of<LoadingProvider>(context);
    String langCode = context.watch<LanguageProvider>().languageCode;

    return BackOverrideWrapper(
      onBack: () {
        NavigationService.pushReplacementNamed('/login');
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
                  NavigationService.pushReplacementNamed('/login');
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
                  // Logo
                  Image.asset('assets/logo_dark.png', height: height * 0.18),
                  const SizedBox(height: 20),

                  Text(
                    getText("Change Password", langCode),
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildLabel(getText('Enter your new password', langCode)),
                  const SizedBox(height: 6),
                  PasswordField(
                    controller: newPasswordController,
                    hint: getText('Password', langCode),
                  ),
                  _buildLabel(
                    getText("Enter your confirmation password", langCode),
                  ),
                  const SizedBox(height: 6),
                  PasswordField(
                    controller: confirmPasswordController,
                    hint: getText("Password Confirm", langCode),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: EffectButton(
                      onTap:
                          () => handleChangePwd(
                            otpType: otpType,
                            address: address,
                          ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Config.activeButtonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            getText("Change", langCode),
                            style: TextStyle(
                              fontSize: Config.buttonTextFontSize,
                              color: Config.buttonTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
