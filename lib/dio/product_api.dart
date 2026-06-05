import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/product_model.dart';
import 'package:dio/dio.dart';

class ProductApi {
  final Dio _dio;

  ProductApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get(
        ApiConfig.productsEndpoint,
        options: await _authOptions(),
      );

      return _readProductsList(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل المنتجات.');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.productsEndpoint}/category/$categoryId',
        options: await _authOptions(),
      );

      return _readProductsList(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل منتجات التصنيف.');
    }
  }

  Future<List<ProductModel>> getProductsBySupplier(int supplierId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.productsEndpoint}/supplier/$supplierId',
        options: await _authOptions(),
      );

      return _readProductsList(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل منتجات المورد.');
    }
  }

  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.productsEndpoint}/$id',
        options: await _authOptions(),
      );

      return ProductModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل تفاصيل المنتج.');
    }
  }

  List<ProductModel> _readProductsList(dynamic data) {
    final response = _asMap(data);
    final products = response['data'];

    if (products is List) {
      return products
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }

    throw Exception('صيغة بيانات المنتجات غير صحيحة.');
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
    throw Exception('صيغة بيانات المنتجات غير صحيحة.');
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
