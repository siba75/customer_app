import 'package:customer_app/cubit_folder/cart_state.dart';
import 'package:customer_app/dio/discount_api.dart';
import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  final DiscountApi _discountApi;
  int _discountRequestId = 0;

  CartCubit(this._discountApi) : super(const CartState.initial()) {
    loadDiscounts();
  }

  Future<void> loadDiscounts() async {
    try {
      final discounts = await _discountApi.getActiveDiscounts();
      emit(state.copyWith(activeDiscounts: discounts));
      await calculateBestDiscount();
    } catch (_) {
      emit(
        state.copyWith(
          activeDiscounts: const [],
          isCalculatingDiscount: false,
          clearDiscountCalculation: true,
        ),
      );
    }
  }

  Future<void> addProduct(Map<String, dynamic> product, {int quantity = 1}) {
    final item = CartItem.fromProductMap(product, quantity: quantity);
    if (item.id.isEmpty || item.price <= 0) return Future.value();
    if (item.maxQuantity != null && item.maxQuantity! <= 0) {
      return Future.value();
    }

    final updatedItems = [...state.items];
    final index = updatedItems.indexWhere((cartItem) => cartItem.id == item.id);

    if (index == -1) {
      updatedItems.add(
        item.copyWith(quantity: _clampQuantity(quantity, item.maxQuantity)),
      );
    } else {
      final currentItem = updatedItems[index];
      final maxQuantity = currentItem.maxQuantity ?? item.maxQuantity;
      updatedItems[index] = currentItem.copyWith(
        quantity: _clampQuantity(currentItem.quantity + quantity, maxQuantity),
      );
    }

    emit(state.copyWith(items: updatedItems, clearDiscountCalculation: true));
    return calculateBestDiscount();
  }

  Future<void> increaseQuantity(CartItem item) {
    final items = state.items.map((cartItem) {
      if (cartItem.id != item.id) return cartItem;
      return cartItem.copyWith(
        quantity: _clampQuantity(cartItem.quantity + 1, cartItem.maxQuantity),
      );
    }).toList();

    emit(state.copyWith(items: items, clearDiscountCalculation: true));
    return calculateBestDiscount();
  }

  Future<void> decreaseQuantity(CartItem item) {
    if (item.quantity <= 1) return Future.value();

    final items = state.items.map((cartItem) {
      if (cartItem.id != item.id) return cartItem;
      return cartItem.copyWith(quantity: cartItem.quantity - 1);
    }).toList();

    emit(state.copyWith(items: items, clearDiscountCalculation: true));
    return calculateBestDiscount();
  }

  Future<void> removeItem(CartItem item) {
    final items = state.items
        .where((cartItem) => cartItem.id != item.id)
        .toList();

    emit(state.copyWith(items: items, clearDiscountCalculation: true));
    return calculateBestDiscount();
  }

  Future<void> clearCart() {
    emit(
      state.copyWith(
        items: const [],
        isCalculatingDiscount: false,
        clearDiscountCalculation: true,
      ),
    );
    return Future.value();
  }

  Future<void> calculateBestDiscount() async {
    final subtotal = state.subtotal;
    final requestId = ++_discountRequestId;

    if (state.itemDiscount > 0) {
      emit(
        state.copyWith(
          isCalculatingDiscount: false,
          clearDiscountCalculation: true,
        ),
      );
      return;
    }

    final discounts = state.activeDiscounts
        .where((discount) => discount.isGlobalScope)
        .toList();

    if (subtotal <= 0 || discounts.isEmpty) {
      emit(
        state.copyWith(
          isCalculatingDiscount: false,
          clearDiscountCalculation: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isCalculatingDiscount: true));

    DiscountCalculationModel? bestCalculation;
    for (final discount in discounts) {
      try {
        final calculation = await _discountApi.calculateDiscount(
          discountId: discount.id,
          subtotal: subtotal,
        );

        if (bestCalculation == null ||
            calculation.discountAmount > bestCalculation.discountAmount) {
          bestCalculation = calculation;
        }
      } catch (_) {
        continue;
      }
    }

    if (requestId != _discountRequestId) return;
    emit(
      state.copyWith(
        discountCalculation: bestCalculation,
        isCalculatingDiscount: false,
      ),
    );
  }

  int _clampQuantity(int quantity, int? maxQuantity) {
    if (maxQuantity == null || maxQuantity <= 0) {
      return quantity < 1 ? 1 : quantity;
    }

    return quantity.clamp(1, maxQuantity).toInt();
  }
}
