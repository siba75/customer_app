import 'package:customer_app/model/category_model.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:customer_app/model/product_model.dart';

class ProductState {
  final List<ProductModel> products;
  final List<DiscountModel> discounts;
  final CategoryModel? selectedCategory;
  final bool isLoading;
  final String? errorMessage;

  const ProductState({
    this.products = const [],
    this.discounts = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.errorMessage,
  });

  const ProductState.initial() : this();

  ProductState copyWith({
    List<ProductModel>? products,
    List<DiscountModel>? discounts,
    CategoryModel? selectedCategory,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearError = true,
  }) {
    return ProductState(
      products: products ?? this.products,
      discounts: discounts ?? this.discounts,
      selectedCategory: clearSelectedCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? errorMessage
          : errorMessage ?? this.errorMessage,
    );
  }
}
