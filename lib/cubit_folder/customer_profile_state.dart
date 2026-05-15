import 'package:customer_app/model/customer_profile_model.dart';

class CustomerProfileState {
  final CustomerProfileModel? profile;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String? successMessage;

  const CustomerProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.successMessage,
  });

  const CustomerProfileState.initial() : this();

  CustomerProfileState copyWith({
    CustomerProfileModel? profile,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = true,
  }) {
    return CustomerProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearMessages
          ? errorMessage
          : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? successMessage
          : successMessage ?? this.successMessage,
    );
  }
}
