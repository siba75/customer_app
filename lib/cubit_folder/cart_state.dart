import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:customer_app/model/discount_model.dart';

class CartState {
  final List<CartItem> items;
  final List<DiscountModel> activeDiscounts;
  final DiscountCalculationModel? discountCalculation;
  final int? selectedDiscountId;
  final bool isCalculatingDiscount;

  const CartState({
    this.items = const [],
    this.activeDiscounts = const [],
    this.discountCalculation,
    this.selectedDiscountId,
    this.isCalculatingDiscount = false,
  });

  const CartState.initial() : this();

  bool get hasItems => items.isNotEmpty;

  bool get hasManualDiscount => selectedDiscountId != null;

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.originalTotal);
  }

  double get invoiceDiscount {
    return discountCalculation?.discountAmount ?? 0;
  }

  double get discount => invoiceDiscount;

  String? get discountName {
    final invoiceDiscountName = discountCalculation?.discountName;
    if (invoiceDiscountName != null && invoiceDiscountName.isNotEmpty) {
      return invoiceDiscountName;
    }
    return null;
  }

  double get total =>
      (subtotal - discount).clamp(0, double.infinity).toDouble();

  int? get orderDiscountId {
    final invoiceDiscountId = discountCalculation?.discountId;
    if (invoiceDiscountId != null && invoiceDiscountId > 0) {
      return invoiceDiscountId;
    }
    return null;
  }

  CartState copyWith({
    List<CartItem>? items,
    List<DiscountModel>? activeDiscounts,
    DiscountCalculationModel? discountCalculation,
    int? selectedDiscountId,
    bool? isCalculatingDiscount,
    bool clearDiscountCalculation = false,
    bool clearSelectedDiscount = false,
  }) {
    return CartState(
      items: items ?? this.items,
      activeDiscounts: activeDiscounts ?? this.activeDiscounts,
      discountCalculation: clearDiscountCalculation
          ? null
          : discountCalculation ?? this.discountCalculation,
      selectedDiscountId: clearSelectedDiscount
          ? null
          : selectedDiscountId ?? this.selectedDiscountId,
      isCalculatingDiscount:
          isCalculatingDiscount ?? this.isCalculatingDiscount,
    );
  }
}
