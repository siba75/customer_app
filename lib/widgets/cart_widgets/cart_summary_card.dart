import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class CartSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final String? discountName;
  final bool isCalculatingDiscount;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    this.discountName,
    this.isCalculatingDiscount = false,
    required this.onCheckout,
  });

  double get total => (subtotal - discount).clamp(0, double.infinity).toDouble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: context.appSoftBorder)),
        boxShadow: context.appCardShadow(
          alpha: 0.14,
          blur: 32,
          offset: const Offset(0, -12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.appBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.appSoftBorder),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: context.tr('المجموع قبل الخصم'),
                    value: subtotal,
                  ),
                  if (isCalculatingDiscount) ...[
                    const SizedBox(height: 10),
                    const _CalculatingDiscountRow(),
                  ],
                  if (discount > 0) ...[
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: discountName == null || discountName!.isEmpty
                          ? context.tr('الخصم')
                          : '${context.tr('الخصم')} - $discountName',
                      value: -discount,
                      valueColor: AppColors.success,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Divider(height: 1, color: context.appSoftBorder),
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: context.tr('الإجمالي للدفع'),
                    value: total,
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('المبلغ للدفع'),
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.appMutedText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.money(total),
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: onCheckout,
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: Text(
                        context.tr('إتمام الطلب'),
                        style: const TextStyle(color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatingDiscountRow extends StatelessWidget {
  const _CalculatingDiscountRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('حساب الخصم'),
          style: AppTypography.bodyMedium.copyWith(color: context.appMutedText),
        ),
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final formattedValue = value < 0
        ? '-${context.money(value.abs())}'
        : context.money(value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: context.appMutedText),
        ),
        Text(
          formattedValue,
          style: AppTypography.titleSmall.copyWith(
            color: valueColor ?? context.appText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
