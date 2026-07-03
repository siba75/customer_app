// lib/core/widgets/bottom_nav_bar.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_BottomNavItemData> _items = [
    _BottomNavItemData(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _BottomNavItemData(
      label: 'السلة',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
    ),
    _BottomNavItemData(
      label: 'طلباتي',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    _BottomNavItemData(
      label: 'حسابي',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;

          return Container(
            height: isCompact ? 78 : 84,
            margin: EdgeInsets.fromLTRB(
              isCompact ? 10 : 14,
              0,
              isCompact ? 10 : 14,
              12,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_items.length, (index) {
                return Expanded(
                  child: _BottomNavItem(
                    item: _items[index],
                    isCompact: isCompact,
                    isSelected: currentIndex == index,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final _BottomNavItemData item;
  final bool isCompact;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.item,
    required this.isCompact,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isCompact ? 40.0 : 44.0;
    final selectedIconSize = isCompact ? 46.0 : 50.0;

    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: AppColors.secondary.withValues(alpha: 0.14),
        highlightColor: AppColors.white.withValues(alpha: 0.06),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: isSelected ? selectedIconSize : iconSize,
                height: isSelected ? selectedIconSize : iconSize,
                transform: Matrix4.translationValues(0, isSelected ? -5 : 0, 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondary.withValues(alpha: 0.55)
                        : AppColors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                        ]
                      : const [],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey('${item.label}-$isSelected'),
                    size: isCompact ? 20 : 22,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.white : AppColors.grey,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  fontSize: isCompact ? 10.5 : 11.5,
                  height: 1,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _BottomNavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
