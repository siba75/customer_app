import 'package:customer_app/cubit_folder/customer_profile_state.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
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
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل بيانات الحساب',
          ),
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
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحديث بيانات الحساب',
          ),
        ),
      );
    }
  }
}
