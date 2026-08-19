// lib/widgets/orders/order_empty_state.dart
import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

class OrderEmptyState extends StatelessWidget {
  const OrderEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final minHeight = MediaQuery.sizeOf(context).height - 180;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight.clamp(420, 620).toDouble(),
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.appSoftBorder),
              boxShadow: context.appCardShadow(
                alpha: 0.08,
                blur: 28,
                offset: const Offset(0, 14),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 156,
                  height: 132,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 132,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: context.appSurfaceHigh,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.14),
                            ),
                            boxShadow: context.appCardShadow(
                              alpha: 0.1,
                              blur: 20,
                              offset: const Offset(0, 10),
                            ),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 46,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 18,
                        bottom: 18,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 22,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  context.tr('لا توجد طلبات'),
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr(
                    'لم تقم بإجراء أي طلبات بعد. تصفح المنتجات وأضف أول طلب لك بسهولة.',
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.appMutedText,
                    height: 1.55,
                  ),
                ),
                // SizedBox(
                //   width: double.infinity,
                //   height: 52,
                //   child: ElevatedButton.icon(
                //     onPressed: () => Navigator.pop(context),
                //     icon: const Icon(Icons.storefront_outlined),
                //     label: Text(
                //       context.tr('تسوق الآن'),
                //       style: AppTypography.buttonMedium,
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.primary,
                //       foregroundColor: AppColors.white,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //       elevation: 0,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
