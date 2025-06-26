// Custom Phone Number Field : made by Leo on 2025/05/24

import 'package:boostseller/screens/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:boostseller/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomPhoneField extends StatefulWidget {
  final Function(String completeNumber) onChanged;
  final String? initialValue;
  final TextEditingController? controller;
  final AutovalidateMode? autovalidateMode;

  const CustomPhoneField({
    super.key,
    required this.onChanged,
    this.initialValue,
    this.controller,
    this.autovalidateMode,
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  String? _initialCountryCode;

  @override
  void initState() {
    super.initState();
    _loadInitialCountry();
  }

  Future<void> _loadInitialCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('last_country_iso');
    setState(() {
      _initialCountryCode = savedCode ?? 'US';
    });
  }

  Future<void> _saveCountryCode(String iso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_country_iso", iso);
  }

  @override
  Widget build(BuildContext context) {
    if (_initialCountryCode == null) {
      return const CircularProgressIndicator();
    }
    String langCode = context.watch<LanguageProvider>().languageCode;

    return FormField<PhoneNumber>(
      autovalidateMode: widget.autovalidateMode,
      validator: (phoneNumber) {
        if (widget.controller?.text.trim().isEmpty ?? true) {
          return getText("Phone number is required", langCode);
        }
        return null;
      },
      builder: (FormFieldState<PhoneNumber> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntlPhoneField(
              controller: widget.controller,
              initialCountryCode: _initialCountryCode!,
              initialValue: widget.initialValue,
              decoration: InputDecoration(
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                errorText: state.errorText,
              ),
              style: const TextStyle(color: Colors.white),
              dropdownTextStyle: const TextStyle(color: Colors.white),
              dropdownIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              onChanged: (phone) {
                widget.onChanged(phone.completeNumber);
                state.didChange(phone);
              },
              onCountryChanged: (country) async {
                await _saveCountryCode(country.code);
              },
            ),
          ],
        );
      },
    );
  }
}
