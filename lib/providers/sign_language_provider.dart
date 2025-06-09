import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/features/learn/models/sign_language_video.dart';

final signLanguageProvider = StateNotifierProvider<SignLanguageNotifier, SignLanguageType>(
  (ref) => SignLanguageNotifier(),
);

class SignLanguageNotifier extends StateNotifier<SignLanguageType> {
  SignLanguageNotifier() : super(SignLanguageType.turkish) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isTurkish = prefs.getBool('isTurkishSignLanguage') ?? true;
    state = isTurkish ? SignLanguageType.turkish : SignLanguageType.american;
  }

  Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == SignLanguageType.turkish ? SignLanguageType.american : SignLanguageType.turkish;
    await prefs.setBool('isTurkishSignLanguage', state == SignLanguageType.turkish);
  }
}
