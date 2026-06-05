import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/cubit_folder/category_state.dart';
import 'package:customer_app/cubit_folder/product_state.dart';
import 'package:customer_app/model/category_model.dart';
import 'package:customer_app/widgets/home_widgets/category_card.dart';
import 'package:customer_app/widgets/home_widgets/home_message_card.dart';
import 'package:customer_app/widgets/home_widgets/home_shimmer.dart';
import 'package:flutter/material.dart';

class HomeCategoriesSection extends StatelessWidget {
  final CategoryState categoryState;
  final ProductState productState;
  final VoidCallback onShowAll;
  final ValueChanged<CategoryModel> onCategoryTap;

  const HomeCategoriesSection({
    super.key,
    required this.categoryState,
    required this.productState,
    required this.onShowAll,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التصنيفات',
                style: TextStyle(color: AppColors.primaryLight),
              ),
              TextButton(onPressed: onShowAll, child: const Text('عرض الكل')),
            ],
          ),
        ),
        _CategoriesList(
          categoryState: categoryState,
          productState: productState,
          onCategoryTap: onCategoryTap,
        ),
      ],
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final CategoryState categoryState;
  final ProductState productState;
  final ValueChanged<CategoryModel> onCategoryTap;

  const _CategoriesList({
    required this.categoryState,
    required this.productState,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryState.isLoading) {
      return const _CategoriesSkeleton();
    }

    if (categoryState.categories.isEmpty) {
      return HomeMessageCard(
        icon: Icons.category_outlined,
        title: categoryState.errorMessage ?? 'لا توجد تصنيفات حالياً',
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryState.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categoryState.categories[index];

          return CategoryCard(
            category: category.toUiMap(),
            isSelected: productState.selectedCategory?.id == category.id,
            onTap: () => onCategoryTap(category),
          );
        },
      ),
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: HomeShimmer(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return const SizedBox(
              width: 78,
              child: Column(
                children: [
                  ShimmerBox.circle(size: 64),
                  SizedBox(height: 8),
                  ShimmerBox(width: 58, height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
