// lib/widgets/orders/order_tracking_dialog.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
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
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TrackingHeader(order: order),
            const SizedBox(height: 18),
            _CurrentStatusCard(order: order),
            const SizedBox(height: 18),
            _TrackingTimeline(order: order),
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
}

class _TrackingHeader extends StatelessWidget {
  final Order order;

  const _TrackingHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: order.statusColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_statusIcon(order), color: order.statusColor, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تتبع الطلب',
                style: AppTypography.titleMedium.copyWith(
                  color: context.appText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${order.orderNumber} • ${order.dateFormatted}',
                style: AppTypography.bodySmall.copyWith(
                  color: context.appMutedText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  final Order order;

  const _CurrentStatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final message = order.isTrackingFinished
        ? (order.isDelivered ? 'تم إنهاء الطلب بنجاح' : 'تم إيقاف تتبع الطلب')
        : 'سيتم تحديث الحالة تلقائياً حسب آخر تحديث من المتجر';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: order.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: order.statusColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(order), color: order.statusColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusText,
                  style: AppTypography.titleSmall.copyWith(
                    color: order.statusColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.appMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final Order order;

  const _TrackingTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled) {
      return Column(
        children: [
          _TimelineStep(
            title: 'قيد الانتظار',
            subtitle: 'تم استلام الطلب',
            icon: Icons.pending_actions,
            color: AppColors.primaryDark,
            isCompleted: true,
            showConnector: true,
          ),
          _TimelineStep(
            title: 'ملغي',
            subtitle: order.cancelledReason ?? 'تم إلغاء الطلب',
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            isCompleted: true,
            isCurrent: true,
            showConnector: false,
          ),
        ],
      );
    }

    final steps = [
      _OrderTrackingStep(
        status: 'pending',
        title: 'قيد الانتظار',
        subtitle: 'تم استلام الطلب وينتظر بدء التحضير',
        icon: Icons.pending_actions,
        color: AppColors.primaryDark,
      ),
      _OrderTrackingStep(
        status: 'preparing',
        title: 'قيد التحضير',
        subtitle: 'يتم تجهيز الطلب قبل التسليم',
        icon: Icons.restaurant_menu,
        color: AppColors.secondary,
      ),
      _OrderTrackingStep(
        status: 'out_for_delivery',
        title: 'خرج للتوصيل',
        subtitle: 'الطلب مع المندوب وفي طريقه إليك',
        icon: Icons.local_shipping_outlined,
        color: AppColors.primaryLight,
      ),
      _OrderTrackingStep(
        status: 'delivered',
        title: 'تم التوصيل',
        subtitle: 'وصل الطلب إلى العميل',
        icon: Icons.delivery_dining,
        color: AppColors.success,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return _TimelineStep(
          title: step.title,
          subtitle: step.subtitle,
          icon: step.icon,
          color: step.color,
          isCompleted: _isStepCompleted(step.status),
          isCurrent: order.status == step.status,
          showConnector: index < steps.length - 1,
        );
      }),
    );
  }

  bool _isStepCompleted(String stepStatus) {
    final orderIndex = _statusOrder.indexOf(order.status);
    final stepIndex = _statusOrder.indexOf(stepStatus);

    if (orderIndex == -1 || stepIndex == -1) return false;
    return stepIndex <= orderIndex;
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final bool isCurrent;
  final bool showConnector;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isCompleted,
    this.isCurrent = false,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isCompleted ? color : AppColors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color
                    : context.appSoftBorder.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: color.withValues(alpha: 0.35), width: 5)
                    : null,
              ),
              child: Icon(
                icon,
                color: isCompleted ? AppColors.white : AppColors.grey,
                size: 21,
              ),
            ),
            if (showConnector)
              Container(
                width: 3,
                height: 34,
                color: isCompleted ? color : context.appSoftBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: effectiveColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.appMutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderTrackingStep {
  final String status;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _OrderTrackingStep({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

const _statusOrder = ['pending', 'preparing', 'out_for_delivery', 'delivered'];

IconData _statusIcon(Order order) {
  if (order.isCancelled) return Icons.cancel_outlined;
  if (order.isDelivered) return Icons.check_circle_outline;
  if (order.isOutForDelivery) return Icons.local_shipping_outlined;
  if (order.isPreparing) return Icons.restaurant_menu;
  return Icons.pending_actions;
}
