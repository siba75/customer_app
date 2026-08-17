abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String message;
  final String email;
  final String token;
  final String? refreshToken;

  LoginSuccess({
    required this.message,
    required this.email,
    required this.token,
    this.refreshToken,
  });
}

class LoginError extends LoginState {
  final String message;

  LoginError(this.message);
}
