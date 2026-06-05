import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/pages/notifications_screen.dart';
import 'package:flutter/material.dart';

class HomeAppBarTitle extends StatelessWidget {
  final String? fullName;
  final int loyaltyPoints;

  const HomeAppBarTitle({
    super.key,
    required this.fullName,
    required this.loyaltyPoints,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _firstName(fullName);

    return Row(
      children: [
        _LoyaltyPill(loyaltyPoints: loyaltyPoints),
        const SizedBox(width: 8),
        const _NotificationButton(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayName == null ? 'مرحباً بك' : 'مرحباً $displayName',
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
            _avatarInitial(fullName),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  String? _firstName(String? value) {
    final name = value?.trim();
    if (name == null || name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  String _avatarInitial(String? value) {
    final name = _firstName(value);
    if (name == null || name.isEmpty) return '؟';
    return name.characters.first.toUpperCase();
  }
}

class _LoyaltyPill extends StatelessWidget {
  final int loyaltyPoints;

  const _LoyaltyPill({required this.loyaltyPoints});

  @override
  Widget build(BuildContext context) {
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
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
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
}
