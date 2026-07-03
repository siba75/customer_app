import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/widgets/home_widgets/home_shimmer.dart';
import 'package:flutter/material.dart';

class LoyaltyRewardsLoadingSkeleton extends StatelessWidget {
  const LoyaltyRewardsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => const _RewardSkeletonCard(),
    );
  }
}

class _RewardSkeletonCard extends StatelessWidget {
  const _RewardSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return HomeShimmer(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.appSoftBorder),
          boxShadow: context.appCardShadow(
            alpha: 0.1,
            blur: 24,
            offset: const Offset(0, 10),
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 46, height: 46),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: double.infinity, height: 18),
                      SizedBox(height: 8),
                      ShimmerBox(width: 150, height: 14),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                ShimmerBox(width: 104, height: 30),
              ],
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: ShimmerBox(height: 86)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 86)),
              ],
            ),
            SizedBox(height: 14),
            ShimmerBox(width: 130, height: 14),
          ],
        ),
      ),
    );
  }
}
