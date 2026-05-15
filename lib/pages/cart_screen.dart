// lib/screens/cart_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/pages/checkout_screen.dart';
import 'package:customer_app/widgets/cart_widgets/cart_empty_state.dart';
import 'package:customer_app/widgets/cart_widgets/cart_item_card.dart';
import 'package:customer_app/widgets/cart_widgets/cart_summary_card.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(mockCartItems);
  }

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  double get _delivery => _subtotal >= 30 ? 0 : 5;

  double get _discount {
    return _items.fold(0, (sum, item) {
      if (!item.hasDiscount) return sum;
      return sum + ((item.oldPrice! - item.price) * item.quantity);
    });
  }

  int get _itemsCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void _increaseQuantity(CartItem item) {
    setState(() {
      _items = _items.map((cartItem) {
        if (cartItem.id != item.id) return cartItem;
        return cartItem.copyWith(quantity: cartItem.quantity + 1);
      }).toList();
    });
  }

  void _decreaseQuantity(CartItem item) {
    if (item.quantity == 1) return;

    setState(() {
      _items = _items.map((cartItem) {
        if (cartItem.id != item.id) return cartItem;
        return cartItem.copyWith(quantity: cartItem.quantity - 1);
      }).toList();
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _items = _items.where((cartItem) => cartItem.id != item.id).toList();
    });
  }

  void _goToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _items.isNotEmpty;

    return Scaffold(
      backgroundColor: context.appBackground,
      body: Column(
        children: [
          Expanded(
            child: hasItems
                ? CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _CartHeader(count: _itemsCount),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        sliver: SliverList.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return CartItemCard(
                              item: item,
                              onIncrease: () => _increaseQuantity(item),
                              onDecrease: () => _decreaseQuantity(item),
                              onRemove: () => _removeItem(item),
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ],
                  )
                : const CartEmptyState(),
          ),
          if (hasItems)
            CartSummaryCard(
              subtotal: _subtotal,
              delivery: _delivery,
              discount: _discount,
              onCheckout: _goToCheckout,
            ),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  final int count;

  const _CartHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: context.appCardShadow(
            alpha: 0.16,
            blur: 30,
            offset: const Offset(0, 14),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shopping_cart_checkout,
                color: AppColors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سلة التسوق',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count منتجات جاهزة لإتمام الطلب',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
