import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/model/loyalty_reward_model.dart';
import 'package:dio/dio.dart';

class LoyaltyRewardsApi {
  final Dio _dio;

  LoyaltyRewardsApi([Dio? dio])
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<LoyaltyRewardModel>> getAvailableLoyaltyRewards() async {
    try {
      final response = await _dio.get(
        ApiConfig.loyaltyRewardsAvailableEndpoint,
        options: await _authOptions(),
      );

      return _readRewardsList(response.data);
    } on DioException catch (e) {
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل مكافآت الولاء.');
    }
  }

  Future<Options> _authOptions() async {
    final token = await SecureStorage.read('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  List<LoyaltyRewardModel> _readRewardsList(dynamic data) {
    final rewards = data is List ? data : _asMap(data)['data'];

    if (rewards is List) {
      return rewards
          .whereType<Map<String, dynamic>>()
          .map(LoyaltyRewardModel.fromJson)
          .toList();
    }

    throw Exception('صيغة بيانات مكافآت الولاء غير صحيحة.');
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw Exception('صيغة بيانات مكافآت الولاء غير صحيحة.');
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
