import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/dio/api_auth.dart';
import 'package:customer_app/model/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationsApi {
  final Dio _dio;

  NotificationsApi([Dio? dio])
    : _dio = dio ?? ApiAuth.createDio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<NotificationsPage> getMyNotifications({
    int limit = 10,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (unreadOnly) {
        queryParameters['unreadOnly'] = true;
      }

      final response = await _dio.get(
        ApiConfig.notificationsMeEndpoint,
        queryParameters: queryParameters,
        options: await ApiAuth.options(),
      );

      return NotificationsPage.fromJson(response.data);
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل الإشعارات.');
    }
  }

  Future<CustomerNotification?> markAsRead(String id) {
    return _updateReadStatus(id: id, isRead: true);
  }

  Future<CustomerNotification?> markAsUnread(String id) {
    return _updateReadStatus(id: id, isRead: false);
  }

  Future<void> registerDeviceToken({
    required String token,
    String platform = 'android',
  }) async {
    try {
      await _dio.post(
        ApiConfig.notificationDeviceTokenEndpoint,
        data: {
          'token': token,
          'fcmToken': token,
          'deviceToken': token,
          'platform': platform,
        },
        options: await ApiAuth.options(),
      );
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر تسجيل جهاز الإشعارات.');
    }
  }

  Future<CustomerNotification?> _updateReadStatus({
    required String id,
    required bool isRead,
  }) async {
    try {
      final action = isRead ? 'read' : 'unread';
      final response = await _dio.patch(
        '${ApiConfig.notificationsEndpoint}/$id/$action',
        options: await ApiAuth.options(),
      );

      return _readNotification(response.data);
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحديث حالة الإشعار.');
    }
  }

  CustomerNotification? _readNotification(dynamic data) {
    if (data is Map<String, dynamic>) {
      final notification = data['data'];
      if (notification is Map<String, dynamic>) {
        return CustomerNotification.fromJson(notification);
      }

      return CustomerNotification.fromJson(data);
    }

    return null;
  }

  String? _readErrorMessage(DioException error) {
    return ApiAuth.readErrorMessage(error);
  }
}
