// lib/widgets/product/add_to_cart_button.dart
import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class AddToCartButton extends StatelessWidget {
  final Map<String, dynamic> product;
  final double height;
  final double horizontalPadding;
  final int quantity;
  final VoidCallback onPressed;

  const AddToCartButton({
    super.key,
    required this.product,
    required this.height,
    required this.horizontalPadding,
    this.quantity = 1,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = (product['price'] as num).toDouble() * quantity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        14,
      ),
      decoration: BoxDecoration(
        color: context.appSurface,
        border: Border(top: BorderSide(color: context.appSoftBorder)),
        boxShadow: context.appCardShadow(
          alpha: 0.14,
          blur: 32,
          offset: const Offset(0, -12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 340;
                final buttonHeight = isCompact ? 52.0 : height;

                return SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 12 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _ButtonContent(
                      totalPrice: totalPrice,
                      quantity: quantity,
                      isCompact: isCompact,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final double totalPrice;
  final int quantity;
  final bool isCompact;

  const _ButtonContent({
    required this.totalPrice,
    required this.quantity,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCompact ? 30 : 34,
          height: isCompact ? 30 : 34,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            size: isCompact ? 17 : 19,
            color: AppColors.white,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('أضف إلى السلة'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.buttonLarge.copyWith(
                  fontSize: isCompact ? 14 : 16,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _priceText(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isCompact ? 10 : 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _priceText(BuildContext context) {
    final price = context.money(totalPrice);
    if (isCompact || quantity == 1) return price;
    return context.trArgs('{price} • {quantity} منتجات', {
      'price': price,
      'quantity': quantity,
    });
  }
}
