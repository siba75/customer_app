import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationsApi {
  final Dio _dio;

  NotificationsApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<CustomerNotification>> getMyNotifications() async {
    try {
      final response = await _dio.get(
        ApiConfig.notificationsMeEndpoint,
        options: await _authOptions(),
      );

      return _readNotificationsList(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل الإشعارات.');
    }
  }

  Future<CustomerNotification?> markAsRead(String id) {
    return _updateReadStatus(id: id, isRead: true);
  }

  Future<CustomerNotification?> markAsUnread(String id) {
    return _updateReadStatus(id: id, isRead: false);
  }

  Future<CustomerNotification?> _updateReadStatus({
    required String id,
    required bool isRead,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.notificationsEndpoint}/$id/${isRead ? 'read' : 'unread'}',
        options: await _authOptions(),
      );

      return _readNotification(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحديث حالة الإشعار.');
    }
  }

  Future<Options> _authOptions() async {
    final token = await SecureStorage.read('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  List<CustomerNotification> _readNotificationsList(dynamic data) {
    final notifications = data is List ? data : _asMap(data)['data'];

    if (notifications is List) {
      return notifications
          .whereType<Map<String, dynamic>>()
          .map(CustomerNotification.fromJson)
          .toList();
    }

    throw Exception('صيغة بيانات الإشعارات غير صحيحة.');
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

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw Exception('صيغة بيانات الإشعارات غير صحيحة.');
  }

  String? _readErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();
    }

    return data?.toString();
  }
}
