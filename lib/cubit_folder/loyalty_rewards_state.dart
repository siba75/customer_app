import 'package:customer_app/model/loyalty_policy_model.dart';
import 'package:customer_app/model/loyalty_reward_model.dart';

abstract class LoyaltyRewardsState {
  const LoyaltyRewardsState();
}

class LoyaltyRewardsInitial extends LoyaltyRewardsState {
  const LoyaltyRewardsInitial();
}

class LoyaltyRewardsLoading extends LoyaltyRewardsState {
  const LoyaltyRewardsLoading();
}

class LoyaltyRewardsSuccess extends LoyaltyRewardsState {
  final List<LoyaltyRewardModel> rewards;
  final LoyaltyPolicyModel policy;
  final String? warningMessage;
  final String? redeemingOfferId;
  final String? successMessage;
  final String? errorMessage;
  final LoyaltyRedemptionModel? lastRedemption;

  const LoyaltyRewardsSuccess({
    required this.rewards,
    required this.policy,
    this.warningMessage,
    this.redeemingOfferId,
    this.successMessage,
    this.errorMessage,
    this.lastRedemption,
  });

  LoyaltyRewardsSuccess copyWith({
    List<LoyaltyRewardModel>? rewards,
    LoyaltyPolicyModel? policy,
    String? warningMessage,
    String? redeemingOfferId,
    String? successMessage,
    String? errorMessage,
    LoyaltyRedemptionModel? lastRedemption,
    bool clearRedeemingOffer = false,
    bool clearMessages = false,
    bool clearLastRedemption = false,
  }) {
    return LoyaltyRewardsSuccess(
      rewards: rewards ?? this.rewards,
      policy: policy ?? this.policy,
      warningMessage: warningMessage ?? this.warningMessage,
      redeemingOfferId: clearRedeemingOffer
          ? null
          : redeemingOfferId ?? this.redeemingOfferId,
      successMessage: clearMessages
          ? successMessage
          : successMessage ?? this.successMessage,
      errorMessage: clearMessages
          ? errorMessage
          : errorMessage ?? this.errorMessage,
      lastRedemption: clearLastRedemption
          ? null
          : lastRedemption ?? this.lastRedemption,
    );
  }
}

class LoyaltyRewardsError extends LoyaltyRewardsState {
  final String message;

  const LoyaltyRewardsError(this.message);
}
