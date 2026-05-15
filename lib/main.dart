// lib/main.dart
import 'package:customer_app/core/theem/app_theme.dart';
import 'package:customer_app/core/theem/theme_controller.dart';
import 'package:customer_app/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // فعّل المعاينة
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Smart Store',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
          locale: const Locale('ar', 'SA'),
          builder: DevicePreview.appBuilder, // لإضافة شريط الأدوات
        );
      },
    );
  }
}
