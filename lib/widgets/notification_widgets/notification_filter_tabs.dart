import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class NotificationFilter {
  final String key;
  final String label;
  final IconData icon;

  const NotificationFilter({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class NotificationFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  const NotificationFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  static const filters = [
    NotificationFilter(key: 'all', label: 'الكل', icon: Icons.apps_rounded),
    NotificationFilter(
      key: 'unread',
      label: 'غير مقروء',
      icon: Icons.mark_email_unread_outlined,
    ),
    NotificationFilter(
      key: 'orders',
      label: 'الطلبات',
      icon: Icons.receipt_long_outlined,
    ),
    NotificationFilter(
      key: 'offers',
      label: 'العروض',
      icon: Icons.local_offer_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter.key;

          return ChoiceChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              filter.icon,
              size: 17,
              color: isSelected ? AppColors.white : AppColors.primary,
            ),
            label: Text(filter.label),
            labelStyle: AppTypography.bodyMedium.copyWith(
              color: isSelected ? AppColors.white : context.appMutedText,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: context.appSurface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : context.appSoftBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (_) => onChanged(filter.key),
          );
        },
      ),
    );
  }
}
