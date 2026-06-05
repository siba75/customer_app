// lib/core/widgets/category_card.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : context.appSoftPrimary,
              shape: BoxShape.circle,
              boxShadow: context.appCardShadow(
                alpha: isSelected ? 0.16 : 0.09,
                blur: 18,
                offset: const Offset(0, 8),
              ),
            ),
            child: Icon(
              _iconData(category['icon']),
              size: 32,
              color: isSelected ? AppColors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 78,
            child: Text(
              category['name'],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : context.appMutedText,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconData(dynamic icon) {
    if (icon is IconData) return icon;

    switch (icon?.toString()) {
      case 'eco':
        return Icons.eco;
      case 'devices':
        return Icons.devices_other;
      case 'apple':
        return Icons.apple;
      case 'local_drink':
        return Icons.local_drink;
      case 'bakery':
        return Icons.bakery_dining;
      case 'cake':
        return Icons.cake;
      case 'egg':
        return Icons.egg;
      case 'restaurant':
        return Icons.restaurant;
      case 'kitchen':
        return Icons.kitchen;
      case 'grain':
        return Icons.grain;
      case 'spice':
        return Icons.spa;
      case 'frozen':
        return Icons.ac_unit;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'checkroom':
        return Icons.checkroom;
      case 'toys':
        return Icons.toys;
      case 'book':
        return Icons.menu_book;
      default:
        return Icons.category_outlined;
    }
  }
}
