// lib/screens/product/product_detail_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/dio/discount_api.dart';
import 'package:customer_app/dio/product_api.dart';
import 'package:customer_app/dio/product_photo_api.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:customer_app/widgets/product/add_to_cart_button.dart';
import 'package:customer_app/widgets/product/product_image_section.dart';
import 'package:customer_app/widgets/product/product_info_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  late Map<String, dynamic> _product;
  bool _isLoadingDetails = false;
  static const int _minQuantity = 1;

  @override
  void initState() {
    super.initState();
    _product = Map<String, dynamic>.from(widget.product);
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    final productId = int.tryParse(_product['id']?.toString() ?? '');
    if (productId == null) return;

    setState(() => _isLoadingDetails = true);

    try {
      final product = await ProductApi().getProduct(productId);
      final discounts = await _loadDiscountsSafely();
      final photoUrl = await _loadPrimaryPhotoSafely(productId);
      if (!mounted) return;
      setState(() {
        final productMap = product.toUiMap(discounts: discounts);
        _product = {
          ...productMap,
          'image': photoUrl ?? productMap['image'] ?? _product['image'],
          'has_image':
              photoUrl != null ||
              productMap['has_image'] == true ||
              _product['has_image'] == true,
        };
        _quantity = _clampQuantity(_quantity);
        _isLoadingDetails = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingDetails = false);
    }
  }

  Future<String?> _loadPrimaryPhotoSafely(int productId) async {
    try {
      return await ProductPhotoApi().getPrimaryPhotoUrl(productId);
    } catch (_) {
      return null;
    }
  }

  Future<List<DiscountModel>> _loadDiscountsSafely() async {
    try {
      return await DiscountApi().getActiveDiscounts();
    } catch (_) {
      return const [];
    }
  }

  void _incrementQuantity() {
    if (_quantity >= _maxQuantity) return;
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity <= _minQuantity) return;
    setState(() => _quantity--);
  }

  int _clampQuantity(int value) {
    if (_maxQuantity <= 0) return _minQuantity;
    return value.clamp(_minQuantity, _maxQuantity).toInt();
  }

  void _addToCart() {
    if (_maxQuantity <= 0) {
      _showMessage('هذا المنتج غير متوفر حالياً', AppColors.error);
      return;
    }

    final cartCubit = context.read<CartCubit>();
    final productId = _product['id']?.toString() ?? '';
    final currentQuantity = cartCubit.state.items
        .where((item) => item.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
    final availableQuantity = _maxQuantity - currentQuantity;

    if (availableQuantity <= 0) {
      _showMessage(
        'لا يمكن إضافة كمية أكبر من المخزون المتاح',
        AppColors.error,
      );
      return;
    }

    final quantityToAdd = _quantity > availableQuantity
        ? availableQuantity
        : _quantity;

    cartCubit.addProduct(_product, quantity: quantityToAdd);
    _showMessage(
      'تم إضافة $quantityToAdd × ${_product['name']} إلى السلة',
      AppColors.success,
    );
  }

  int get _maxQuantity {
    final stock = _product['quantity_in_stock'];
    if (stock is int) return stock;
    if (stock is num) return stock.toInt();
    return int.tryParse(stock?.toString() ?? '') ?? 99;
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
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
                    child: Stack(
                      children: [
                        ProductImageSection(product: _product),
                        if (_isLoadingDetails)
                          const Positioned(
                            left: 28,
                            right: 28,
                            bottom: 0,
                            child: LinearProgressIndicator(
                              color: AppColors.primary,
                              minHeight: 3,
                            ),
                          ),
                      ],
                    ),
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
                              ProductInfoSection(product: _product),
                              const SizedBox(height: 18),
                              _QuantityCard(
                                quantity: _quantity,
                                minQuantity: _minQuantity,
                                maxQuantity: _maxQuantity,
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
              product: _product,
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
  final int maxQuantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityCard({
    required this.quantity,
    required this.minQuantity,
    required this.maxQuantity,
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
                  maxQuantity > 0
                      ? 'المتوفر حالياً: $maxQuantity'
                      : 'غير متوفر حالياً',
                  style: AppTypography.bodySmall.copyWith(
                    color: maxQuantity > 0
                        ? context.appMutedText
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          _QuantityStepper(
            quantity: quantity,
            minQuantity: minQuantity,
            maxQuantity: maxQuantity,
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
  final int maxQuantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityStepper({
    required this.quantity,
    required this.minQuantity,
    required this.maxQuantity,
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
          _StepButton(
            icon: Icons.add,
            isDisabled: maxQuantity <= 0 || quantity >= maxQuantity,
            onTap: onIncrease,
          ),
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
