import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

enum NotificationType { order, offer, account, reminder }

class CustomerNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isRead;
  final String? actionText;

  const CustomerNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
    this.actionText,
  });

  CustomerNotification copyWith({bool? isRead}) {
    return CustomerNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      type: type,
      isRead: isRead ?? this.isRead,
      actionText: actionText,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.order:
        return Icons.receipt_long_outlined;
      case NotificationType.offer:
        return Icons.local_offer_outlined;
      case NotificationType.account:
        return Icons.person_outline;
      case NotificationType.reminder:
        return Icons.notifications_active_outlined;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.order:
        return AppColors.primary;
      case NotificationType.offer:
        return AppColors.secondary;
      case NotificationType.account:
        return AppColors.success;
      case NotificationType.reminder:
        return AppColors.error;
    }
  }
}

const List<CustomerNotification> mockNotifications = [
  CustomerNotification(
    id: 'NTF-001',
    title: 'طلبك قيد التجهيز',
    message: 'تم استلام طلبك SM-2024-003 وسيتم تجهيزه خلال وقت قصير.',
    time: 'منذ 10 دقائق',
    type: NotificationType.order,
    isRead: false,
    actionText: 'تتبع الطلب',
  ),
  CustomerNotification(
    id: 'NTF-002',
    title: 'خصم 25% على الفواكه',
    message: 'استفيدي من العرض اليوم على التفاح والبرتقال الطازج.',
    time: 'منذ ساعة',
    type: NotificationType.offer,
    isRead: false,
    actionText: 'تسوقي الآن',
  ),
  CustomerNotification(
    id: 'NTF-003',
    title: 'نقاط ولاء جديدة',
    message: 'تمت إضافة 120 نقطة إلى حسابك بعد آخر عملية شراء.',
    time: 'أمس',
    type: NotificationType.account,
    isRead: false,
  ),
  CustomerNotification(
    id: 'NTF-004',
    title: 'لا تنسي سلتك',
    message: 'منتجاتك المختارة لا تزال في السلة ويمكنك إكمال الطلب الآن.',
    time: 'قبل يومين',
    type: NotificationType.reminder,
    isRead: true,
    actionText: 'فتح السلة',
  ),
  CustomerNotification(
    id: 'NTF-005',
    title: 'تم توصيل الطلب',
    message: 'طلبك SM-2024-001 وصل بنجاح. نتمنى لك تجربة لطيفة.',
    time: '15 يناير',
    type: NotificationType.order,
    isRead: true,
  ),
];
