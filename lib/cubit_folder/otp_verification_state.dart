abstract class OtpVerificationState {}

class OtpVerificationInitial extends OtpVerificationState {}

class OtpVerificationLoading extends OtpVerificationState {}

class OtpVerificationSuccess extends OtpVerificationState {
  final String message;

  OtpVerificationSuccess(this.message);
}

class OtpVerificationError extends OtpVerificationState {
  final String message;

  OtpVerificationError(this.message);
}
