import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

class TranslatorHelper {
  static final GoogleTranslator translator = GoogleTranslator();

  static Future<String> translateText(
    String text,
    String toLanguageCode,
  ) async {
    try {
      if (toLanguageCode == 'en') {
        return text;
      }
      final translation = await translator.translate(text, to: toLanguageCode);
      return translation.text;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Fallback to original text
    }
  }
}
