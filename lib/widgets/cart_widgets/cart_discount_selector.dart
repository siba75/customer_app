import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/cubit_folder/cart_state.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartDiscountSelector extends StatelessWidget {
  final CartState state;

  const CartDiscountSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = state.discount > 0;
    final hasAvailableDiscounts = state.activeDiscounts.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasDiscount
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.secondarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    hasDiscount
                        ? Icons.verified_outlined
                        : Icons.local_offer_outlined,
                    color: hasDiscount
                        ? AppColors.success
                        : AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasDiscount
                            ? context.tr('الخصم المطبق')
                            : context.tr('خيارات الخصم'),
                        style: AppTypography.titleMedium.copyWith(
                          color: context.appText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _subtitle(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.appMutedText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.appSoftBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _DiscountMetric(
                        label: state.hasManualDiscount
                            ? context.tr('خصم مختار يدوياً')
                            : context.tr('أفضل خصم تلقائي'),
                        value: state.discountName ?? context.tr('خصم متاح'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _DiscountMetric(
                      label: context.tr('وفرتِ'),
                      value: context.money(state.discount),
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ] else if (!state.isCalculatingDiscount) ...[
              const SizedBox(height: 12),
              _NoDiscountMessage(hasAvailableDiscounts: hasAvailableDiscounts),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasAvailableDiscounts
                        ? () => _showDiscountSheet(context)
                        : null,
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: Text(
                      hasAvailableDiscounts
                          ? context.trArgs('{count} خصومات', {
                              'count': state.activeDiscounts.length,
                            })
                          : context.tr('لا توجد خصومات'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.hasManualDiscount
                        ? () => context.read<CartCubit>().useBestDiscount()
                        : null,
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: Text(context.tr('أفضل خصم تلقائي')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: context.appSoftBorder,
                      disabledForegroundColor: context.appMutedText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
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

  String _subtitle(BuildContext context) {
    if (state.isCalculatingDiscount) {
      return context.tr('جاري حساب الخصم المناسب للسلة...');
    }

    if (state.hasManualDiscount) {
      return context.tr(
        'تم اختيار خصم يدوي. يمكنك الرجوع للأفضل تلقائياً بأي وقت.',
      );
    }

    if (state.discount > 0) {
      return context.tr(
        'النظام اختار أعلى توفير مناسب للمنتجات الموجودة في السلة.',
      );
    }

    return context.tr(
      'يمكنك اختيار خصم يدوي أو ترك النظام يطبّق أعلى توفير تلقائياً.',
    );
  }

  void _showDiscountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: _DiscountSheet(
          discounts: state.activeDiscounts,
          hasManualDiscount: state.hasManualDiscount,
        ),
      ),
    );
  }
}

class _NoDiscountMessage extends StatelessWidget {
  final bool hasAvailableDiscounts;

  const _NoDiscountMessage({required this.hasAvailableDiscounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appSoftBorder),
      ),
      child: Row(
        children: [
          Icon(
            hasAvailableDiscounts
                ? Icons.info_outline
                : Icons.local_offer_outlined,
            color: hasAvailableDiscounts ? AppColors.secondary : AppColors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasAvailableDiscounts
                  ? context.tr('لا يوجد خصم مناسب لمحتوى السلة الحالي.')
                  : context.tr('لا توجد خصومات متاحة حالياً.'),
              style: AppTypography.bodySmall.copyWith(
                color: context.appMutedText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _DiscountMetric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleSmall.copyWith(
            color: color ?? context.appText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DiscountSheet extends StatelessWidget {
  final List<DiscountModel> discounts;
  final bool hasManualDiscount;

  const _DiscountSheet({
    required this.discounts,
    required this.hasManualDiscount,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.42,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: context.appSoftBorder,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('اختاري الخصم المناسب'),
                        style: AppTypography.titleLarge.copyWith(
                          color: context.appText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                  children: [
                    _AutoDiscountOption(enabled: hasManualDiscount),
                    const SizedBox(height: 10),
                    ...discounts.map(
                      (discount) => _DiscountOption(discount: discount),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AutoDiscountOption extends StatelessWidget {
  final bool enabled;

  const _AutoDiscountOption({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.primary.withValues(alpha: 0.08)
            : context.appBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled ? AppColors.primary : context.appSoftBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          context.tr('أفضل خصم تلقائي'),
          style: AppTypography.titleSmall.copyWith(
            color: context.appText,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          context.tr('اتركي النظام يختار أعلى توفير مناسب للسلة.'),
          style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
        ),
        trailing: enabled
            ? const Icon(Icons.restart_alt_rounded, color: AppColors.primary)
            : const Icon(Icons.check_circle, color: AppColors.success),
        onTap: enabled
            ? () async {
                await context.read<CartCubit>().useBestDiscount();
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            : null,
      ),
    );
  }
}

class _DiscountOption extends StatelessWidget {
  final DiscountModel discount;

  const _DiscountOption({required this.discount});

  @override
  Widget build(BuildContext context) {
    final selected =
        context.select((CartCubit cubit) => cubit.state.selectedDiscountId) ==
        discount.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : context.appBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.primary : context.appSoftBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _color(discount).withValues(alpha: 0.12),
          child: Icon(_icon(discount), color: _color(discount), size: 20),
        ),
        title: Text(
          discount.name,
          style: AppTypography.titleSmall.copyWith(
            color: context.appText,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${_scope(context, discount)} - ${_value(context, discount)}',
          style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () => _apply(context),
      ),
    );
  }

  Future<void> _apply(BuildContext context) async {
    try {
      await context.read<CartCubit>().applyDiscount(discount);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('تم تطبيق الخصم على السلة')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  static IconData _icon(DiscountModel discount) {
    if (discount.isProductScope) return Icons.inventory_2_outlined;
    if (discount.isCategoryScope) return Icons.category_outlined;
    if (discount.isCustomerScope) return Icons.person_pin_circle_outlined;
    return Icons.storefront_outlined;
  }

  static Color _color(DiscountModel discount) {
    if (discount.isProductScope) return AppColors.success;
    if (discount.isCategoryScope) return AppColors.secondary;
    return AppColors.primary;
  }

  static String _scope(BuildContext context, DiscountModel discount) {
    if (discount.isProductScope) return context.tr('منتج محدد');
    if (discount.isCategoryScope) return context.tr('فئة محددة');
    if (discount.isCustomerScope) return context.tr('خصم خاص بحسابك');
    return context.tr('كل الطلب');
  }

  static String _value(BuildContext context, DiscountModel discount) {
    if (discount.isPercentage) return '${_format(discount.value)}%';
    if (discount.isFixedAmount) return context.money(discount.value);
    return context.tr('خصم متاح');
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}
