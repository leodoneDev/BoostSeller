// lib/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _languageCode = 'en';

  String get languageCode => _languageCode;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('langCode');
    if (langCode != null) {
      _languageCode = langCode;
      notifyListeners();
    }
  }

  void setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('langCode', code);
    notifyListeners();
  }
}
