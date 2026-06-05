import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/model/order_model.dart';
import 'package:dio/dio.dart';

class OrderApi {
  final Dio _dio;

  OrderApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get(
        ApiConfig.customerOrdersEndpoint,
        options: await _authOptions(),
      );

      return _readOrdersList(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل الطلبات.');
    }
  }

  Future<Order> getOrder(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.customerOrdersEndpoint}/$id',
        options: await _authOptions(),
      );

      return Order.fromJson(_readOrderMap(response.data));
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل تفاصيل الطلب.');
    }
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    int? discountId,
    int loyaltyPointsUsed = 0,
    String? deliveryAddress,
  }) async {
    try {
      final orderItems = items
          .where((item) => item.productId != null)
          .map(
            (item) => {'productId': item.productId, 'quantity': item.quantity},
          )
          .toList();

      if (orderItems.isEmpty) {
        throw Exception('لا توجد منتجات صالحة لإرسال الطلب.');
      }

      final response = await _dio.post(
        ApiConfig.customerOrdersEndpoint,
        data: {
          'discountId': discountId,
          'loyaltyPointsUsed': loyaltyPointsUsed,
          if (deliveryAddress != null && deliveryAddress.trim().isNotEmpty)
            'deliveryAddress': deliveryAddress.trim(),
          'items': orderItems,
        },
        options: await _authOptions(),
      );

      return Order.fromJson(_readOrderMap(response.data));
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر إنشاء الطلب.');
    }
  }

  Future<Order> cancelOrder(int id) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.customerOrdersEndpoint}/$id/cancel',
        options: await _authOptions(),
      );

      return Order.fromJson(_readOrderMap(response.data));
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر إلغاء الطلب.');
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
    throw Exception('صيغة بيانات الطلب غير صحيحة.');
  }

  Map<String, dynamic> _readOrderMap(dynamic data) {
    final response = _asMap(data);
    final order = response['data'];

    if (order is Map<String, dynamic>) return order;
    return response;
  }

  List<Order> _readOrdersList(dynamic data) {
    final orders = data is List ? data : _asMap(data)['data'];

    if (orders is List) {
      return orders
          .whereType<Map<String, dynamic>>()
          .map(Order.fromJson)
          .toList();
    }

    throw Exception('صيغة بيانات الطلبات غير صحيحة.');
  }

  String? _readErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return _localizeError(
        data['message']?.toString() ??
            data['error']?.toString() ??
            data['detail']?.toString(),
      );
    }

    return _localizeError(data?.toString());
  }

  String? _localizeError(String? message) {
    if (message == null || message.isEmpty) return message;

    final stockMatch = RegExp(
      r'Insufficient stock for product "(.+)" \(available: (\d+)\)',
    ).firstMatch(message);

    if (stockMatch != null) {
      final productName = stockMatch.group(1) ?? 'المنتج';
      final available = stockMatch.group(2) ?? '0';
      return 'الكمية المطلوبة من $productName أكبر من المخزون المتاح ($available).';
    }

    return message;
  }
}
