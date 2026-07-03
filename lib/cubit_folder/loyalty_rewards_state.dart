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

  const LoyaltyRewardsSuccess(this.rewards);
}

class LoyaltyRewardsError extends LoyaltyRewardsState {
  final String message;

  const LoyaltyRewardsError(this.message);
}
