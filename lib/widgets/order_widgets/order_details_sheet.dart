// lib/widgets/orders/order_details_sheet.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/order_model.dart';
import 'package:customer_app/widgets/order_widgets/status_chip.dart';
import 'package:flutter/material.dart';

class OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const OrderDetailsSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: context.appCardShadow(
              alpha: 0.16,
              blur: 32,
              offset: const Offset(0, -10),
            ),
          ),
          child: Column(
            children: [
              _buildDragHandle(context),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildInfoSection(
                        context,
                        title: 'عنوان التوصيل',
                        icon: Icons.location_on_outlined,
                        child: Text(
                          order.address,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.appMutedText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoSection(
                        context,
                        title: 'طريقة الدفع',
                        icon: Icons.payment_outlined,
                        child: Text(
                          order.paymentText,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.appMutedText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (order.hasTracking) _buildTrackingInfo(context),
                      const SizedBox(height: 20),
                      _buildInfoSection(
                        context,
                        title: 'المنتجات',
                        icon: Icons.shopping_bag_outlined,
                        child: _buildItemsList(context),
                      ),
                      const SizedBox(height: 20),
                      _buildPriceSummary(context),
                      if (order.appliedDiscountName != null &&
                          order.appliedDiscountName!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildInfoSection(
                          context,
                          title: 'الخصم المطبق',
                          icon: Icons.local_offer_outlined,
                          child: Text(
                            order.appliedDiscountName!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.appMutedText,
                            ),
                          ),
                        ),
                      ],
                      if (order.cancelledReason != null) ...[
                        const SizedBox(height: 20),
                        _buildCancelledReason(),
                      ],
                      const SizedBox(height: 24),
                      _buildCloseButton(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 50,
      height: 4,
      decoration: BoxDecoration(
        color: context.appSoftBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.orderNumber,
              style: AppTypography.headlineSmall.copyWith(
                color: context.appText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.dateFormatted} • ${order.time}',
              style: AppTypography.bodyMedium.copyWith(
                color: context.appMutedText,
              ),
            ),
          ],
        ),
        OrderStatusChip(text: order.statusText, color: order.statusColor),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: context.appText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.appBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appSoftBorder),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildTrackingInfo(BuildContext context) {
    return _buildInfoSection(
      context,
      title: 'معلومات التتبع',
      icon: Icons.track_changes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'رقم التتبع: ${order.trackingNumber}',
            style: AppTypography.bodyMedium.copyWith(
              color: context.appMutedText,
            ),
          ),
          if (order.estimatedDelivery != null)
            Text(
              'موعد التوصيل المتوقع: ${order.estimatedDelivery}',
              style: AppTypography.bodySmall.copyWith(
                color: context.appMutedText,
              ),
            ),
          if (order.deliveredAt != null)
            Text(
              'تم التوصيل في: ${order.deliveredAt}',
              style: AppTypography.bodySmall.copyWith(
                color: context.appMutedText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (context, index) =>
          Divider(color: context.appSoftBorder),
      itemBuilder: (context, index) {
        final item = order.items[index];
        final image = item.image;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image == null || image.isEmpty
                      ? const Icon(Icons.shopping_bag, color: AppColors.primary)
                      : Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.shopping_bag,
                                color: AppColors.primary,
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.titleSmall.copyWith(
                        color: context.appText,
                      ),
                    ),
                    Text(
                      'الكمية: ${item.quantity}',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.appMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.total.toStringAsFixed(2)}  ل.س',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    return _buildInfoSection(
      context,
      title: 'ملخص الأسعار',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _buildPriceRow(context, 'المجموع الفرعي', order.subtotal),
          _buildPriceRow(context, 'التوصيل', order.delivery),
          if (order.discount > 0)
            _buildPriceRow(context, 'الخصم', -order.discount),
          Divider(height: 24, color: context.appSoftBorder),
          _buildPriceRow(context, 'الإجمالي', order.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.titleMedium.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.bold,
                  )
                : AppTypography.bodyMedium.copyWith(
                    color: context.appMutedText,
                  ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}  ل.س',
            style: isTotal
                ? AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )
                : AppTypography.bodyMedium.copyWith(
                    color: context.appMutedText,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledReason() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              order.cancelledReason!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text('إغلاق', style: TextStyle(color: context.appMutedText)),
      ),
    );
  }
}
