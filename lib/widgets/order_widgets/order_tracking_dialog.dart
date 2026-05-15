// lib/widgets/orders/order_tracking_dialog.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/model/order_model.dart';
import 'package:flutter/material.dart';

class OrderTrackingDialog extends StatelessWidget {
  final Order order;

  const OrderTrackingDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.track_changes,
                size: 30,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تتبع الطلب',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم التتبع: ${order.trackingNumber ?? "غير متوفر"}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrackingTimeline(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final steps = [
      {'label': 'تم الطلب', 'icon': Icons.check_circle, 'completed': true},
      {
        'label': 'قيد المعالجة',
        'icon': Icons.settings,
        'completed': order.isProcessing || order.isDelivered,
      },
      {
        'label': 'تم التوصيل',
        'icon': Icons.delivery_dining,
        'completed': order.isDelivered,
      },
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = step['completed'] as bool;
        return Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : AppColors.greyLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                step['icon'] as IconData,
                color: isCompleted ? AppColors.white : AppColors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step['label'] as String,
                style: TextStyle(
                  color: isCompleted ? AppColors.primary : AppColors.grey,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (index < steps.length - 1)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.primary : AppColors.greyLight,
              ),
          ],
        );
      }),
    );
  }
}
