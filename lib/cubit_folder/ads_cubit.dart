import 'package:customer_app/cubit_folder/ads_state.dart';
import 'package:customer_app/dio/ads_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdsCubit extends Cubit<AdsState> {
  final AdsApi _adsApi;

  AdsCubit(this._adsApi) : super(const AdsState.initial());

  Future<void> loadAds({bool activeOnly = true}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final ads = await _adsApi.getAds(activeOnly: activeOnly);
      emit(state.copyWith(ads: ads, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> loadHomeAds({bool activeOnly = true}) {
    return loadAds(activeOnly: activeOnly);
  }
}
