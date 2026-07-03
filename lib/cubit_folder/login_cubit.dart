import 'package:customer_app/cubit_folder/login_state.dart';
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

      if (token == null || token.isEmpty) {
        emit(LoginError('لم يتم استلام رمز الدخول من الخادم.'));
        return;
      }

      emit(
        LoginSuccess(
          message: data['message']?.toString() ?? 'تم تسجيل الدخول بنجاح',
          email: model.email,
          token: token,
        ),
      );
    } catch (e) {
      emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
