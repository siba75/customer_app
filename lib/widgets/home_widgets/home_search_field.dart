import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  final TextEditingController controller;

  const HomeSearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: context.shadowColor(0.05), blurRadius: 10),
          ],
        ),
        child: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن منتج...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: context.appMutedText,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.content_paste_search_outlined,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }
}
