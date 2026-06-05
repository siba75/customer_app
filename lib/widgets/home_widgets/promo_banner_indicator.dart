import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class PromoBannerIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const PromoBannerIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isActive ? 22 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.greyLight,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
