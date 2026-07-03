import 'package:customer_app/model/notification_model.dart';

class NotificationsState {
  final List<CustomerNotification> notifications;
  final bool isLoading;
  final String? updatingNotificationId;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.updatingNotificationId,
    this.errorMessage,
  });

  const NotificationsState.initial() : this();

  int get unreadCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  NotificationsState copyWith({
    List<CustomerNotification>? notifications,
    bool? isLoading,
    String? updatingNotificationId,
    String? errorMessage,
    bool clearUpdatingNotification = false,
    bool clearError = true,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      updatingNotificationId: clearUpdatingNotification
          ? null
          : updatingNotificationId ?? this.updatingNotificationId,
      errorMessage: clearError
          ? errorMessage
          : errorMessage ?? this.errorMessage,
    );
  }
}
