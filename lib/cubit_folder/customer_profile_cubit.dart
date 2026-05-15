import 'package:customer_app/cubit_folder/customer_profile_state.dart';
import 'package:customer_app/dio/customer_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerProfileCubit extends Cubit<CustomerProfileState> {
  final CustomerApi _api;

  CustomerProfileCubit(this._api) : super(const CustomerProfileState.initial());

  Future<void> loadProfile() async {
    try {
      emit(state.copyWith(isLoading: true));
      final profile = await _api.getProfile();
      emit(state.copyWith(profile: profile, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      emit(state.copyWith(isUpdating: true));
      final profile = await _api.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
      );
      emit(
        state.copyWith(
          profile: profile,
          isUpdating: false,
          successMessage: 'تم تحديث بيانات الحساب بنجاح',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
