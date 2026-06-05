import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/ad_model.dart';
import 'package:dio/dio.dart';

class AdsApi {
  final Dio _dio;

  AdsApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<AdModel>> getAds({bool activeOnly = true}) async {
    try {
      final response = await _dio.get(
        ApiConfig.adsEndpoint,
        queryParameters: {'activeOnly': activeOnly},
        options: await _authOptions(),
      );

      return _readAdsList(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل الإعلانات.');
    }
  }

  Future<Options> _authOptions() async {
    final token = await SecureStorage.read('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  List<AdModel> _readAdsList(dynamic data) {
    final ads = data is List ? data : _asMap(data)['data'];

    if (ads is List) {
      return ads
          .whereType<Map<String, dynamic>>()
          .map(AdModel.fromJson)
          .toList();
    }

    throw Exception('صيغة بيانات الإعلانات غير صحيحة.');
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw Exception('صيغة بيانات الإعلانات غير صحيحة.');
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
