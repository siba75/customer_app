import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:dio/dio.dart';

class ProductPhotoApi {
  final Dio _dio;

  ProductPhotoApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<Map<String, dynamic>>> getProductPhotos(int productId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.productPhotosEndpoint}/product/$productId',
        options: await _authOptions(),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();

      throw Exception('صيغة بيانات صور المنتج غير صحيحة.');
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل صور المنتج.');
    }
  }

  Future<String?> getPrimaryPhotoUrl(int productId) async {
    final photos = await getProductPhotos(productId);

    for (final photo in photos) {
      final storedFile = photo['storedFile'] is Map<String, dynamic>
          ? photo['storedFile'] as Map<String, dynamic>
          : <String, dynamic>{};
      final storedFileId =
          photo['storedFileId']?.toString() ?? storedFile['id']?.toString();

      if (storedFileId != null && storedFileId.isNotEmpty) {
        return downloadUrl(storedFileId);
      }
    }

    return null;
  }

  String downloadUrl(String storedFileId) {
    return '${ApiConfig.baseUrl}${ApiConfig.productPhotosEndpoint}/download/$storedFileId';
  }

  Future<Options> _authOptions() async {
    final token = await SecureStorage.read('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
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
