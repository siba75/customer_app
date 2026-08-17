import 'package:customer_app/cubit_folder/login_state.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:customer_app/model/signin_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthApi _api;

  LoginCubit(this._api) : super(LoginInitial());

  Future<void> login(SigninModel model) async {
    try {
      emit(LoginLoading());

      final data = await _api.signin(model);
      final token = AuthApi.readToken(data);
      final refreshToken = AuthApi.readRefreshToken(data);

      if (token == null || token.isEmpty) {
        emit(LoginError('لم يتم استلام رمز الدخول من الخادم.'));
        return;
      }

      emit(
        LoginSuccess(
          message: data['message']?.toString() ?? 'تم تسجيل الدخول بنجاح',
          email: model.email,
          token: token,
          refreshToken: refreshToken,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        LoginError(
          AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تسجيل الدخول، حاول مرة أخرى.',
          ),
        ),
      );
    }
  }
}
