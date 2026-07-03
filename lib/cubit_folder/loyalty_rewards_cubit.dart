import 'package:customer_app/cubit_folder/loyalty_rewards_state.dart';
import 'package:customer_app/dio/loyalty_rewards_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyRewardsCubit extends Cubit<LoyaltyRewardsState> {
  final LoyaltyRewardsApi _api;

  LoyaltyRewardsCubit(this._api) : super(const LoyaltyRewardsInitial());

  Future<void> loadRewards() async {
    emit(const LoyaltyRewardsLoading());

    try {
      final rewards = await _api.getAvailableLoyaltyRewards();
      emit(LoyaltyRewardsSuccess(rewards));
    } catch (e) {
      emit(LoyaltyRewardsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
