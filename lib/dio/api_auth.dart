import 'dart:convert';

import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:dio/dio.dart';

class ApiAuth {
  ApiAuth._();

  static const sessionExpiredMessage =
      'انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.';
  static Future<String?>? _refreshFuture;

  static Dio createDio([BaseOptions? options]) {
    final dio = Dio(
      options ??
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 12),
          ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_shouldAttachAuth(options)) {
            final token = await accessToken();
            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.trim()}';
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (!_canRefresh(error)) {
            handler.next(error);
            return;
          }

          final newAccessToken = await _refreshAccessToken();
          if (newAccessToken == null || newAccessToken.isEmpty) {
            handler.next(error);
            return;
          }

          try {
            final requestOptions = error.requestOptions;
            requestOptions.extra['auth_retry'] = true;
            requestOptions.headers['Authorization'] =
                'Bearer ${newAccessToken.trim()}';

            final response = await dio.fetch<dynamic>(requestOptions);
            handler.resolve(response);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );

    return dio;
  }

  static Future<Options> options() async {
    final token = await accessToken();

    if (token == null || token.trim().isEmpty) {
      throw const ApiSessionExpiredException();
    }

    return Options(headers: {'Authorization': 'Bearer ${token.trim()}'});
  }

  static Future<String?> accessToken() async {
    final token = await SecureStorage.read(SecureStorage.authTokenKey);

    if (token == null || token.trim().isEmpty) {
      return _refreshAccessToken();
    }

    if (_isJwtExpiredOrAlmostExpired(token)) {
      return _refreshAccessToken();
    }

    return token.trim();
  }

  static Future<void> throwIfUnauthorized(DioException error) async {
    if (!_isUnauthorized(error) && !_hasInvalidTokenMessage(error)) return;

    await expireSession();
    throw const ApiSessionExpiredException();
  }

  static Future<void> expireSession({String? notice}) {
    return SecureStorage.clearAuthSession(
      notice: notice ?? sessionExpiredMessage,
    );
  }

  static String? readErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return map['message']?.toString() ??
          map['error']?.toString() ??
          map['detail']?.toString();
    }

    return data?.toString();
  }

  static bool _shouldAttachAuth(RequestOptions options) {
    if (options.extra['skip_auth'] == true) return false;
    if (_isAuthEndpoint(options.path)) {
      return false;
    }

    return !options.headers.containsKey('Authorization');
  }

  static bool _canRefresh(DioException error) {
    final requestOptions = error.requestOptions;
    if (requestOptions.extra['auth_retry'] == true) return false;
    if (_isAuthEndpoint(requestOptions.path)) return false;

    return _isUnauthorized(error) || _hasInvalidTokenMessage(error);
  }

  static bool _isAuthEndpoint(String path) {
    return path.endsWith(ApiConfig.signinEndpoint) ||
        path.endsWith(ApiConfig.signupEndpoint) ||
        path.endsWith(ApiConfig.verifyEndpoint) ||
        path.endsWith(ApiConfig.refreshTokensEndpoint);
  }

  static Future<String?> _refreshAccessToken() {
    final activeRefresh = _refreshFuture;
    if (activeRefresh != null) return activeRefresh;

    final refresh = _requestNewTokens();
    _refreshFuture = refresh.whenComplete(() => _refreshFuture = null);
    return _refreshFuture!;
  }

  static Future<String?> _requestNewTokens() async {
    final refreshToken = await SecureStorage.read(
      SecureStorage.refreshTokenKey,
    );
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      await expireSession();
      return null;
    }

    try {
      final data = await AuthApi().refreshTokens(refreshToken);
      final accessToken = AuthApi.readToken(data);
      final nextRefreshToken = AuthApi.readRefreshToken(data);

      if (accessToken == null || accessToken.trim().isEmpty) {
        await expireSession();
        return null;
      }

      await SecureStorage.write(SecureStorage.authTokenKey, accessToken);
      if (nextRefreshToken != null && nextRefreshToken.trim().isNotEmpty) {
        await SecureStorage.write(
          SecureStorage.refreshTokenKey,
          nextRefreshToken,
        );
      }

      return accessToken;
    } on AuthConnectionException {
      return SecureStorage.read(SecureStorage.authTokenKey);
    } catch (_) {
      await expireSession();
      return null;
    }
  }

  static bool _isUnauthorized(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401;
  }

  static bool _hasInvalidTokenMessage(DioException error) {
    final message = readErrorMessage(error)?.toLowerCase().trim();
    if (message == null || message.isEmpty) return false;

    return message.contains('invalid token') ||
        message.contains('jwt expired') ||
        message.contains('token expired') ||
        message.contains('unauthorized');
  }

  static bool _isJwtExpiredOrAlmostExpired(String token) {
    final parts = token.trim().split('.');
    if (parts.length != 3) return false;

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) return false;

      final exp = json['exp'];
      if (exp is! num) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
      return expiry.isBefore(
        DateTime.now().toUtc().add(const Duration(minutes: 2)),
      );
    } catch (_) {
      return false;
    }
  }
}

class ApiSessionExpiredException implements Exception {
  const ApiSessionExpiredException();

  @override
  String toString() => ApiAuth.sessionExpiredMessage;
}
