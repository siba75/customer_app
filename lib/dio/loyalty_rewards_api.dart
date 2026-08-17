import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/dio/api_auth.dart';
import 'package:customer_app/model/loyalty_reward_model.dart';
import 'package:dio/dio.dart';

class LoyaltyRewardsApi {
  final Dio _dio;

  LoyaltyRewardsApi([Dio? dio])
    : _dio = dio ?? ApiAuth.createDio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<LoyaltyRewardModel>> getAvailableLoyaltyRewards() async {
    try {
      final response = await _dio.get(
        ApiConfig.loyaltyRewardsAvailableEndpoint,
        options: await ApiAuth.options(),
      );

      return _readRewardsList(response.data);
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر تحميل مكافآت الولاء.');
    }
  }

  Future<LoyaltyRedemptionModel> redeemReward(String offerId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.loyaltyRewardsEndpoint}/redeem',
        data: {'offerId': offerId},
        options: await ApiAuth.options(),
      );

      return LoyaltyRedemptionModel.fromJson(_readMap(response.data));
    } on DioException catch (e) {
      await ApiAuth.throwIfUnauthorized(e);
      throw Exception(_readErrorMessage(e) ?? 'تعذر استبدال المكافأة.');
    }
  }

  List<LoyaltyRewardModel> _readRewardsList(dynamic data) {
    final rewards = data is List ? data : _asMap(data)['data'];

    if (rewards is List) {
      return rewards
          .whereType<Map>()
          .map((reward) => Map<String, dynamic>.from(reward))
          .map(LoyaltyRewardModel.fromJson)
          .toList();
    }

    throw Exception('صيغة بيانات مكافآت الولاء غير صحيحة.');
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('صيغة بيانات مكافآت الولاء غير صحيحة.');
  }

  Map<String, dynamic> _readMap(dynamic data) {
    final response = _asMap(data);
    final nested = response['data'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return response;
  }

  String? _readErrorMessage(DioException error) {
    return ApiAuth.readErrorMessage(error);
  }
}
