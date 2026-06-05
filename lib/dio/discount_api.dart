import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:dio/dio.dart';

class DiscountApi {
  final Dio _dio;

  DiscountApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<DiscountModel>> getActiveDiscounts() async {
    try {
      final response = await _dio.get(
        ApiConfig.activeDiscountsEndpoint,
        options: await _authOptions(),
      );
      final data = _asMap(response.data);
      final discounts = data['data'];

      if (discounts is List) {
        return discounts
            .whereType<Map<String, dynamic>>()
            .map(DiscountModel.fromJson)
            .where((discount) => discount.isActive)
            .toList();
      }

      throw Exception('صيغة بيانات الخصومات غير صحيحة.');
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل الخصومات.');
    }
  }

  Future<DiscountCalculationModel> calculateDiscount({
    required int discountId,
    required double subtotal,
    int? customerId,
    int? productId,
    int? categoryId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.calculateDiscountEndpoint,
        data: {
          'customerId': customerId,
          'productId': productId,
          'categoryId': categoryId,
          'discountId': discountId,
          'subtotal': subtotal,
        },
        options: await _authOptions(),
      );

      return DiscountCalculationModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر حساب الخصم.');
    }
  }

  Future<Options> _authOptions() async {
    final token = await SecureStorage.read('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw Exception('صيغة بيانات الخصومات غير صحيحة.');
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
