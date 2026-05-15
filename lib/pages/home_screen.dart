// lib/screens/home_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/customer_profile_cubit.dart';
import 'package:customer_app/cubit_folder/customer_profile_state.dart';
import 'package:customer_app/dio/customer_api.dart';
import 'package:customer_app/model/promo_banner_model.dart';
import 'package:customer_app/pages/cart_screen.dart';
import 'package:customer_app/pages/notifications_screen.dart';
import 'package:customer_app/pages/orders_screen.dart';
import 'package:customer_app/pages/product_detail_screen.dart';
import 'package:customer_app/pages/profile_screen.dart';
import 'package:customer_app/widgets/home_widgets/bottom_nav_bar.dart';
import 'package:customer_app/widgets/home_widgets/category_card.dart';
import 'package:customer_app/widgets/home_widgets/product_card.dart';
import 'package:customer_app/widgets/home_widgets/promo_banner_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Mock data
  final List<Map<String, dynamic>> _categories = [
    {'id': '1', 'name': 'خضروات', 'icon': Icons.eco},
    {'id': '2', 'name': 'فواكه', 'icon': Icons.apple},
    {'id': '3', 'name': 'مشروبات', 'icon': Icons.local_drink},
    {'id': '4', 'name': 'معلبات', 'icon': Icons.kitchen},
    {'id': '5', 'name': 'حلويات', 'icon': Icons.cake},
    {'id': '6', 'name': 'ألبان', 'icon': Icons.egg},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'طماطم',
      'price': 5.50,
      'old_price': 7.00,
      'unit': 'كجم',
      'image': 'https://picsum.photos/200/200?random=1',
      'category_id': '1',
      'description': 'طماطم .....',
    },
    {
      'id': '2',
      'name': 'خيار',
      'price': 3.00,
      'old_price': 4.00,
      'unit': 'كجم',
      'image': 'https://picsum.photos/200/200?random=2',
      'category_id': '1',
      'description': 'خيار ..... ',
    },
    {
      'id': '3',
      'name': 'تفاح',
      'price': 8.00,
      'old_price': null,
      'unit': 'كجم',
      'image': 'https://picsum.photos/200/200?random=3',
      'category_id': '2',
      'description': 'تفاح......',
    },
    {
      'id': '4',
      'name': 'برتقال',
      'price': 6.00,
      'old_price': 8.00,
      'unit': 'كجم',
      'image': 'https://picsum.photos/200/200?random=4',
      'category_id': '2',
      'description': 'برتقال بلدي',
    },
    {
      'id': '5',
      'name': 'عصير برتقال',
      'price': 12.00,
      'old_price': null,
      'unit': 'لتر',
      'image': 'https://picsum.photos/200/200?random=5',
      'category_id': '3',
      'description': 'عصير طبيعي 100%',
    },
    {
      'id': '6',
      'name': 'جبنة بيضاء',
      'price': 15.00,
      'old_price': 18.00,
      'unit': 'كجم',
      'image': 'https://picsum.photos/200/200?random=6',
      'category_id': '6',
      'description': 'جبنة بيضاء طازجة',
    },
  ];

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerProfileCubit(CustomerApi())..loadProfile(),
      child: BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
        builder: (context, profileState) {
          final profile = profileState.profile;
          final displayName = _firstName(profile?.fullName);
          final loyaltyPoints = profile?.loyaltyPoints ?? 250;

          return Scaffold(
            backgroundColor: context.appBackground,
            appBar: AppBar(
              title: Row(
                children: [
                  _buildLoyaltyPill(loyaltyPoints),
                  const SizedBox(width: 8),
                  _buildNotificationButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          displayName == null
                              ? 'مرحباً بك'
                              : 'مرحباً $displayName',
                          style: AppTypography.titleSmall.copyWith(
                            color: context.appText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ماذا تريد أن تطلب اليوم؟',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.appMutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      _avatarInitial(profile?.fullName),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: _currentIndex == 0
                ? _buildHomeContent()
                : _buildOtherScreen(),
            bottomNavigationBar: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: context.appSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: context.shadowColor(0.05), blurRadius: 10),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: context.appMutedText,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  // prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.content_paste_search_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PromoBannerCarousel(
            banners: mockPromoBanners,
            onActionTap: () => _showSuccess('جاري تجهيز العروض لك'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'التصنيفات',
                  style: TextStyle(color: AppColors.primaryLight),
                  // AppTypography.titleMedium,
                ),
                TextButton(onPressed: () {}, child: const Text('عرض الكل')),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) =>
                  CategoryCard(category: _categories[index]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(
                product: _products[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(product: _products[index]),
                  ),
                ),
                onAddToCart: () => _showSuccess(
                  'تم إضافة ${_products[index]['name']} إلى السلة',
                ),
              ),
              childCount: _products.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyPill(int loyaltyPoints) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 15, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            '$loyaltyPoints',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
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

  String? _firstName(String? fullName) {
    final name = fullName?.trim();
    if (name == null || name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  String _avatarInitial(String? fullName) {
    final name = _firstName(fullName);
    if (name == null || name.isEmpty) return '؟';
    return name.characters.first.toUpperCase();
  }
}
