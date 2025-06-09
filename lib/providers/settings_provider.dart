import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hand_speak/providers/language_provider.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale? locale;
  final bool showUserId; // User ID gösterme durumu eklendi

  AppSettings({
    required this.themeMode,
    this.locale,
    this.showUserId = true, // Varsayılan olarak User ID görünür
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? showUserId,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      showUserId: showUserId ?? this.showUserId,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  SharedPreferences? _prefs;

  AppSettingsNotifier() : super(AppSettings(
    themeMode: ThemeMode.system,
    locale: const Locale('tr'), // Varsayılan dili Türkçe yaptık
    showUserId: true,
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    final themeModeString = _prefs!.getString('themeMode') ?? 'system';
    
    // Handle case where locale might be stored as an int (older versions)
    String localeString;
    if (_prefs!.containsKey('locale')) {
      var localeValue = _prefs!.get('locale');
      if (localeValue is int) {
        localeString = localeValue == 0 ? 'tr' : 'tr'; // legacy int not meaningful, default to Turkish
      } else {
        // Eğer kayıtlı bir dil kodu varsa kullan, yoksa Türkçe
        localeString = (localeValue as String?) ?? 'tr';
      }
    } else {
      // Kayıtlı dil yoksa varsayılan Türkçe olarak ayarla
      localeString = 'tr';
    }
    
    final showUserId = _prefs!.getBool('showUserId') ?? true;

    state = AppSettings(
      themeMode: _parseThemeMode(themeModeString),
      locale: Locale(localeString),
      showUserId: showUserId,
    );
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToPref(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs?.setString('themeMode', _themeModeToPref(mode));
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _prefs?.setString('locale', locale.languageCode);
    debugPrint('Language changed to ${locale.languageCode}');
  }

  // User ID gösterme durumunu ayarlamak için metot
  Future<void> setShowUserId(bool show) async {
    state = state.copyWith(showUserId: show);
    await _prefs?.setBool('showUserId', show);
  }
}

// Define the provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final notifier = AppSettingsNotifier();
  return notifier;
});

// Extension to ensure language is synced with settings
extension AppSettingsLanguageSync on ProviderContainer {
  void syncLanguageWithSettings() {
    listen<AppSettings>(
      appSettingsProvider, 
      (previous, next) {
        if (previous?.locale != next.locale && next.locale != null) {
          read(languageProvider.notifier).setLanguage(next.locale!);
        }
      },
      fireImmediately: true,
    );
  }
}
