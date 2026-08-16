import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:flutter/material.dart';

class DiscountCard extends StatelessWidget {
  final DiscountModel discount;
  final String targetName;
  final VoidCallback? onApply;

  const DiscountCard({
    super.key,
    required this.discount,
    required this.targetName,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(discount);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
          blur: 26,
          offset: const Offset(0, 12),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            PositionedDirectional(
              top: -36,
              end: -34,
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(_scopeIcon(discount), color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              discount.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium.copyWith(
                                color: context.appText,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  icon: Icons.local_offer_outlined,
                                  label: _scopeLabel(context, discount),
                                  color: accent,
                                ),
                                _InfoChip(
                                  icon: Icons.adjust_rounded,
                                  label: targetName,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.appBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: context.appSoftBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            title: context.tr('قيمة الخصم'),
                            value: _valueLabel(context, discount),
                            color: accent,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: context.appSoftBorder,
                        ),
                        Expanded(
                          child: _Metric(
                            title: context.tr('حد الخصم'),
                            value: discount.maxInvoiceValue > 0
                                ? context.money(discount.maxInvoiceValue)
                                : context.tr('بدون حد'),
                            color: context.appText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaLine(
                          icon: Icons.event_available_outlined,
                          text: _dateLabel(context, discount),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _UsageBadge(discount: discount),
                    ],
                  ),
                  if (onApply != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: onApply,
                        icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                        label: Text(context.tr('تطبيق على السلة')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _scopeIcon(DiscountModel discount) {
    if (discount.isProductScope) return Icons.inventory_2_outlined;
    if (discount.isCategoryScope) return Icons.category_outlined;
    if (discount.isCustomerScope) return Icons.person_pin_circle_outlined;
    return Icons.storefront_outlined;
  }

  static Color _accentColor(DiscountModel discount) {
    if (discount.isProductScope) return AppColors.success;
    if (discount.isCategoryScope) return AppColors.secondary;
    if (discount.isCustomerScope) return AppColors.primary;
    return AppColors.primaryLight;
  }

  static String _scopeLabel(BuildContext context, DiscountModel discount) {
    if (discount.isProductScope) return context.tr('خصم منتج');
    if (discount.isCategoryScope) return context.tr('خصم فئة');
    if (discount.isCustomerScope) return context.tr('خصم خاص');
    return context.tr('خصم عام');
  }

  static String _valueLabel(BuildContext context, DiscountModel discount) {
    final value = _formatNumber(discount.value);
    if (discount.isPercentage) return '$value%';
    if (discount.isFixedAmount) return context.money(discount.value);
    return value;
  }

  static String _dateLabel(BuildContext context, DiscountModel discount) {
    final endDate = discount.endDate;
    if (endDate == null) return context.tr('مستمر بدون تاريخ انتهاء');

    final date = '${endDate.year}/${_two(endDate.month)}/${_two(endDate.day)}';
    return context.trArgs('صالح حتى {date}', {'date': date});
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _Metric({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: context.appMutedText),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: context.appMutedText,
            ),
          ),
        ),
      ],
    );
  }
}

class _UsageBadge extends StatelessWidget {
  final DiscountModel discount;

  const _UsageBadge({required this.discount});

  @override
  Widget build(BuildContext context) {
    final maxUses = discount.maxUses;
    final text = maxUses == null
        ? context.tr('استخدام مفتوح')
        : context.trArgs('{used}/{max} استخدام', {
            'used': discount.usedCount,
            'max': maxUses,
          });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.appSoftPrimary,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
