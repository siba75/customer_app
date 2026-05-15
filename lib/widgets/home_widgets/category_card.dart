// lib/core/widgets/category_card.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.appSoftPrimary,
            shape: BoxShape.circle,
            boxShadow: context.appCardShadow(
              alpha: 0.09,
              blur: 18,
              offset: const Offset(0, 8),
            ),
          ),
          child: Icon(category['icon'], size: 32, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          category['name'],
          style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
        ),
      ],
    );
  }
}
