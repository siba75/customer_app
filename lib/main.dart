// lib/main.dart
import 'package:customer_app/core/services/notification_service.dart';
import 'package:customer_app/core/theem/app_theme.dart';
import 'package:customer_app/core/theem/theme_controller.dart';
import 'package:customer_app/pages/splash_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await ThemeController.loadSavedTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
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
