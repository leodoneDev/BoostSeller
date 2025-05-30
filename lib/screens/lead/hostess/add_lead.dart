// Add Lead Page : made by Leo on 2025/05/03

import 'package:flutter/material.dart';
import 'package:boostseller/screens/profile/hostess/profile_panel.dart';
import 'package:boostseller/widgets/button_effect.dart';
import 'package:boostseller/widgets/custom_input_text.dart';
import 'package:boostseller/widgets/custom_phone_field.dart';
import 'package:boostseller/config/constants.dart';
import 'package:boostseller/utils/toast.dart';
import 'package:boostseller/utils/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:boostseller/providers/loading.provider.dart';
import 'package:boostseller/services/api_services.dart';
import 'dart:convert';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  @override
  void initState() {
    super.initState();
    fetchInterestList();
  }

  void fetchInterestList() async {
    final loadingProvider = Provider.of<LoadingProvider>(
      context,
      listen: false,
    );
    loadingProvider.setLoading(true);
    final api = ApiService();
    try {
      final response = await api.get('/api/auth/interest');
      Map<String, dynamic> jsonData = jsonDecode(response?.data);
    } catch (e) {
      ToastUtil.error("Server not found.\nPlease try again");
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  final _formKey = GlobalKey<FormState>();
  final ProfileHostessPanelController _profileController =
      ProfileHostessPanelController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedInterest;
  String phoneNumber = '';
  final List<String> interests = ['Interest 1', 'Interest 2', 'Interest 3'];

  void resetForm() {
    nameController.clear();
    genderController.clear();
    ageController.clear();
    budgetController.clear();
    setState(() => selectedInterest = null);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;

    return LoadingOverlay(
      isLoading: false,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Config.backgroundColor,
            appBar: AppBar(
              backgroundColor: Config.appbarColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
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
              actions: [
                EffectButton(
                  onTap: () => _profileController.toggle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.asset(
                      'assets/list.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            const Text(
                              'New Lead',
                              style: TextStyle(
                                fontSize: Config.titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Config.titleFontColor,
                              ),
                            ),
                            const SizedBox(height: 20),

                            CustomLabel(label: 'Email', required: true),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: nameController,
                              hint: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),

                            CustomLabel(label: 'Phone Number', required: true),
                            const SizedBox(height: 6),
                            CustomPhoneField(
                              controller: phoneController,
                              onChanged: (value) {
                                phoneNumber = value;
                              },
                            ),

                            CustomLabel(label: 'Interest', required: true),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedInterest,
                                    hint: const Text(
                                      'Interest',
                                      style: TextStyle(color: Colors.white38),
                                    ),
                                    dropdownColor: Colors.grey[900],
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white54,
                                    ),
                                    items:
                                        interests.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() => selectedInterest = value);
                                    },
                                  ),
                                ),
                              ),
                            ),

                            CustomLabel(label: 'Gender'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: genderController,
                              hint: 'Gender',
                              keyboardType: TextInputType.text,
                            ),

                            CustomLabel(label: 'Age'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: ageController,
                              hint: 'Age',
                              keyboardType: TextInputType.number,
                            ),

                            CustomLabel(label: 'Budget'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: budgetController,
                              hint: 'Budget',
                              keyboardType: TextInputType.text,
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Fixed Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: EffectButton(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                ToastUtil.success("Developing...");
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Config.activeButtonColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Add",
                                style: TextStyle(
                                  color: Config.buttonTextColor,
                                  fontSize: Config.buttonTextFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: EffectButton(
                            onTap: resetForm,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Config.deactiveButtonColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  color: Config.buttonTextColor,
                                  fontSize: Config.buttonTextFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          ProfileHostessPanel(controller: _profileController),
        ],
      ),
    );
  }
}
