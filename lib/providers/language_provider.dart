import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/core/services/storage_service.dart';

final languageProvider = StateNotifierProvider<LanguageController, Locale>((ref) {
  return LanguageController();
});

class LanguageController extends StateNotifier<Locale> {
  LanguageController() : super(const Locale('tr')) {
    _initializeLanguage();
  }

  static const String _languageKey = 'selected_language';
  Map<String, dynamic> _translations = {};

  Future<void> _initializeLanguage() async {
    try {
      // First load default translations
      await _loadTranslations('tr');

      // Notify listeners so widgets rebuild with loaded translations
      state = const Locale('tr');
      
      // Then check for saved language preference
      final storage = await StorageService.getInstance();
      final savedLanguage = storage.getString(_languageKey);
      if (savedLanguage != null && savedLanguage != 'tr') {
        await setLanguage(Locale(savedLanguage));
      }
      
      debugPrint('🌐 Language controller initialized with ${state.languageCode}');
    } catch (e) {
      debugPrint('❌ Error initializing language controller: $e');
    }
  }

  Future<void> setLanguage(Locale locale) async {
    state = locale;
    await _loadTranslations(locale.languageCode);
    final storage = await StorageService.getInstance();
    await storage.setString(_languageKey, locale.languageCode);
    
    // Force UI update by notifying listeners
    state = locale;
    debugPrint('✅ Language set to ${locale.languageCode}, translations loaded: ${_translations.isNotEmpty}');
  }

  Future<void> _loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      _translations = json.decode(jsonString);
      debugPrint('✅ Loaded translations for $languageCode: ${_translations.keys.length} root keys');
    } catch (e) {
      debugPrint('❌ Error loading translations for $languageCode: $e');
      // Fall back to English if the requested language can't be loaded
      if (languageCode != 'en') {
        try {
          final jsonString = await rootBundle.loadString('assets/translations/en.json');
          _translations = json.decode(jsonString);
          debugPrint('✅ Loaded fallback translations for en: ${_translations.keys.length} root keys');
        } catch (fallbackError) {
          debugPrint('❌ Error loading fallback translations: $fallbackError');
          _translations = {}; // Empty translations as last resort
        }
      } else {
        _translations = {}; // Empty translations as last resort
      }
    }
  }

  String translate(String key) {
    try {
      final keys = key.split('.');
      dynamic value = _translations;
      
      // Debug the translation process
      debugPrint('🔍 Translating key "$key" in ${state.languageCode}');
      debugPrint('📚 Available translations: ${_translations.keys}');
      
      for (final k in keys) {
        if (value == null || value[k] == null) {
          debugPrint('❌ Missing translation for key "$key" at segment "$k" in ${state.languageCode}');
          return key;
        }
        value = value[k];
      }
      
      final result = value?.toString() ?? key;
      debugPrint('✅ Translation found: "$key" -> "$result"');
      return result;
    } catch (e) {
      debugPrint('❌ Translation error for key "$key" in ${state.languageCode}: $e');
      return key;
    }
  }

  bool get isEnglish => state.languageCode == 'en';
  bool get isTurkish => state.languageCode == 'tr';
}
