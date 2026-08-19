import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/widgets/product/authenticated_product_image.dart';
import 'package:flutter/material.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.11,
          blur: 28,
          offset: const Offset(0, 12),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumb(item: item),
              const SizedBox(width: 14),
              Expanded(child: _ProductInfo(item: item)),
              const SizedBox(width: 8),
              _IconCircleButton(
                icon: Icons.delete_outline,
                color: AppColors.error,
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                onTap: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CartItemFooter(
            item: item,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final CartItem item;

  const _ProductThumb({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;

    return Container(
      width: 86,
      height: 96,
      decoration: BoxDecoration(
        color: context.appSoftPrimary,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: AuthenticatedProductImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => const Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.primary,
          size: 36,
        ),
        errorBuilder: (_) => const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primary,
          size: 34,
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final CartItem item;

  const _ProductInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleSmall.copyWith(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.trArgs('لكل {unit}', {'unit': context.tr(item.unit)}),
          style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
        ),
        const SizedBox(height: 12),
        Text(
          context.money(item.price),
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _CartItemFooter extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartItemFooter({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.appBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appSoftBorder),
      ),
      child: Row(
        children: [
          _QuantityStepper(
            quantity: item.quantity,
            maxQuantity: item.maxQuantity,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.tr('المجموع'),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.appMutedText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.money(item.total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final int? maxQuantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityStepper({
    required this.quantity,
    required this.maxQuantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconCircleButton(
          icon: Icons.remove,
          color: quantity > 1 ? AppColors.primary : AppColors.grey,
          onTap: quantity > 1 ? onDecrease : null,
          size: 34,
        ),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: AppTypography.titleSmall.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _IconCircleButton(
          icon: Icons.add,
          color: _canIncrease ? AppColors.primary : AppColors.grey,
          onTap: _canIncrease ? onIncrease : null,
          size: 34,
        ),
      ],
    );
  }

  bool get _canIncrease {
    return maxQuantity == null || quantity < maxQuantity!;
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double size;

  const _IconCircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.backgroundColor,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size * 0.55),
      ),
    );
  }
}
