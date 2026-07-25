import 'package:customer_app/model/notification_model.dart';

class NotificationsState {
  final List<CustomerNotification> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final int total;
  final int limit;
  final int offset;
  final bool isFinalPage;
  final String? updatingNotificationId;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.total = 0,
    this.limit = 10,
    this.offset = 0,
    this.isFinalPage = true,
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
    bool? isLoadingMore,
    int? total,
    int? limit,
    int? offset,
    bool? isFinalPage,
    String? updatingNotificationId,
    String? errorMessage,
    bool clearUpdatingNotification = false,
    bool clearError = true,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isFinalPage: isFinalPage ?? this.isFinalPage,
      updatingNotificationId: clearUpdatingNotification
          ? null
          : updatingNotificationId ?? this.updatingNotificationId,
      errorMessage: clearError
          ? errorMessage
          : errorMessage ?? this.errorMessage,
    );
  }
}
