import 'package:customer_app/cubit_folder/cart_state.dart';
import 'package:customer_app/dio/discount_api.dart';
import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:customer_app/model/discount_model.dart';
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

    emit(
      state.copyWith(
        items: updatedItems,
        clearDiscountCalculation: true,
        clearSelectedDiscount: true,
      ),
    );
    return calculateBestDiscount();
  }

  Future<void> increaseQuantity(CartItem item) {
    final items = state.items.map((cartItem) {
      if (cartItem.id != item.id) return cartItem;
      return cartItem.copyWith(
        quantity: _clampQuantity(cartItem.quantity + 1, cartItem.maxQuantity),
      );
    }).toList();

    emit(
      state.copyWith(
        items: items,
        clearDiscountCalculation: true,
        clearSelectedDiscount: true,
      ),
    );
    return calculateBestDiscount();
  }

  Future<void> decreaseQuantity(CartItem item) {
    if (item.quantity <= 1) return Future.value();

    final items = state.items.map((cartItem) {
      if (cartItem.id != item.id) return cartItem;
      return cartItem.copyWith(quantity: cartItem.quantity - 1);
    }).toList();

    emit(
      state.copyWith(
        items: items,
        clearDiscountCalculation: true,
        clearSelectedDiscount: true,
      ),
    );
    return calculateBestDiscount();
  }

  Future<void> removeItem(CartItem item) {
    final items = state.items
        .where((cartItem) => cartItem.id != item.id)
        .toList();

    emit(
      state.copyWith(
        items: items,
        clearDiscountCalculation: true,
        clearSelectedDiscount: true,
      ),
    );
    return calculateBestDiscount();
  }

  Future<void> clearCart() {
    emit(
      state.copyWith(
        items: const [],
        isCalculatingDiscount: false,
        clearDiscountCalculation: true,
        clearSelectedDiscount: true,
      ),
    );
    return Future.value();
  }

  Future<void> applyDiscount(DiscountModel discount) async {
    ++_discountRequestId;
    final subtotal = _subtotalForDiscount(discount);

    if (state.items.isEmpty || subtotal <= 0) {
      throw Exception('هذا الخصم لا ينطبق على المنتجات الموجودة في السلة.');
    }

    emit(state.copyWith(isCalculatingDiscount: true));

    try {
      final calculation = await _discountApi.calculateDiscount(
        discountId: discount.id,
        subtotal: subtotal,
        customerId: discount.customerId,
        productId: discount.productId,
        categoryId: discount.categoryId,
      );

      if (calculation.discountAmount <= 0) {
        throw Exception('هذا الخصم لا يعطي تخفيضاً على السلة الحالية.');
      }

      emit(
        state.copyWith(
          discountCalculation: calculation,
          selectedDiscountId: discount.id,
          isCalculatingDiscount: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isCalculatingDiscount: false));
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> useBestDiscount() async {
    emit(
      state.copyWith(
        clearDiscountCalculation: true,
        clearSelectedDiscount: true,
      ),
    );
    await calculateBestDiscount();
  }

  Future<void> calculateBestDiscount() async {
    final subtotal = state.subtotal;
    final requestId = ++_discountRequestId;

    if (state.selectedDiscountId != null) return;

    if (subtotal <= 0) {
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
    try {
      bestCalculation = await _calculateBestDiscountFromBackend();
      bestCalculation ??= await _calculateBestDiscountLocally();
    } catch (_) {
      bestCalculation = await _calculateBestDiscountLocally();
    }

    if (requestId != _discountRequestId) return;

    final shouldUseInvoiceDiscount =
        bestCalculation != null && bestCalculation.discountAmount > 0;

    emit(
      state.copyWith(
        discountCalculation: shouldUseInvoiceDiscount ? bestCalculation : null,
        isCalculatingDiscount: false,
        clearDiscountCalculation: !shouldUseInvoiceDiscount,
      ),
    );
  }

  Future<DiscountCalculationModel?> _calculateBestDiscountFromBackend() async {
    final calculations = <DiscountCalculationModel>[];

    await _tryAddCalculation(
      calculations,
      () => _discountApi.getBestDiscount(subtotal: state.subtotal),
    );

    for (final entry in _subtotalByProduct().entries) {
      await _tryAddCalculation(
        calculations,
        () => _discountApi.getBestDiscount(
          subtotal: entry.value,
          productId: entry.key,
        ),
      );
    }

    for (final entry in _subtotalByCategory().entries) {
      await _tryAddCalculation(
        calculations,
        () => _discountApi.getBestDiscount(
          subtotal: entry.value,
          categoryId: entry.key,
        ),
      );
    }

    return _bestCalculation(calculations);
  }

  Future<void> _tryAddCalculation(
    List<DiscountCalculationModel> calculations,
    Future<DiscountCalculationModel?> Function() request,
  ) async {
    try {
      final calculation = await request();
      if (calculation != null && calculation.discountAmount > 0) {
        final alreadyAdded = calculations.any(
          (item) =>
              item.discountId == calculation.discountId &&
              item.subtotal == calculation.subtotal,
        );
        if (!alreadyAdded) calculations.add(calculation);
      }
    } catch (_) {
      // Some scope checks can fail for a product/category; other discounts may still be valid.
    }
  }

  Future<DiscountCalculationModel?> _calculateBestDiscountLocally() async {
    final calculations = <DiscountCalculationModel>[];
    for (final discount in state.activeDiscounts) {
      try {
        final scopedSubtotal = _subtotalForDiscount(discount);
        if (scopedSubtotal <= 0) continue;

        final calculation = await _discountApi.calculateDiscount(
          discountId: discount.id,
          subtotal: scopedSubtotal,
          customerId: discount.customerId,
          productId: discount.productId,
          categoryId: discount.categoryId,
        );

        if (calculation.discountAmount > 0) calculations.add(calculation);
      } catch (_) {
        continue;
      }
    }

    return _bestCalculation(calculations);
  }

  DiscountCalculationModel? _bestCalculation(
    List<DiscountCalculationModel> calculations,
  ) {
    DiscountCalculationModel? bestCalculation;

    for (final calculation in calculations) {
      if (bestCalculation == null ||
          calculation.discountAmount > bestCalculation.discountAmount) {
        bestCalculation = calculation;
      }
    }

    return bestCalculation;
  }

  Map<int, double> _subtotalByProduct() {
    final result = <int, double>{};

    for (final item in state.items) {
      final productId = item.productId;
      if (productId == null) continue;
      result[productId] = (result[productId] ?? 0) + item.originalTotal;
    }

    return result;
  }

  Map<int, double> _subtotalByCategory() {
    final result = <int, double>{};

    for (final item in state.items) {
      final categoryId = item.categoryId;
      if (categoryId == null) continue;
      result[categoryId] = (result[categoryId] ?? 0) + item.originalTotal;
    }

    return result;
  }

  double _subtotalForDiscount(DiscountModel discount) {
    if (discount.isProductScope && discount.productId != null) {
      return _subtotalByProduct()[discount.productId] ?? 0;
    }

    if (discount.isCategoryScope && discount.categoryId != null) {
      return _subtotalByCategory()[discount.categoryId] ?? 0;
    }

    return state.subtotal;
  }

  int _clampQuantity(int quantity, int? maxQuantity) {
    if (maxQuantity == null || maxQuantity <= 0) {
      return quantity < 1 ? 1 : quantity;
    }

    return quantity.clamp(1, maxQuantity).toInt();
  }
}
