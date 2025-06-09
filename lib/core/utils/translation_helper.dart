import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/providers/language_provider.dart';

/// Helper class to access translations throughout the app
class TranslationHelper {
  static String translate(BuildContext context, String key) {
    try {
      final container = ProviderScope.containerOf(context);
      final languageController = container.read(languageProvider.notifier);
      final result = languageController.translate(key);
      
      // If translation returns the key itself, it means translation failed
      if (result == key) {
        debugPrint('⚠️ Translation missing for key: $key');
      }
      
      return result;
    } catch (e) {
      debugPrint('❌ Translation error for key "$key": $e');
      return key; // Return the key as fallback
    }
  }

  static String t(BuildContext context, String key) {
    return translate(context, key);
  }
}

// Shorthand for TranslationHelper.translate
String T(BuildContext context, String key) {
  return TranslationHelper.translate(context, key);
}
