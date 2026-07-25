import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

enum NotificationType { order, offer, account, reminder }

class NotificationsPage {
  final List<CustomerNotification> notifications;
  final int total;
  final int limit;
  final int offset;
  final bool isFinalPage;

  const NotificationsPage({
    required this.notifications,
    required this.total,
    required this.limit,
    required this.offset,
    required this.isFinalPage,
  });

  factory NotificationsPage.fromJson(dynamic data) {
    if (data is List) {
      return NotificationsPage(
        notifications: data
            .whereType<Map<String, dynamic>>()
            .map(CustomerNotification.fromJson)
            .toList(),
        total: data.length,
        limit: data.length,
        offset: 0,
        isFinalPage: true,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw Exception('صيغة بيانات الإشعارات غير صحيحة.');
    }

    final notificationsData = _readList(data);
    final notifications = notificationsData
        .whereType<Map<String, dynamic>>()
        .map(CustomerNotification.fromJson)
        .toList();

    return NotificationsPage(
      notifications: notifications,
      total: _readInt(data['total']) ?? notifications.length,
      limit: _readInt(data['limit']) ?? notifications.length,
      offset: _readInt(data['offset']) ?? 0,
      isFinalPage:
          CustomerNotification._toBool(data['isFinalPage']) ||
          CustomerNotification._toBool(data['is_final_page']) ||
          notifications.length <
              (_readInt(data['limit']) ?? notifications.length),
    );
  }

  static List<dynamic> _readList(Map<String, dynamic> data) {
    for (final key in ['data', 'notifications', 'items', 'results']) {
      final value = data[key];
      if (value is List) return value;
    }

    throw Exception('صيغة بيانات الإشعارات غير صحيحة.');
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class CustomerNotification {
  final String id;
  final String title;
  final String message;
  final DateTime? createdAt;
  final NotificationType type;
  final bool isRead;
  final String? actionText;

  const CustomerNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    required this.isRead,
    this.actionText,
  });

  factory CustomerNotification.fromJson(Map<String, dynamic> json) {
    final source = _notificationSource(json);
    final rawType = _readText(source, const [
      'type',
      'category',
      'notificationType',
      'notification_type',
    ]);
    final readAt = _readText(source, const ['readAt', 'read_at']);
    final isReadValue =
        json['isRead'] ??
        json['read'] ??
        json['seen'] ??
        json['is_read'] ??
        json['readStatus'];

    return CustomerNotification(
      id: _readText(source, const [
        'id',
        'notificationId',
        'notification_id',
        '_id',
      ]),
      title: _readText(source, const [
        'title',
        'subject',
        'name',
        'notificationTitle',
        'notification_title',
      ], fallback: 'إشعار جديد'),
      message: _readText(source, const [
        'message',
        'body',
        'description',
        'content',
        'notificationBody',
        'notification_body',
        'text',
      ], fallback: 'لديك تحديث جديد في حسابك.'),
      createdAt:
          _readDate(json, const ['createdAt', 'created_at', 'date']) ??
          _readDate(source, const ['createdAt', 'created_at', 'date']),
      type: _typeFrom(rawType, source),
      isRead: _toBool(isReadValue) || readAt.isNotEmpty,
      actionText: _optionalText(source, const [
        'actionText',
        'action_text',
        'action',
      ]),
    );
  }

  static Map<String, dynamic> _notificationSource(Map<String, dynamic> json) {
    for (final key in ['notification', 'data', 'payload']) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        return {...json, ...value};
      }
    }

    return json;
  }

  CustomerNotification copyWith({bool? isRead}) {
    return CustomerNotification(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      type: type,
      isRead: isRead ?? this.isRead,
      actionText: actionText,
    );
  }

  String get time {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    if (difference.inDays == 1) return 'أمس';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} أيام';

    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
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

  static NotificationType _typeFrom(String value, Map<String, dynamic> json) {
    final type = value.toLowerCase();
    final combinedText =
        '${_readText(json, const ['title'])} ${_readText(json, const ['message', 'body', 'description'])}'
            .toLowerCase();

    if (type.contains('order') ||
        type.contains('طلب') ||
        combinedText.contains('order') ||
        combinedText.contains('طلب')) {
      return NotificationType.order;
    }
    if (type.contains('offer') ||
        type.contains('discount') ||
        type.contains('عرض') ||
        combinedText.contains('discount') ||
        combinedText.contains('خصم') ||
        combinedText.contains('عرض')) {
      return NotificationType.offer;
    }
    if (type.contains('account') ||
        type.contains('loyalty') ||
        type.contains('حساب') ||
        combinedText.contains('loyalty') ||
        combinedText.contains('نقاط')) {
      return NotificationType.account;
    }

    return NotificationType.reminder;
  }

  static String _readText(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return fallback;
  }

  static String? _optionalText(Map<String, dynamic> json, List<String> keys) {
    final text = _readText(json, keys);
    return text.isEmpty ? null : text;
  }

  static DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
    final text = _readText(json, keys);
    return text.isEmpty ? null : DateTime.tryParse(text)?.toLocal();
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
