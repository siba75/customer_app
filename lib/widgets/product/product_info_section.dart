// lib/widgets/product/product_info_section.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/widgets/product/product_meta_info.dart';
import 'package:customer_app/widgets/product/product_price_row.dart';
import 'package:flutter/material.dart';

class ProductInfoSection extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProductTitleCard(product: product, isTablet: isTablet),
        const SizedBox(height: 16),
        _DescriptionCard(product: product, isTablet: isTablet),
        if (_hasMetaInfo) ...[
          const SizedBox(height: 16),
          ProductMetaInfo(product: product),
        ],
      ],
    );
  }

  bool get _hasMetaInfo {
    return product['supplier'] != null || product['in_stock'] != null;
  }
}

class _ProductTitleCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isTablet;

  const _ProductTitleCard({required this.product, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
          blur: 28,
          offset: const Offset(0, 12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product['name'],
                  style:
                      (isTablet
                              ? AppTypography.headlineMedium
                              : AppTypography.headlineSmall)
                          .copyWith(
                            color: context.appText,
                            fontWeight: FontWeight.w900,
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'متوفر',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ProductPriceRow(product: product),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isTablet;

  const _DescriptionCard({required this.product, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.08,
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.appSoftPrimary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'الوصف',
                style:
                    (isTablet
                            ? AppTypography.titleLarge
                            : AppTypography.titleMedium)
                        .copyWith(
                          color: context.appText,
                          fontWeight: FontWeight.w800,
                        ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            product['description'] ?? 'لا يوجد وصف متاح لهذا المنتج.',
            style: AppTypography.bodyLarge.copyWith(
              color: context.appMutedText,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
