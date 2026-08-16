// lib/widgets/product/product_price_row.dart
import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class ProductPriceRow extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductPriceRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final price = _toDouble(product['price']);
    final discountName = product['discount_name']?.toString();
    final discountLabel = _discountLabel(product);
    final hasDiscount = discountName != null && discountName.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.money(price),
                style:
                    (isTablet
                            ? AppTypography.headlineSmall
                            : AppTypography.titleLarge)
                        .copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
              ),
            ],
          ),
        ),
        if (hasDiscount) ...[
          Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              discountLabel,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.secondarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            context.tr(product['unit']?.toString() ?? 'قطعة'),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _discountLabel(Map<String, dynamic> product) {
    final label = product['discount_label']?.toString().trim();
    if (label != null && label.isNotEmpty) return label;

    final type = product['discount_type']?.toString().toUpperCase();
    final value = _toDouble(product['discount_value']);
    if (value <= 0) return AppLocalizations.translate('خصم متاح');

    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    if (type == 'PERCENTAGE') return '$formatted%';
    if (type == 'FIXED_AMOUNT') return AppLocalizations.formatCurrency(value);
    return AppLocalizations.translate('خصم متاح');
  }
}
