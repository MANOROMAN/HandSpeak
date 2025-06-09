import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hand_speak/core/services/storage_service.dart';
import 'package:hand_speak/core/theme/app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme';

  Future<void> _loadTheme() async {
    final storage = await StorageService.getInstance();
    final themeString = storage.getString(_themeKey);
    if (themeString != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    state = theme;
    final storage = await StorageService.getInstance();
    await storage.setString(_themeKey, theme.toString());
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setTheme(newTheme);
  }

  ThemeData getTheme(bool isDark) {
    return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
}
