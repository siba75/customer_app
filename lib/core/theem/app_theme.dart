// lib/core/theme/app_theme.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';
import 'app_typography.dart';

class AppTheme {
  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    scaffoldBackground: AppColors.background,
    surface: AppColors.white,
    onSurface: AppColors.black,
    onSurfaceVariant: AppColors.greyDark,
    outline: AppColors.greyLight,
    appBarBackground: AppColors.white,
    inputFill: AppColors.white,
  );

  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    scaffoldBackground: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
    onSurfaceVariant: AppColors.darkTextMuted,
    outline: AppColors.darkBorder,
    appBarBackground: AppColors.darkBackground,
    inputFill: AppColors.darkSurfaceHigh,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color surface,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color appBarBackground,
    required Color inputFill,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.black,
      error: AppColors.error,
      onError: AppColors.white,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: colorScheme,
      canvasColor: scaffoldBackground,
      dividerColor: outline,
      textTheme: TextTheme(
        headlineLarge: AppTypography.headlineLarge.copyWith(color: onSurface),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: onSurface),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: onSurface),
        titleLarge: AppTypography.titleLarge.copyWith(color: onSurface),
        titleMedium: AppTypography.titleMedium.copyWith(color: onSurface),
        titleSmall: AppTypography.titleSmall.copyWith(color: onSurface),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: onSurfaceVariant),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
        bodySmall: AppTypography.bodySmall.copyWith(color: onSurfaceVariant),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.titleMedium.copyWith(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0 : 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: AppTypography.bodyMedium.copyWith(color: onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.buttonLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.black,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
