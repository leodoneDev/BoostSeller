import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CustomPhoneField extends StatelessWidget {
  final Function(String) onChanged;
  final String initialCountryCode;
  final String? initialValue;
  final TextEditingController? controller;

  const CustomPhoneField({
    super.key,
    required this.onChanged,
    this.initialCountryCode = 'US',
    this.initialValue,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      initialCountryCode: initialCountryCode,
      initialValue: initialValue,
      style: const TextStyle(color: Colors.white),
      dropdownTextStyle: const TextStyle(color: Colors.white),
      dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      onChanged: (phone) => onChanged(phone.completeNumber),
    );
  }
}
