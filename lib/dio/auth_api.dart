import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/model/signin_model.dart';
import 'package:customer_app/model/signup_model.dart';
import 'package:customer_app/model/verify_otp_model.dart';
import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;

  AuthApi([Dio? dio])
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

  Future<Map<String, dynamic>> signup(SignupModel model) async {
    try {
      final response = await _dio.post(
        ApiConfig.signupEndpoint,
        data: model.toJson(),
      );
      return response.data;
    } on DioException catch (e) {
      // التحقق من الخطأ
      if (e.response?.statusCode == 409) {
        throw Exception('البريد الإلكتروني أو رقم الهوية موجود مسبقًا.');
      } else {
        throw Exception('حدث خطأ غير متوقع.');
      }
    }
  }

  Future<Map<String, dynamic>> signin(SigninModel model) async {
    try {
      final response = await _dio.post(
        ApiConfig.signinEndpoint,
        data: model.toJson(),
      );

      return _asResponseMap(response.data, 'تم تسجيل الدخول بنجاح');
    } on DioException catch (e) {
      final message = _readErrorMessage(e);

      if (_isConnectionIssue(e)) {
        throw AuthConnectionException(_connectionMessage);
      }

      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw Exception(
          message ?? 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        );
      }

      if (e.response?.statusCode == 403) {
        throw Exception(message ?? 'يرجى تأكيد الحساب قبل تسجيل الدخول.');
      }

      throw Exception(
        AppErrorMessages.friendly(
          message,
          fallback: 'تعذر تسجيل الدخول، حاول مرة أخرى.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required VerifyOtpModel model,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.verifyEndpoint,
        data: model.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _asResponseMap(response.data, 'تم التحقق بنجاح');
    } on DioException catch (e) {
      final message = _readErrorMessage(e);

      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw Exception(message ?? 'رمز التحقق غير صحيح.');
      }

      throw Exception(message ?? 'تعذر التحقق من الرمز، حاول مرة أخرى.');
    }
  }

  Future<Map<String, dynamic>> refreshTokens(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConfig.refreshTokensEndpoint,
        data: {'refresh_token': refreshToken},
      );

      return _asResponseMap(response.data, 'تم تجديد الجلسة بنجاح');
    } on DioException catch (e) {
      final message = _readErrorMessage(e);

      if (_isConnectionIssue(e)) {
        throw AuthConnectionException(_connectionMessage);
      }

      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw Exception(
          message ?? 'انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.',
        );
      }

      throw Exception(
        AppErrorMessages.friendly(
          message,
          fallback: 'تعذر تجديد الجلسة، الرجاء تسجيل الدخول مرة أخرى.',
        ),
      );
    }
  }

  Map<String, dynamic> _asResponseMap(dynamic data, String fallbackMessage) {
    return data is Map<String, dynamic>
        ? data
        : {'message': data?.toString() ?? fallbackMessage};
  }

  static String? readToken(Map<String, dynamic> data) {
    final directToken =
        data['accessToken'] ??
        data['token'] ??
        data['access_token'] ??
        data['jwt'];

    if (directToken != null) {
      return directToken.toString();
    }

    for (final key in ['data', 'user']) {
      final nested = data[key];
      if (nested is Map<String, dynamic>) {
        final nestedToken =
            nested['accessToken'] ??
            nested['token'] ??
            nested['access_token'] ??
            nested['jwt'];

        if (nestedToken != null) {
          return nestedToken.toString();
        }
      }
    }

    return null;
  }

  static String? readRefreshToken(Map<String, dynamic> data) {
    final directToken =
        data['refreshToken'] ?? data['refresh_token'] ?? data['refresh'];

    if (directToken != null) {
      return directToken.toString();
    }

    for (final key in ['data', 'user']) {
      final nested = data[key];
      if (nested is Map<String, dynamic>) {
        final nestedToken =
            nested['refreshToken'] ??
            nested['refresh_token'] ??
            nested['refresh'];

        if (nestedToken != null) {
          return nestedToken.toString();
        }
      }
    }

    return null;
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

    return 'تعذر الاتصال بالسيرفر. تأكد أن السيرفر يعمل على المنفذ 3000 وأن الموبايل واللابتوب على نفس الشبكة.';
  }
}

class AuthConnectionException implements Exception {
  final String message;

  const AuthConnectionException(this.message);

  @override
  String toString() => message;
}
