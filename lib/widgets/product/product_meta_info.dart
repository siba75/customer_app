// lib/widgets/product/product_meta_info.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class ProductMetaInfo extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductMetaInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final rows = [
      if (product['supplier'] != null)
        _MetaRowData(
          icon: Icons.business_outlined,
          label: 'المورد',
          value: product['supplier'],
          color: AppColors.primary,
        ),
      if (product['in_stock'] != null)
        _MetaRowData(
          icon: product['in_stock'] ? Icons.check_circle : Icons.cancel,
          label: 'الحالة',
          value: product['in_stock'] ? 'متوفر في المخزون' : 'غير متوفر',
          color: product['in_stock'] ? AppColors.success : AppColors.error,
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.08,
          blur: 22,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        children: List.generate(rows.length, (index) {
          final row = rows[index];
          return Column(
            children: [
              _MetaRow(data: row),
              if (index != rows.length - 1)
                Divider(height: 22, color: context.appSoftBorder),
            ],
          );
        }),
      ),
    );
  }
}

class _MetaRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetaRowData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _MetaRow extends StatelessWidget {
  final _MetaRowData data;

  const _MetaRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(data.icon, size: 20, color: data.color),
        ),
        const SizedBox(width: 12),
        Text(
          '${data.label}:',
          style: AppTypography.bodyMedium.copyWith(
            color: context.appMutedText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            data.value,
            style: AppTypography.bodyMedium.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
