// lib/widgets/orders/order_reorder_dialog.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/model/order_model.dart';
import 'package:flutter/material.dart';

class OrderReorderDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onConfirm;

  const OrderReorderDialog({
    super.key,
    required this.order,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('طلب مجدد'),
      content: Text(
        'هل تريد إعادة طلب المنتجات من الطلب ${order.orderNumber}؟',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: TextStyle(color: AppColors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('تأكيد', style: TextStyle(color: AppColors.white)),
        ),
      ],
    );
  }
}
