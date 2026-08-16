import 'package:customer_app/model/category_model.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:customer_app/model/product_model.dart';

enum DiscountScopeFilter { all, global, product, category, customer }

enum DiscountCalculatorTarget { order, product, category }

class DiscountsState {
  final List<DiscountModel> discounts;
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final DiscountScopeFilter scopeFilter;
  final String query;
  final bool isLoading;
  final String? errorMessage;
  final bool isCalculating;
  final DiscountCalculationModel? calculation;
  final String? calculationError;

  const DiscountsState({
    this.discounts = const [],
    this.products = const [],
    this.categories = const [],
    this.scopeFilter = DiscountScopeFilter.all,
    this.query = '',
    this.isLoading = false,
    this.errorMessage,
    this.isCalculating = false,
    this.calculation,
    this.calculationError,
  });

  const DiscountsState.initial() : this();

  List<DiscountModel> get visibleDiscounts {
    final normalizedQuery = query.trim().toLowerCase();

    return discounts.where((discount) {
      final matchesScope =
          scopeFilter == DiscountScopeFilter.all ||
          discount.scope.toUpperCase() == scopeFilter.name.toUpperCase();

      final matchesQuery =
          normalizedQuery.isEmpty ||
          discount.name.toLowerCase().contains(normalizedQuery) ||
          discount.scope.toLowerCase().contains(normalizedQuery) ||
          targetNameFor(discount).toLowerCase().contains(normalizedQuery);

      return matchesScope && matchesQuery;
    }).toList();
  }

  int get productDiscountsCount =>
      discounts.where((discount) => discount.isProductScope).length;

  int get categoryDiscountsCount =>
      discounts.where((discount) => discount.isCategoryScope).length;

  int get customerDiscountsCount =>
      discounts.where((discount) => discount.isCustomerScope).length;

  String targetNameFor(DiscountModel discount) {
    if (discount.isProductScope && discount.productId != null) {
      for (final product in products) {
        if (product.id == discount.productId) return product.name;
      }
      return 'منتج محدد';
    }

    if (discount.isCategoryScope && discount.categoryId != null) {
      for (final category in categories) {
        if (category.id == discount.categoryId) return category.name;
      }
      return 'فئة محددة';
    }

    if (discount.isCustomerScope) return 'خصم خاص بحسابك';
    if (discount.isGlobalScope) return 'كل الطلب';
    return 'خصم متاح';
  }

  DiscountsState copyWith({
    List<DiscountModel>? discounts,
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    DiscountScopeFilter? scopeFilter,
    String? query,
    bool? isLoading,
    String? errorMessage,
    bool? isCalculating,
    DiscountCalculationModel? calculation,
    String? calculationError,
    bool clearError = false,
    bool clearCalculation = false,
    bool clearCalculationError = false,
  }) {
    return DiscountsState(
      discounts: discounts ?? this.discounts,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      scopeFilter: scopeFilter ?? this.scopeFilter,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isCalculating: isCalculating ?? this.isCalculating,
      calculation: clearCalculation ? null : calculation ?? this.calculation,
      calculationError: clearCalculationError
          ? null
          : calculationError ?? this.calculationError,
    );
  }
}
