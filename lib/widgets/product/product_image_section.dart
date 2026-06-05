// lib/widgets/product/product_image_section.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/widgets/product/authenticated_product_image.dart';
import 'package:flutter/material.dart';

class ProductImageSection extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductImageSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isWeb = screenWidth >= 1200;
    final imageHeight = isWeb ? 470.0 : (isTablet ? 410.0 : 320.0);
    final price = _toDouble(product['price']);
    final oldPrice = product['old_price'] == null
        ? null
        : _toDouble(product['old_price']);
    final hasDiscount = oldPrice != null && oldPrice - price >= 0.01;
    final imageUrl = product['image']?.toString();

    return Container(
      height: imageHeight,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.14,
          blur: 32,
          offset: const Offset(0, 14),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AuthenticatedProductImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholderBuilder: _buildLoadingWidget,
              errorBuilder: _buildErrorWidget,
            ),
            const _ImageGradient(),
            Positioned(
              top: 14,
              right: 14,
              child: _CircleAction(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: _CircleAction(icon: Icons.favorite_border, onTap: () {}),
            ),
            if (hasDiscount)
              Positioned(
                bottom: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'عرض خاص',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      color: context.appSoftPrimary,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      color: context.appSoftPrimary,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _ImageGradient extends StatelessWidget {
  const _ImageGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.22),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.26),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: context.appSurface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: context.appText, size: 21),
      ),
    );
  }
}
