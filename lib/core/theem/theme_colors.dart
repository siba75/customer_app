import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  Color get appSurface => isDarkMode ? AppColors.darkSurface : AppColors.white;

  Color get appSurfaceHigh =>
      isDarkMode ? AppColors.darkSurfaceHigh : AppColors.white;

  Color get appText => isDarkMode ? AppColors.darkText : AppColors.black;

  Color get appMutedText =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.greyDark;

  Color get appSoftBorder =>
      isDarkMode ? AppColors.darkBorder : AppColors.greyLight;

  Color get appSoftPrimary =>
      isDarkMode ? AppColors.darkSurfaceHigh : AppColors.primarySoft;

  Color shadowColor(double alpha) =>
      Colors.black.withValues(alpha: isDarkMode ? alpha * 1.5 : alpha);

  List<BoxShadow> appCardShadow({
    double alpha = 0.1,
    double blur = 22,
    double spread = 0,
    Offset offset = const Offset(0, 10),
  }) {
    return [
      BoxShadow(
        color: shadowColor(alpha),
        blurRadius: blur,
        spreadRadius: spread,
        offset: offset,
      ),
    ];
  }
}
