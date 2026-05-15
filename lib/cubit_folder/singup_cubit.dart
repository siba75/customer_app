import 'package:bloc/bloc.dart';
import 'package:customer_app/cubit_folder/singup_state.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:customer_app/model/signup_model.dart';

// part 'register_state.dart';
class RegisterCubit extends Cubit<RegisterState> {
  final AuthApi _api;

  RegisterCubit(this._api) : super(RegisterInitial());

  Future<void> register(SignupModel model) async {
    try {
      emit(RegisterLoading());
      final data = await _api.signup(model);
      final token = AuthApi.readToken(data);

      emit(
        RegisterSuccess(
          message: data['message']?.toString() ?? 'تم إنشاء الحساب بنجاح',
          email: model.email,
          token: token?.toString(),
        ),
      );
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }
}
