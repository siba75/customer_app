import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/ads_cubit.dart';
import 'package:customer_app/cubit_folder/ads_state.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/cubit_folder/category_cubit.dart';
import 'package:customer_app/cubit_folder/category_state.dart';
import 'package:customer_app/cubit_folder/product_cubit.dart';
import 'package:customer_app/cubit_folder/product_state.dart';
import 'package:customer_app/model/ad_model.dart';
import 'package:customer_app/model/category_model.dart';
import 'package:customer_app/pages/product_detail_screen.dart';
import 'package:customer_app/widgets/home_widgets/home_categories_section.dart';
import 'package:customer_app/widgets/home_widgets/home_products_section.dart';
import 'package:customer_app/widgets/home_widgets/home_search_field.dart';
import 'package:customer_app/widgets/home_widgets/home_shimmer.dart';
import 'package:customer_app/widgets/home_widgets/promo_banner_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContent extends StatelessWidget {
  final AdsState adsState;
  final CategoryState categoryState;
  final ProductState productState;
  final TextEditingController searchController;
  final VoidCallback onSearchCleared;
  final ValueChanged<String> onSuccess;
  final ValueChanged<String> onError;

  const HomeContent({
    super.key,
    required this.adsState,
    required this.categoryState,
    required this.productState,
    required this.searchController,
    required this.onSearchCleared,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: context.appSurface,
      onRefresh: () => _refresh(context),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: HomeSearchField(controller: searchController),
          ),
          SliverToBoxAdapter(child: _AdsCarousel(state: adsState)),
          SliverToBoxAdapter(
            child: HomeCategoriesSection(
              categoryState: categoryState,
              productState: productState,
              onShowAll: () => _showAllProducts(context),
              onCategoryTap: (category) => _loadCategory(context, category),
            ),
          ),
          HomeProductsSection(
            state: productState,
            searchQuery: searchController.text,
            onProductTap: (product) => _openProductDetails(context, product),
            onAddToCart: (product) => _addProductToCart(context, product),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final adsCubit = context.read<AdsCubit>();
    final categoryCubit = context.read<CategoryCubit>();
    final productCubit = context.read<ProductCubit>();

    await adsCubit.loadAds();
    await categoryCubit.loadCategories();
    await productCubit.refreshProducts();
  }

  void _showAllProducts(BuildContext context) {
    if (searchController.text.isNotEmpty) {
      searchController.clear();
      onSearchCleared();
    }

    context.read<ProductCubit>().loadProducts();
  }

  void _loadCategory(BuildContext context, CategoryModel category) {
    context.read<ProductCubit>().loadProductsByCategory(category);
  }

  void _openProductDetails(BuildContext context, Map<String, dynamic> product) {
    final cartCubit = context.read<CartCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cartCubit,
          child: ProductDetailScreen(product: product),
        ),
      ),
    );
  }

  void _addProductToCart(BuildContext context, Map<String, dynamic> product) {
    final cartCubit = context.read<CartCubit>();
    final stock = _productStock(product);
    final productId = product['id']?.toString() ?? '';
    final currentQuantity = cartCubit.state.items
        .where((item) => item.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);

    if (stock <= 0) {
      onError('هذا المنتج غير متوفر حالياً');
      return;
    }

    if (currentQuantity >= stock) {
      onError('لا يمكن إضافة كمية أكبر من المخزون المتاح');
      return;
    }

    cartCubit.addProduct(product);
    onSuccess('تم إضافة ${product['name']} إلى السلة');
  }

  int _productStock(Map<String, dynamic> product) {
    final stock = product['quantity_in_stock'] ?? product['quantityInStock'];
    if (stock is int) return stock;
    if (stock is num) return stock.toInt();
    return int.tryParse(stock?.toString() ?? '') ?? 0;
  }
}

class _AdsCarousel extends StatelessWidget {
  final AdsState state;

  const _AdsCarousel({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.ads.isEmpty) {
      return const _AdsSkeleton();
    }

    return PromoBannerCarousel(
      banners: state.ads,
      onActionTap: (ad) => _handleAdTap(context, ad),
    );
  }

  void _handleAdTap(BuildContext context, AdModel ad) {
    final message = ad.linkUrl == null || ad.linkUrl!.isEmpty
        ? (ad.title.isEmpty ? 'جاري تجهيز الإعلان لك' : ad.title)
        : 'تم فتح إعلان ${ad.title}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }
}

class _AdsSkeleton extends StatelessWidget {
  const _AdsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: HomeShimmer(
        child: Container(
          height: 304,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.appSoftBorder),
            boxShadow: context.appCardShadow(
              alpha: 0.1,
              blur: 24,
              offset: const Offset(0, 10),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerBox(width: 86, height: 28),
                  SizedBox(width: 8),
                  ShimmerBox(width: 74, height: 28),
                ],
              ),
              Spacer(),
              ShimmerBox(width: 220, height: 28),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 16),
              SizedBox(height: 8),
              ShimmerBox(width: 250, height: 16),
              SizedBox(height: 22),
              ShimmerBox(width: 126, height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
