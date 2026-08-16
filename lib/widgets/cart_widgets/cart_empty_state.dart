import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                color: context.appSoftPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              context.tr('سلتك فارغة'),
              style: AppTypography.headlineSmall.copyWith(
                color: context.appText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'أضيفي منتجاتك المفضلة وارجعي لإكمال الطلب بسهولة.',
              ),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.appMutedText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
