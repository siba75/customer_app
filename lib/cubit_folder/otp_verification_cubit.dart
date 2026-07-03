import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/cubit_folder/otp_verification_state.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:customer_app/model/verify_otp_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  final AuthApi _api;

  OtpVerificationCubit(this._api) : super(OtpVerificationInitial());

  Future<void> verify({required VerifyOtpModel model, String? token}) async {
    try {
      emit(OtpVerificationLoading());

      final authToken = token ?? await SecureStorage.read('auth_token');
      if (authToken == null || authToken.isEmpty) {
        emit(
          OtpVerificationError('انتهت الجلسة، الرجاء إنشاء الحساب مرة أخرى'),
        );
        return;
      }

      final data = await _api.verifyOtp(model: model, token: authToken);

      emit(
        OtpVerificationSuccess(
          data['message']?.toString() ?? 'تم تأكيد الحساب بنجاح',
        ),
      );
    } catch (e) {
      emit(OtpVerificationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
