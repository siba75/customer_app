import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/notification_model.dart';
import 'package:customer_app/widgets/notification_widgets/notification_card.dart';
import 'package:customer_app/widgets/notification_widgets/notification_empty_state.dart';
import 'package:customer_app/widgets/notification_widgets/notification_filter_tabs.dart';
import 'package:customer_app/widgets/notification_widgets/notification_summary_header.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';
  late List<CustomerNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(mockNotifications);
  }

  int get _unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  List<CustomerNotification> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'unread':
        return _notifications
            .where((notification) => !notification.isRead)
            .toList();
      case 'orders':
        return _notifications
            .where(
              (notification) => notification.type == NotificationType.order,
            )
            .toList();
      case 'offers':
        return _notifications
            .where(
              (notification) => notification.type == NotificationType.offer,
            )
            .toList();
      default:
        return _notifications;
    }
  }

  void _markAsRead(CustomerNotification selectedNotification) {
    if (selectedNotification.isRead) return;

    setState(() {
      _notifications = _notifications.map((notification) {
        if (notification.id != selectedNotification.id) return notification;
        return notification.copyWith(isRead: true);
      }).toList();
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(title: const Text('الإشعارات')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: NotificationSummaryHeader(
              totalCount: _notifications.length,
              unreadCount: _unreadCount,
              onMarkAllRead: _markAllAsRead,
            ),
          ),
          SliverToBoxAdapter(
            child: NotificationFilterTabs(
              selectedFilter: _selectedFilter,
              onChanged: (filter) => setState(() => _selectedFilter = filter),
            ),
          ),
          if (filteredNotifications.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: NotificationEmptyState(
                title: _emptyTitle,
                subtitle: _emptySubtitle,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList.builder(
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () => _markAsRead(notification),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String get _emptyTitle {
    switch (_selectedFilter) {
      case 'unread':
        return 'لا توجد إشعارات جديدة';
      case 'orders':
        return 'لا توجد إشعارات طلبات';
      case 'offers':
        return 'لا توجد عروض حالياً';
      default:
        return 'لا توجد إشعارات';
    }
  }

  String get _emptySubtitle {
    switch (_selectedFilter) {
      case 'unread':
        return 'كل شيء مقروء ومرتب لديك.';
      case 'orders':
        return 'سنخبرك هنا بكل تحديثات الطلبات القادمة.';
      case 'offers':
        return 'العروض والخصومات الجديدة ستظهر هنا.';
      default:
        return 'عند وصول أي تحديث جديد سيظهر في هذه الصفحة.';
    }
  }
}
