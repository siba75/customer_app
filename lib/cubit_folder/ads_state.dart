import 'package:customer_app/model/ad_model.dart';

class AdsState {
  final List<AdModel> ads;
  final bool isLoading;
  final String? errorMessage;

  const AdsState({
    this.ads = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  const AdsState.initial() : this();

  AdsState copyWith({
    List<AdModel>? ads,
    bool? isLoading,
    String? errorMessage,
    bool clearError = true,
  }) {
    return AdsState(
      ads: ads ?? this.ads,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? errorMessage
          : errorMessage ?? this.errorMessage,
    );
  }
}
