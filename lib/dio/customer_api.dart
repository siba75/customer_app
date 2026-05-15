import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/customer_profile_model.dart';
import 'package:dio/dio.dart';

class CustomerApi {
  final Dio _dio;

  CustomerApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<CustomerProfileModel> getProfile() async {
    try {
      final response = await _dio.get(
        ApiConfig.customerMeEndpoint,
        options: await _authOptions(),
      );

      return CustomerProfileModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل بيانات الحساب.');
    }
  }

  Future<CustomerProfileModel> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConfig.customerMeEndpoint,
        data: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'address': address,
        },
        options: await _authOptions(),
      );

      return CustomerProfileModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحديث بيانات الحساب.');
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
    throw Exception('صيغة بيانات الحساب غير صحيحة.');
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
