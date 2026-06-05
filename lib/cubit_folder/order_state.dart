import 'package:customer_app/model/order_model.dart';

class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final bool isCreating;
  final int? cancellingOrderId;
  final String? errorMessage;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.cancellingOrderId,
    this.errorMessage,
  });

  const OrderState.initial() : this();

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isCreating,
    int? cancellingOrderId,
    String? errorMessage,
    bool clearCancellingOrder = false,
    bool clearError = true,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      cancellingOrderId: clearCancellingOrder
          ? null
          : cancellingOrderId ?? this.cancellingOrderId,
      errorMessage: clearError
          ? errorMessage
          : errorMessage ?? this.errorMessage,
    );
  }
}
