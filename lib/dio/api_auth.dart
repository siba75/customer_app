import 'package:customer_app/core/const/secure_storage.dart';
import 'package:dio/dio.dart';

class ApiAuth {
  ApiAuth._();

  static const sessionExpiredMessage =
      'انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.';

  static Future<Options> options() async {
    final token = await SecureStorage.read(SecureStorage.authTokenKey);

    if (token == null || token.trim().isEmpty) {
      throw const ApiSessionExpiredException();
    }

    return Options(headers: {'Authorization': 'Bearer ${token.trim()}'});
  }

  static Future<void> throwIfUnauthorized(DioException error) async {
    if (!_isUnauthorized(error) && !_hasInvalidTokenMessage(error)) return;

    await SecureStorage.clearAuthSession(notice: sessionExpiredMessage);
    throw const ApiSessionExpiredException();
  }

  static String? readErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();
    }

    return data?.toString();
  }

  static bool _isUnauthorized(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 || statusCode == 403;
  }

  static bool _hasInvalidTokenMessage(DioException error) {
    final message = readErrorMessage(error)?.toLowerCase().trim();
    if (message == null || message.isEmpty) return false;

    return message.contains('invalid token') ||
        message.contains('jwt expired') ||
        message.contains('token expired') ||
        message.contains('unauthorized') ||
        message.contains('forbidden');
  }
}

class ApiSessionExpiredException implements Exception {
  const ApiSessionExpiredException();

  @override
  String toString() => ApiAuth.sessionExpiredMessage;
}
