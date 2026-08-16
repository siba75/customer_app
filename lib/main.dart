// lib/main.dart
import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/localization/language_controller.dart';
import 'package:customer_app/core/services/notification_service.dart';
import 'package:customer_app/core/theem/app_theme.dart';
import 'package:customer_app/core/theem/theme_controller.dart';
import 'package:customer_app/pages/splash_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await ThemeController.loadSavedTheme();
  await LanguageController.loadSavedLanguage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageController.locale,
          builder: (context, locale, child) {
            return MaterialApp(
              navigatorKey: NotificationService.navigatorKey,
              title: 'Smart Store',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const SplashScreen(),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                final previewChild = DevicePreview.appBuilder(context, child);
                return Directionality(
                  textDirection: AppLocalizations.directionOf(locale),
                  child: previewChild,
                );
              },
            );
          },
        );
      },
    );
  }
}
