import 'package:customer_app/model/category_model.dart';

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  const CategoryState.initial() : this();

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
    bool clearError = true,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? errorMessage
          : errorMessage ?? this.errorMessage,
    );
  }
}
