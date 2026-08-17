import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/dio/api_auth.dart';
import 'package:customer_app/model/ad_model.dart';
import 'package:dio/dio.dart';

class AdsApi {
  final Dio _dio;

  AdsApi([Dio? dio])
    : _dio = dio ?? ApiAuth.createDio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<AdModel>> getAds({bool activeOnly = true}) async {
    try {
      final response = await _dio.get(
        ApiConfig.adsEndpoint,
        queryParameters: {'activeOnly': activeOnly},
        options: await ApiAuth.options(),
      );

      return _readAdsList(response.data);
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل الإعلانات.');
    }
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
    return ApiAuth.readErrorMessage(error);
  }
}
