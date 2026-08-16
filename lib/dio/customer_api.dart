import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/customer_profile_model.dart';
import 'package:dio/dio.dart';

class CustomerApi {
  final Dio _dio;

  CustomerApi([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 12),
            ),
          );

  Future<CustomerProfileModel> getProfile() async {
    try {
      final response = await _dio.get(
        ApiConfig.customerMeEndpoint,
        options: await _authOptions(),
      );

      return CustomerProfileModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      if (_isUnauthorized(e)) {
        throw const CustomerSessionExpiredException();
      }

      if (_isConnectionIssue(e)) {
        throw CustomerConnectionException(_connectionMessage);
      }

      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل بيانات الحساب.');
    }
  }

  Future<CustomerProfileModel> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConfig.customerMeEndpoint,
        data: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'address': address,
        },
        options: await _authOptions(),
      );

      return CustomerProfileModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      if (_isUnauthorized(e)) {
        throw const CustomerSessionExpiredException();
      }

      if (_isConnectionIssue(e)) {
        throw CustomerConnectionException(_connectionMessage);
      }

      throw Exception(_readErrorMessage(e) ?? 'تعذر تحديث بيانات الحساب.');
    }
  }

  Future<Options> _authOptions() async {
    final token = await SecureStorage.read(SecureStorage.authTokenKey);

    if (token == null || token.isEmpty) {
      throw const CustomerSessionExpiredException();
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw Exception('صيغة بيانات الحساب غير صحيحة.');
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

  bool _isUnauthorized(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  bool _isConnectionIssue(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.response == null;
  }

  String get _connectionMessage {
    if (ApiConfig.isLocalhost) {
      return 'التطبيق لا يستطيع الوصول للسيرفر. تأكدي أن adb reverse مفعّل وأن السيرفر يعمل على المنفذ 3000.';
    }

    return 'تعذر الاتصال بالسيرفر. تأكدي أن السيرفر يعمل على المنفذ 3000 وأن الموبايل واللابتوب على نفس الشبكة.';
  }
}

class CustomerSessionExpiredException implements Exception {
  const CustomerSessionExpiredException();

  @override
  String toString() => 'انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.';
}

class CustomerConnectionException implements Exception {
  final String message;

  const CustomerConnectionException(this.message);

  @override
  String toString() => message;
}
