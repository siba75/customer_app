import 'package:customer_app/core/const/secure_storage.dart';
import 'package:flutter/material.dart';

class LanguageController {
  LanguageController._();

  static const String _languageCodeKey = 'language_code';
  static const String arabicCode = 'ar';
  static const String englishCode = 'en';

  static final ValueNotifier<Locale> locale = ValueNotifier(
    const Locale(arabicCode, 'SA'),
  );

  static bool get isArabic => locale.value.languageCode == arabicCode;

  static bool get isEnglish => locale.value.languageCode == englishCode;

  static Future<void> loadSavedLanguage() async {
    final savedLanguage = await SecureStorage.read(_languageCodeKey);
    locale.value = savedLanguage == null || savedLanguage.isEmpty
        ? _deviceLocale()
        : _localeFromCode(savedLanguage);
  }

  static Future<void> setLanguage(String languageCode) async {
    final nextLocale = _localeFromCode(languageCode);
    locale.value = nextLocale;
    await SecureStorage.write(_languageCodeKey, nextLocale.languageCode);
  }

  static Locale _localeFromCode(String? languageCode) {
    return languageCode == englishCode
        ? const Locale(englishCode, 'US')
        : const Locale(arabicCode, 'SA');
  }

  static Locale _deviceLocale() {
    final deviceLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    return deviceLanguage == englishCode
        ? const Locale(englishCode, 'US')
        : const Locale(arabicCode, 'SA');
  }
}
