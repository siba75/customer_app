// lib/widgets/profile/profile_menu_item.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isLogout;
  final bool showChevron;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.isLogout = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLogout
              ? AppColors.error.withValues(alpha: 0.1)
              : context.appSoftPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isLogout ? AppColors.error : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: isLogout ? AppColors.error : context.appText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
      ),
      trailing:
          trailing ??
          (showChevron
              ? Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: isLogout ? AppColors.error : AppColors.grey,
                )
              : null),
      onTap: showChevron || trailing != null ? onTap : null,
    );
  }
}
