
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // كتابة القيمة في التخزين الآمن
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // قراءة القيمة من التخزين الآمن
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // حذف القيمة من التخزين الآمن
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}