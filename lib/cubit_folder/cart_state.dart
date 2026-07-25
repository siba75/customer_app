import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:customer_app/model/discount_model.dart';

class CartState {
  final List<CartItem> items;
  final List<DiscountModel> activeDiscounts;
  final DiscountCalculationModel? discountCalculation;
  final bool isCalculatingDiscount;

  const CartState({
    this.items = const [],
    this.activeDiscounts = const [],
    this.discountCalculation,
    this.isCalculatingDiscount = false,
  });

  const CartState.initial() : this();

  bool get hasItems => items.isNotEmpty;

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.originalTotal);
  }

  double get delivery => subtotal >= 30 || subtotal == 0 ? 0 : 5;

  double get itemDiscount {
    return items.fold(0, (sum, item) => sum + item.lineDiscount);
  }

  double get invoiceDiscount {
    return discountCalculation?.discountAmount ?? 0;
  }

  double get discount => invoiceDiscount > 0 ? invoiceDiscount : itemDiscount;

  String? get discountName {
    final invoiceDiscountName = discountCalculation?.discountName;
    if (invoiceDiscountName != null && invoiceDiscountName.isNotEmpty) {
      return invoiceDiscountName;
    }

    final itemDiscountNames = items
        .where((item) => item.hasDiscount)
        .map((item) => item.discountName)
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toSet();

    if (itemDiscountNames.length == 1) return itemDiscountNames.first;
    if (itemDiscount > 0) return 'عروض المنتجات';
    return null;
  }

  double get total => subtotal + delivery - discount;

  int? get orderDiscountId {
    final invoiceDiscountId = discountCalculation?.discountId;
    if (invoiceDiscountId != null && invoiceDiscountId > 0) {
      return invoiceDiscountId;
    }

    final itemDiscountIds = items
        .where((item) => item.hasDiscount)
        .map((item) => item.discountId)
        .whereType<int>()
        .toSet();

    if (itemDiscountIds.length == 1) return itemDiscountIds.first;
    return null;
  }

  CartState copyWith({
    List<CartItem>? items,
    List<DiscountModel>? activeDiscounts,
    DiscountCalculationModel? discountCalculation,
    bool? isCalculatingDiscount,
    bool clearDiscountCalculation = false,
  }) {
    return CartState(
      items: items ?? this.items,
      activeDiscounts: activeDiscounts ?? this.activeDiscounts,
      discountCalculation: clearDiscountCalculation
          ? null
          : discountCalculation ?? this.discountCalculation,
      isCalculatingDiscount:
          isCalculatingDiscount ?? this.isCalculatingDiscount,
    );
  }
}
