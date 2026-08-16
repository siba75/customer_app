import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/dio/api_auth.dart';
import 'package:customer_app/model/category_model.dart';
import 'package:dio/dio.dart';

class CategoryApi {
  final Dio _dio;

  CategoryApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(
        ApiConfig.categoriesEndpoint,
        options: await ApiAuth.options(),
      );
      final data = _asMap(response.data);
      final categories = data['data'];

      if (categories is List) {
        return categories
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList();
      }

      throw Exception('صيغة بيانات التصنيفات غير صحيحة.');
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل التصنيفات.');
    }
  }

  Future<CategoryModel> getCategory(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.categoriesEndpoint}/$id',
        options: await ApiAuth.options(),
      );

      return CategoryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل منتجات التصنيف.');
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw Exception('صيغة بيانات التصنيفات غير صحيحة.');
  }

  String? _readErrorMessage(DioException error) {
    return ApiAuth.readErrorMessage(error);
  }
}
