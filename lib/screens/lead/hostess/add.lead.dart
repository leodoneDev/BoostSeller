// Add Lead Page : made by Leo on 2025/05/03

import 'package:flutter/material.dart';
import 'package:boostseller/screens/lead/hostess/add.lead.success.dart';
import 'package:boostseller/screens/profile/hostess/profile.panel.dart';
import 'package:boostseller/widgets/button.effect.dart';
import 'package:boostseller/widgets/custom.input.text.dart';
import 'package:boostseller/widgets/custom.phone.field.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
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
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF333333),
          appBar: AppBar(
            backgroundColor: const Color(0xFF3C3C3C),
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
                  color: Color(0xFF42A5F5),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _profileController.toggle(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset('assets/list.png', width: 24, height: 24),
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const AddSuccessScreen(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E90FF),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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

        // ✅ Overlay Profile Panel
        ProfileHostessPanel(controller: _profileController),
      ],
    );
  }

  // Widget _buildLabel(String label, {bool required = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 16, bottom: 6),
  //     child: Text(
  //       required ? '$label *' : label,
  //       style: const TextStyle(color: Colors.white, fontSize: 14),
  //     ),
  //   );
  // }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String hint,
  //   TextInputType? keyboardType,
  // }) {
  //   return TextField(
  //     controller: controller,
  //     keyboardType: keyboardType,
  //     style: const TextStyle(color: Colors.white),
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: Colors.grey[800],
  //       hintText: hint,
  //       hintStyle: const TextStyle(color: Colors.white38),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(8),
  //         borderSide: BorderSide.none,
  //       ),
  //     ),
  //   );
  // }
}
