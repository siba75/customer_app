// part of 'register_cubit.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String message;
  final String email;
  final String? token;
  final String? refreshToken;

  RegisterSuccess({
    required this.message,
    required this.email,
    this.token,
    this.refreshToken,
  });
}

class RegisterError extends RegisterState {
  final String message;
  RegisterError(this.message);
}
