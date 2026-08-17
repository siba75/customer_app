import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class NotificationEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const NotificationEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(
              size: 112,
              borderRadius: 30,
              shadows: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              context.tr(title),
              style: AppTypography.headlineSmall.copyWith(
                color: context.appText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(subtitle),
              style: AppTypography.bodyMedium.copyWith(
                color: context.appMutedText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
