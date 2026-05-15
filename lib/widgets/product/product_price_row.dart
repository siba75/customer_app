// lib/widgets/product/product_price_row.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class ProductPriceRow extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductPriceRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final price = (product['price'] as num).toDouble();
    final oldPrice = product['old_price'] == null
        ? null
        : (product['old_price'] as num).toDouble();

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${price.toStringAsFixed(2)} ل.س',
                style:
                    (isTablet
                            ? AppTypography.headlineSmall
                            : AppTypography.titleLarge)
                        .copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
              ),
              if (oldPrice != null)
                Text(
                  '${oldPrice.toStringAsFixed(2)} ل.س',
                  style: AppTypography.bodyMedium.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: context.appMutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.secondarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            product['unit'] ?? 'قطعة',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
