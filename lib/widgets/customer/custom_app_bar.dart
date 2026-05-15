// lib/core/widgets/custom_app_bar.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final int? loyaltyPoints;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.loyaltyPoints,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Loyalty points chip
          if (loyaltyPoints != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    loyaltyPoints.toString(),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          // Title section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: AppTypography.titleSmall),
              if (subtitle != null)
                Text(subtitle!, style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(width: 12),
          // Avatar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              // child: CachedNetworkImage(
              //   imageUrl: avatarUrl ?? 'https://ui-avatars.com/api/?background=492F90&color=fff&name=User',
              //   width: 44,
              //   height: 44,
              //   fit: BoxFit.cover,
              //   placeholder: (_, __) => Container(
              //     width: 44,
              //     height: 44,
              //     color: AppColors.primarySoft,
              //     child: const Icon(Icons.person, color: AppColors.primary),
              //   ),
              // ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
