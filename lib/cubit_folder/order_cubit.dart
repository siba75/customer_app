import 'package:customer_app/cubit_folder/order_state.dart';
import 'package:customer_app/dio/order_api.dart';
import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/model/order_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderApi _api;

  OrderCubit(this._api) : super(const OrderState.initial());

  Future<void> loadOrders() async {
    try {
      emit(state.copyWith(isLoading: true));
      final orders = await _api.getOrders();
      emit(state.copyWith(orders: orders, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    int? discountId,
    int loyaltyPointsUsed = 0,
    String? deliveryAddress,
  }) async {
    emit(state.copyWith(isCreating: true));

    try {
      final order = await _api.createOrder(
        items: items,
        discountId: discountId,
        loyaltyPointsUsed: loyaltyPointsUsed,
        deliveryAddress: deliveryAddress,
      );
      emit(state.copyWith(orders: [order, ...state.orders], isCreating: false));
      return order;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(isCreating: false, errorMessage: message));
      throw Exception(message);
    }
  }

  Future<Order> cancelOrder(Order order) async {
    final orderId = int.tryParse(order.id);

    if (orderId == null) {
      const message = 'رقم الطلب غير صالح.';
      emit(state.copyWith(errorMessage: message));
      throw Exception(message);
    }

    emit(state.copyWith(cancellingOrderId: orderId));

    try {
      final cancelledOrder = await _api.cancelOrder(orderId);
      final updatedOrders = state.orders
          .map(
            (currentOrder) => currentOrder.id == cancelledOrder.id
                ? cancelledOrder
                : currentOrder,
          )
          .toList();

      emit(state.copyWith(orders: updatedOrders, clearCancellingOrder: true));
      return cancelledOrder;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(errorMessage: message, clearCancellingOrder: true));
      throw Exception(message);
    }
  }
}
