import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class HomeMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const HomeMessageCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.appSoftBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 34),
            const SizedBox(height: 10),
            Text(
              context.tr(title),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.appMutedText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
