import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/dio/api_auth.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:dio/dio.dart';

class DiscountApi {
  final Dio _dio;

  DiscountApi([Dio? dio])
    : _dio = dio ?? ApiAuth.createDio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<DiscountModel>> getActiveDiscounts() async {
    try {
      final response = await _dio.get(
        ApiConfig.activeDiscountsEndpoint,
        options: await ApiAuth.options(),
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
      await ApiAuth.throwIfUnauthorized(e);
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
      final data = <String, dynamic>{
        'discountId': discountId,
        'subtotal': subtotal,
      };

      if (customerId != null) data['customerId'] = customerId;
      if (productId != null) data['productId'] = productId;
      if (categoryId != null) data['categoryId'] = categoryId;

      final response = await _dio.post(
        ApiConfig.calculateDiscountEndpoint,
        data: data,
        options: await ApiAuth.options(),
      );

      return DiscountCalculationModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر حساب الخصم.');
    }
  }

  Future<DiscountCalculationModel?> getBestDiscount({
    required double subtotal,
    int? productId,
    int? categoryId,
  }) async {
    if (subtotal <= 0) return null;

    try {
      final data = <String, dynamic>{'subtotal': subtotal};
      if (productId != null) data['productId'] = productId;
      if (categoryId != null) data['categoryId'] = categoryId;

      final response = await _dio.post(
        ApiConfig.bestDiscountEndpoint,
        data: data,
        options: await ApiAuth.options(),
      );

      final calculation = DiscountCalculationModel.fromJson(
        _asMap(response.data),
      );

      return calculation.discountId <= 0 ? null : calculation;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر حساب أفضل خصم.');
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw Exception('صيغة بيانات الخصومات غير صحيحة.');
  }

  String? _readErrorMessage(DioException error) {
    return ApiAuth.readErrorMessage(error);
  }
}
