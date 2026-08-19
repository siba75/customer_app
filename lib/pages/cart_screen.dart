// lib/screens/cart_screen.dart
import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/cubit_folder/cart_state.dart';
import 'package:customer_app/cubit_folder/customer_profile_cubit.dart';
import 'package:customer_app/cubit_folder/order_cubit.dart';
import 'package:customer_app/pages/checkout_screen.dart';
import 'package:customer_app/widgets/cart_widgets/cart_empty_state.dart';
import 'package:customer_app/widgets/cart_widgets/cart_item_card.dart';
import 'package:customer_app/widgets/cart_widgets/cart_summary_card.dart';
import 'package:customer_app/widgets/cart_widgets/cart_discount_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _goToCheckout(BuildContext context, CartState state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider.value(value: context.read<OrderCubit>()),
            BlocProvider.value(value: context.read<CustomerProfileCubit>()),
          ],
          child: const CheckoutScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.appBackground,
          body: Column(
            children: [
              Expanded(
                child: state.hasItems
                    ? CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _CartHeader(count: state.itemsCount),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            sliver: SliverList.builder(
                              itemCount: state.items.length,
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return CartItemCard(
                                  item: item,
                                  onIncrease: () => context
                                      .read<CartCubit>()
                                      .increaseQuantity(item),
                                  onDecrease: () => context
                                      .read<CartCubit>()
                                      .decreaseQuantity(item),
                                  onRemove: () => context
                                      .read<CartCubit>()
                                      .removeItem(item),
                                );
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: CartDiscountSelector(state: state),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 120),
                          ),
                        ],
                      )
                    : const CartEmptyState(),
              ),
              if (state.hasItems) ...[
                CartSummaryCard(
                  subtotal: state.subtotal,
                  discount: state.discount,
                  discountName: state.discountName,
                  isCalculatingDiscount: state.isCalculatingDiscount,
                  onCheckout: () => _goToCheckout(context, state),
                ),
              ],
            ],
          ),
        );
      },
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
                  Text(
                    context.tr('سلة التسوق'),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.trArgs('{count} منتجات جاهزة لإتمام الطلب', {
                      'count': count,
                    }),
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
