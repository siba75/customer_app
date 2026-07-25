import 'package:customer_app/cubit_folder/ads_state.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
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
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل الإعلانات',
          ),
        ),
      );
    }
  }

  Future<void> loadHomeAds({bool activeOnly = true}) {
    return loadAds(activeOnly: activeOnly);
  }
}
