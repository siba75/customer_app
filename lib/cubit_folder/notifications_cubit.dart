import 'package:customer_app/cubit_folder/notifications_state.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/dio/notifications_api.dart';
import 'package:customer_app/model/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsApi _api;
  static const int _pageLimit = 10;

  NotificationsCubit(this._api) : super(const NotificationsState.initial());

  Future<void> loadNotifications({bool refresh = true}) async {
    try {
      emit(
        state.copyWith(
          isLoading: refresh,
          isLoadingMore: false,
          offset: refresh ? 0 : state.offset,
        ),
      );

      final page = await _api.getMyNotifications(
        limit: _pageLimit,
        offset: refresh ? 0 : state.offset,
      );

      emit(
        state.copyWith(
          notifications: page.notifications,
          isLoading: false,
          total: page.total,
          limit: page.limit,
          offset: page.offset + page.notifications.length,
          isFinalPage: page.isFinalPage,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل الإشعارات.',
          ),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.isFinalPage) return;

    try {
      emit(state.copyWith(isLoadingMore: true));

      final page = await _api.getMyNotifications(
        limit: state.limit,
        offset: state.offset,
      );

      emit(
        state.copyWith(
          notifications: [...state.notifications, ...page.notifications],
          isLoadingMore: false,
          total: page.total,
          limit: page.limit,
          offset: page.offset + page.notifications.length,
          isFinalPage: page.isFinalPage,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل المزيد من الإشعارات.',
          ),
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
      final message = e.toString().replaceFirst('Exception: ', '');
      if (AppErrorMessages.isBackendSchemaError(message)) {
        emit(state.copyWith(clearUpdatingNotification: true));
        return;
      }

      emit(
        state.copyWith(
          notifications: _replaceNotification(notification),
          clearUpdatingNotification: true,
          errorMessage: AppErrorMessages.friendly(message),
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
