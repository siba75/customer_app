import 'package:customer_app/core/const/secure_storage.dart';
import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();

  static const String _themeModeKey = 'theme_mode';
  static const String _darkValue = 'dark';
  static const String _lightValue = 'light';

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  static bool get isDarkMode => themeMode.value == ThemeMode.dark;

  static Future<void> loadSavedTheme() async {
    final savedTheme = await SecureStorage.read(_themeModeKey);
    themeMode.value = savedTheme == _darkValue
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static Future<void> setDarkMode(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await SecureStorage.write(_themeModeKey, isDark ? _darkValue : _lightValue);
  }
}
