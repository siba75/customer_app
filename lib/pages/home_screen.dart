// lib/screens/home_screen.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/ads_cubit.dart';
import 'package:customer_app/cubit_folder/ads_state.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/cubit_folder/category_cubit.dart';
import 'package:customer_app/cubit_folder/category_state.dart';
import 'package:customer_app/cubit_folder/customer_profile_cubit.dart';
import 'package:customer_app/cubit_folder/customer_profile_state.dart';
import 'package:customer_app/cubit_folder/order_cubit.dart';
import 'package:customer_app/cubit_folder/product_cubit.dart';
import 'package:customer_app/cubit_folder/product_state.dart';
import 'package:customer_app/dio/ads_api.dart';
import 'package:customer_app/dio/category_api.dart';
import 'package:customer_app/dio/customer_api.dart';
import 'package:customer_app/dio/discount_api.dart';
import 'package:customer_app/dio/order_api.dart';
import 'package:customer_app/dio/product_api.dart';
import 'package:customer_app/pages/cart_screen.dart';
import 'package:customer_app/pages/orders_screen.dart';
import 'package:customer_app/pages/profile_screen.dart';
import 'package:customer_app/widgets/home_widgets/bottom_nav_bar.dart';
import 'package:customer_app/widgets/home_widgets/home_app_bar_title.dart';
import 'package:customer_app/widgets/home_widgets/home_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CustomerProfileCubit(CustomerApi())..loadProfile(),
        ),
        BlocProvider(create: (_) => AdsCubit(AdsApi())..loadAds()),
        BlocProvider(create: (_) => CartCubit(DiscountApi())),
        BlocProvider(create: (_) => OrderCubit(OrderApi())..loadOrders()),
        BlocProvider(
          create: (_) => CategoryCubit(CategoryApi())..loadCategories(),
        ),
        BlocProvider(
          create: (_) =>
              ProductCubit(ProductApi(), DiscountApi())..loadProducts(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _showSuccess(String message) {
    _showSnackBar(message, AppColors.success);
  }

  void _showError(String message) {
    _showSnackBar(message, AppColors.error);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;

        return Scaffold(
          backgroundColor: context.appBackground,
          appBar: AppBar(
            title: HomeAppBarTitle(
              fullName: profile?.fullName,
              loyaltyPoints: profile?.loyaltyPoints ?? 250,
            ),
          ),
          body: _currentIndex == 0 ? _buildHomeTab() : _buildOtherScreen(),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    return BlocBuilder<AdsCubit, AdsState>(
      builder: (context, adsState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<ProductCubit, ProductState>(
              builder: (context, productState) {
                return HomeContent(
                  adsState: adsState,
                  categoryState: categoryState,
                  productState: productState,
                  searchController: _searchController,
                  onSearchCleared: _onSearchChanged,
                  onSuccess: _showSuccess,
                  onError: _showError,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOtherScreen() {
    switch (_currentIndex) {
      case 1:
        return const CartScreen();
      case 2:
        return const OrdersScreen();
      case 3:
        return const ProfileScreen(useExistingCubit: true);
      default:
        return const SizedBox();
    }
  }
}
