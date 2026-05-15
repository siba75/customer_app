// lib/core/theme/app_typography.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class AppTypography {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.black,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.black,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.black,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.black,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.black,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, color: AppColors.greyDark,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, color: AppColors.greyDark,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, color: AppColors.grey,
  );
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white,
  );
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white,
  );
}