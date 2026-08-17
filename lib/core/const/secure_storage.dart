import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const authTokenKey = 'auth_token';
  static const refreshTokenKey = 'refresh_token';
  static const userEmailKey = 'user_email';
  static const sessionNoticeKey = 'session_notice';

  // كتابة القيمة في التخزين الآمن
  static Future<void> write(String key, String value) async {
    final nextValue = key == authTokenKey || key == refreshTokenKey
        ? _normalizeToken(value)
        : value;
    await _storage.write(key: key, value: nextValue);
  }

  // قراءة القيمة من التخزين الآمن
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // حذف القيمة من التخزين الآمن
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAuthSession({String? notice}) async {
    await delete(authTokenKey);
    await delete(refreshTokenKey);
    await delete(userEmailKey);

    if (notice == null || notice.trim().isEmpty) {
      await delete(sessionNoticeKey);
    } else {
      await write(sessionNoticeKey, notice.trim());
    }
  }

  static String _normalizeToken(String token) {
    final trimmed = token.trim();
    const bearerPrefix = 'Bearer ';

    if (trimmed.toLowerCase().startsWith(bearerPrefix.toLowerCase())) {
      return trimmed.substring(bearerPrefix.length).trim();
    }

    return trimmed;
  }
}
