import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/widgets/home_widgets/home_shimmer.dart';
import 'package:flutter/material.dart';

class OrdersLoadingSkeleton extends StatelessWidget {
  const OrdersLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => const _OrderSkeletonCard(),
    );
  }
}

class _OrderSkeletonCard extends StatelessWidget {
  const _OrderSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return HomeShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: context.appCardShadow(
            alpha: 0.1,
            blur: 24,
            offset: const Offset(0, 10),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _OrderSkeletonHeader(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerBox(width: 40, height: 40),
                      SizedBox(width: 8),
                      ShimmerBox(width: 40, height: 40),
                      SizedBox(width: 8),
                      ShimmerBox(width: 40, height: 40),
                    ],
                  ),
                  SizedBox(height: 14),
                  ShimmerBox(width: 92, height: 14),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(child: ShimmerBox(height: 42)),
                  SizedBox(width: 12),
                  Expanded(child: ShimmerBox(height: 42)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSkeletonHeader extends StatelessWidget {
  const _OrderSkeletonHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: context.appSoftPrimary,
      child: const Row(
        children: [
          ShimmerBox(width: 40, height: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 118, height: 16),
                SizedBox(height: 8),
                ShimmerBox(width: 150, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          ShimmerBox(width: 76, height: 28),
        ],
      ),
    );
  }
}
