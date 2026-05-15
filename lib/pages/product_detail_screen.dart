// lib/screens/product/product_detail_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/widgets/product/add_to_cart_button.dart';
import 'package:customer_app/widgets/product/product_image_section.dart';
import 'package:customer_app/widgets/product/product_info_section.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  static const int _minQuantity = 1;
  static const int _maxQuantity = 99;

  void _incrementQuantity() {
    if (_quantity >= _maxQuantity) return;
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity <= _minQuantity) return;
    setState(() => _quantity--);
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إضافة $_quantity × ${widget.product['name']} إلى السلة',
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isWeb = screenWidth >= 1200;
    final horizontalPadding = isWeb ? 40.0 : (isTablet ? 28.0 : 16.0);
    final maxContentWidth = isWeb ? 920.0 : double.infinity;

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ProductImageSection(product: widget.product),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            18,
                            horizontalPadding,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductInfoSection(product: widget.product),
                              const SizedBox(height: 18),
                              _QuantityCard(
                                quantity: _quantity,
                                minQuantity: _minQuantity,
                                onIncrease: _incrementQuantity,
                                onDecrease: _decrementQuantity,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AddToCartButton(
              product: widget.product,
              height: isTablet ? 58 : 54,
              horizontalPadding: horizontalPadding,
              quantity: _quantity,
              onPressed: _addToCart,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityCard({
    required this.quantity,
    required this.minQuantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
          blur: 26,
          offset: const Offset(0, 12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: context.appSoftPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختاري الكمية',
                  style: AppTypography.titleSmall.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'يمكنك تعديلها قبل إتمام الطلب',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.appMutedText,
                  ),
                ),
              ],
            ),
          ),
          _QuantityStepper(
            quantity: quantity,
            minQuantity: minQuantity,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityStepper({
    required this.quantity,
    required this.minQuantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.appBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appSoftBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            isDisabled: quantity <= minQuantity,
            onTap: onDecrease,
          ),
          SizedBox(
            width: 42,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTypography.titleSmall.copyWith(
                color: context.appText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  const _StepButton({
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDisabled
              ? context.appSoftBorder
              : AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDisabled ? AppColors.grey : AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
