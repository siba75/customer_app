import 'package:customer_app/cubit_folder/loyalty_rewards_state.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/dio/loyalty_rewards_api.dart';
import 'package:customer_app/model/loyalty_policy_model.dart';
import 'package:customer_app/model/loyalty_reward_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyRewardsCubit extends Cubit<LoyaltyRewardsState> {
  final LoyaltyRewardsApi _api;

  LoyaltyRewardsCubit(this._api) : super(const LoyaltyRewardsInitial());

  Future<void> loadRewards() async {
    emit(const LoyaltyRewardsLoading());

    try {
      final rewards = await _api.getAvailableLoyaltyRewards();

      emit(
        LoyaltyRewardsSuccess(
          rewards: rewards,
          policy: const LoyaltyPolicyModel.empty(),
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        LoyaltyRewardsError(
          AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل نقاط الولاء.',
          ),
        ),
      );
    }
  }

  Future<void> redeemReward(LoyaltyRewardModel reward) async {
    final currentState = state;
    if (currentState is! LoyaltyRewardsSuccess ||
        currentState.redeemingOfferId != null) {
      return;
    }

    if (!reward.canRedeem) {
      emit(
        currentState.copyWith(
          errorMessage: 'نقاطك غير كافية لاستبدال هذه المكافأة.',
          clearMessages: true,
          clearLastRedemption: true,
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        redeemingOfferId: reward.id,
        clearMessages: true,
        clearLastRedemption: true,
      ),
    );

    try {
      final redemption = await _api.redeemReward(reward.id);
      final rewards = await _api.getAvailableLoyaltyRewards();

      emit(
        currentState.copyWith(
          rewards: rewards,
          clearRedeemingOffer: true,
          lastRedemption: redemption,
          successMessage:
              'تم تحويل ${redemption.pointsSpent} نقطة إلى خصم جاهز للاستخدام عند إتمام الطلب.',
          clearMessages: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        currentState.copyWith(
          clearRedeemingOffer: true,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر استبدال المكافأة.',
          ),
          clearMessages: true,
          clearLastRedemption: true,
        ),
      );
    }
  }
}
