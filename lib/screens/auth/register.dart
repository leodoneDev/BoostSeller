// Register Page : made by Leo on 2025/04/30

import 'package:flutter/material.dart';

import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/utils/validation.dart';
import 'package:boostseller/widgets/custom_input_text.dart';
import 'package:boostseller/widgets/custom_phone_field.dart';
import 'package:boostseller/widgets/custom_password_field.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/screens/auth/login.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:boostseller/utils/back_override_wrapper.dart';
import 'package:boostseller/services/navigation_services.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/loading_provider.dart';
import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final TextEditingController pwdConfirmController = TextEditingController();
  String phoneNumber = '';
  String role = '';

  void reset() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    pwdController.clear();
    pwdConfirmController.clear();
  }

  void handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final adminEmail = adminEmailController.text.trim();
    final password = pwdController.text.trim();
    final passwordConfirm = pwdConfirmController.text.trim();
    final phone = phoneController.text.trim();
    String langCode =
        Provider.of<LanguageProvider>(context, listen: false).languageCode;
    if ((name.isNotEmpty) &&
        (email.isNotEmpty) &&
        (adminEmail.isNotEmpty) &&
        (phoneNumber.isNotEmpty) &&
        (password.isNotEmpty) &&
        (passwordConfirm.isNotEmpty) &&
        (phoneNumber.isNotEmpty) &&
        (phone.isNotEmpty)) {
      if (isValidEmail(email)) {
        if (isValidPassword(password)) {
          if (password == passwordConfirm) {
            final loadingProvider = Provider.of<LoadingProvider>(
              context,
              listen: false,
            );
            loadingProvider.setLoading(true);

            try {
              final api = ApiService();
              final response = await api.post('/api/auth/admin', {
                'email': adminEmail,
              });
              Map<String, dynamic> jsonData = jsonDecode(response?.data);

              if ((response?.statusCode == 200 ||
                      response?.statusCode == 201) &&
                  !jsonData['error']) {
                final adminId = jsonData['adminId'];
                NavigationService.pushReplacementNamed(
                  '/send-otp',
                  arguments: {
                    'name': name,
                    'email': email,
                    'phone': phoneNumber,
                    'password': password,
                    'adminId': adminId,
                  },
                );
              } else {
                if (jsonData['message'] == 'user-not-found') {
                  ToastUtil.error(getText("admin_empty_message", langCode));
                } else {
                  ToastUtil.error(getText("ajax_error_message", langCode));
                }
              }
            } catch (e) {
              debugPrint("Exception: $e");
              ToastUtil.error(getText("ajax_error_message", langCode));
            } finally {
              loadingProvider.setLoading(false);
            }
          } else {
            ToastUtil.error(getText("password_match_error_message", langCode));
          }
        } else {
          ToastUtil.error(getText("password_invalid_message", langCode));
        }
      } else {
        ToastUtil.error(getText("email_invalid_message", langCode));
      }
    } else {
      ToastUtil.error(getText("all fileds_invalid_message", langCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final loadingProvider = Provider.of<LoadingProvider>(context);
    String langCode = context.watch<LanguageProvider>().languageCode;

    return BackOverrideWrapper(
      onBack: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
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
                  Image.asset('assets/logo_dark.png', height: height * 0.2),
                  SizedBox(height: height * 0.04),

                  Text(
                    getText("Register", langCode),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Config.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Config.titleFontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getText("Create a new account", langCode),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Config.subTitleFontSize,
                      color: Config.subTitleFontColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Username
                  const SizedBox(height: 12),

                  // Email
                  _buildLabel(getText('Name', langCode)),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: nameController,
                    hint: getText('Name', langCode),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 6),
                  // Email
                  _buildLabel(getText('Email', langCode)),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: emailController,
                    hint: getText('Email', langCode),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 6),
                  // Phone Number
                  _buildLabel(getText("Phone Number", langCode)),
                  const SizedBox(height: 6),
                  CustomPhoneField(
                    controller: phoneController,
                    onChanged: (phoneNumber) {
                      setState(() {
                        this.phoneNumber = phoneNumber;
                      });
                    },
                  ),

                  const SizedBox(height: 6),

                  _buildLabel(getText('Admin Email', langCode)),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: adminEmailController,
                    hint: getText('Admin Email', langCode),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 6),

                  // Password
                  _buildLabel(getText("Password", langCode)),
                  const SizedBox(height: 6),
                  PasswordField(
                    controller: pwdController,
                    hint: getText("Password", langCode),
                  ),

                  const SizedBox(height: 6),

                  // paswird confirm
                  _buildLabel(getText("Password Confirm", langCode)),
                  const SizedBox(height: 6),
                  PasswordField(
                    controller: pwdConfirmController,
                    hint: getText("Password Confirm", langCode),
                  ),

                  const SizedBox(height: 30),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: EffectButton(
                      onTap: handleRegister,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Config.activeButtonColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            getText("Register", langCode),
                            style: TextStyle(
                              fontSize: Config.buttonTextFontSize,
                              color: Config.buttonTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getText("Already have account?", langCode),
                        style: TextStyle(color: Config.guideTextColor),
                      ),
                      SizedBox(width: 10),
                      EffectButton(
                        onTap: () {
                          NavigationService.pushReplacementNamed('/login');
                        },

                        child: Text(
                          getText("Login", langCode),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
