// lib/widgets/profile/profile_stats_card.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ProfileStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: context.appCardShadow(
              alpha: 0.1,
              blur: 24,
              offset: const Offset(0, 10),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTypography.titleLarge.copyWith(
                  color: context.appText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: context.appMutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
