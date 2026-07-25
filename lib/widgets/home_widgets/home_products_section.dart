import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/product_state.dart';
import 'package:customer_app/widgets/home_widgets/home_message_card.dart';
import 'package:customer_app/widgets/home_widgets/home_shimmer.dart';
import 'package:customer_app/widgets/home_widgets/product_card.dart';
import 'package:flutter/material.dart';

class HomeProductsSection extends StatelessWidget {
  final ProductState state;
  final String searchQuery;
  final ValueChanged<Map<String, dynamic>> onProductTap;
  final ValueChanged<Map<String, dynamic>> onAddToCart;

  const HomeProductsSection({
    super.key,
    required this.state,
    required this.searchQuery,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              state.selectedCategory?.name ?? 'المنتجات',
              style: AppTypography.titleMedium.copyWith(
                color: context.appText,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        ..._buildProductSlivers(),
      ],
    );
  }

  List<Widget> _buildProductSlivers() {
    if (state.isLoading) {
      return const [_ProductsSkeleton()];
    }

    final query = searchQuery.trim().toLowerCase();
    final products = state.products
        .where((product) {
          if (query.isEmpty) return true;
          return product.name.toLowerCase().contains(query) ||
              product.barcode.toLowerCase().contains(query);
        })
        .map(
          (product) => product.toUiMap(
            categoryName: state.selectedCategory?.name,
            discounts: state.discounts,
          ),
        )
        .toList();

    if (products.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: HomeMessageCard(
            icon: Icons.inventory_2_outlined,
            title: AppErrorMessages.friendly(
              state.errorMessage,
              fallback: query.isEmpty
                  ? 'لا توجد منتجات ضمن هذا التصنيف'
                  : 'لا توجد نتائج مطابقة للبحث',
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = products[index];

            return ProductCard(
              product: product,
              onTap: () => onProductTap(product),
              onAddToCart: () => onAddToCart(product),
            );
          }, childCount: products.length),
        ),
      ),
    ];
  }
}

class _ProductsSkeleton extends StatelessWidget {
  const _ProductsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _ProductSkeletonCard(),
          childCount: 6,
        ),
      ),
    );
  }
}

class _ProductSkeletonCard extends StatelessWidget {
  const _ProductSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return HomeShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: context.appCardShadow(
            alpha: 0.1,
            blur: 24,
            offset: const Offset(0, 10),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ShimmerBox(borderRadius: BorderRadius.zero),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 110, height: 14),
                  SizedBox(height: 8),
                  ShimmerBox(width: 58, height: 10),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 78, height: 16),
                      ShimmerBox.circle(size: 40),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiSliver extends StatelessWidget {
  final List<Widget> children;

  const MultiSliver({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: children);
  }
}
