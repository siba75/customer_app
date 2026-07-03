import 'package:customer_app/cubit_folder/notifications_state.dart';
import 'package:customer_app/dio/notifications_api.dart';
import 'package:customer_app/model/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsApi _api;

  NotificationsCubit(this._api) : super(const NotificationsState.initial());

  Future<void> loadNotifications() async {
    try {
      emit(state.copyWith(isLoading: true));
      final notifications = await _api.getMyNotifications();
      emit(state.copyWith(notifications: notifications, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> markAsRead(CustomerNotification notification) async {
    if (notification.isRead) return;
    await _setReadStatus(notification, isRead: true);
  }

  Future<void> markAsUnread(CustomerNotification notification) {
    return _setReadStatus(notification, isRead: false);
  }

  Future<void> markAllAsRead() async {
    final unreadNotifications = state.notifications
        .where((notification) => !notification.isRead)
        .toList();

    for (final notification in unreadNotifications) {
      await markAsRead(notification);
    }
  }

  Future<void> _setReadStatus(
    CustomerNotification notification, {
    required bool isRead,
  }) async {
    emit(state.copyWith(updatingNotificationId: notification.id));

    final optimisticNotifications = _replaceNotification(
      notification.copyWith(isRead: isRead),
    );
    emit(state.copyWith(notifications: optimisticNotifications));

    try {
      final updatedNotification = isRead
          ? await _api.markAsRead(notification.id)
          : await _api.markAsUnread(notification.id);

      if (updatedNotification == null) {
        emit(state.copyWith(clearUpdatingNotification: true));
        return;
      }

      emit(
        state.copyWith(
          notifications: _replaceNotification(updatedNotification),
          clearUpdatingNotification: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          notifications: _replaceNotification(notification),
          clearUpdatingNotification: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  List<CustomerNotification> _replaceNotification(
    CustomerNotification updatedNotification,
  ) {
    return state.notifications.map((notification) {
      if (notification.id != updatedNotification.id) return notification;
      return updatedNotification;
    }).toList();
  }
}
