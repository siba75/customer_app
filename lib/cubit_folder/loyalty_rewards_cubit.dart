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
      var policy = const LoyaltyPolicyModel.empty();
      var rewards = const <LoyaltyRewardModel>[];
      String? warningMessage;

      try {
        policy = await _api.getLoyaltyPolicy();
      } catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        warningMessage = AppErrorMessages.friendly(
          message,
          fallback: 'تعذر تحميل سياسة نقاط الولاء.',
        );
      }

      try {
        rewards = await _api.getAvailableLoyaltyRewards();
      } catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        final rewardsMessage = AppErrorMessages.friendly(
          message,
          fallback: 'تعذر تحميل مكافآت الولاء.',
        );
        warningMessage = warningMessage == null
            ? rewardsMessage
            : '$warningMessage\n$rewardsMessage';
      }

      emit(
        LoyaltyRewardsSuccess(
          rewards: rewards,
          policy: policy,
          warningMessage: warningMessage,
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
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(redeemingOfferId: reward.id, clearMessages: true),
    );

    try {
      final redemption = await _api.redeemReward(reward.id);
      final rewards = await _api.getAvailableLoyaltyRewards();

      emit(
        currentState.copyWith(
          rewards: rewards,
          clearRedeemingOffer: true,
          successMessage:
              'تم استبدال ${redemption.pointsSpent} نقطة وإنشاء الخصم بنجاح.',
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
        ),
      );
    }
  }
}
