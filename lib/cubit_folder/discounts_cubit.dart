import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/cubit_folder/discounts_state.dart';
import 'package:customer_app/dio/category_api.dart';
import 'package:customer_app/dio/discount_api.dart';
import 'package:customer_app/dio/product_api.dart';
import 'package:customer_app/model/category_model.dart';
import 'package:customer_app/model/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscountsCubit extends Cubit<DiscountsState> {
  final DiscountApi _discountApi;
  final ProductApi _productApi;
  final CategoryApi _categoryApi;

  DiscountsCubit(
    this._discountApi, {
    ProductApi? productApi,
    CategoryApi? categoryApi,
  }) : _productApi = productApi ?? ProductApi(),
       _categoryApi = categoryApi ?? CategoryApi(),
       super(const DiscountsState.initial());

  Future<void> loadDiscounts() async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearCalculationError: true,
      ),
    );

    try {
      final discounts = await _discountApi.getActiveDiscounts();
      final products = await _loadProductsSafely();
      final categories = await _loadCategoriesSafely();

      emit(
        state.copyWith(
          discounts: discounts,
          products: products,
          categories: categories,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل الخصومات حالياً.',
          ),
        ),
      );
    }
  }

  void setScopeFilter(DiscountScopeFilter filter) {
    emit(state.copyWith(scopeFilter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(query: query));
  }

  Future<void> calculateBestDiscount({
    required double subtotal,
    DiscountCalculatorTarget target = DiscountCalculatorTarget.order,
    int? productId,
    int? categoryId,
  }) async {
    if (subtotal <= 0) {
      emit(
        state.copyWith(
          calculationError: 'أدخلي قيمة طلب صحيحة حتى نحسب الخصم.',
          isCalculating: false,
          clearCalculation: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isCalculating: true,
        clearCalculation: true,
        clearCalculationError: true,
      ),
    );

    try {
      final calculation = await _discountApi.getBestDiscount(
        subtotal: subtotal,
        productId: target == DiscountCalculatorTarget.product
            ? productId
            : null,
        categoryId: target == DiscountCalculatorTarget.category
            ? categoryId
            : null,
      );

      if (calculation == null || calculation.discountAmount <= 0) {
        emit(
          state.copyWith(
            isCalculating: false,
            calculationError: 'لا يوجد خصم مناسب لهذه القيمة حالياً.',
            clearCalculation: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isCalculating: false,
          calculation: calculation,
          clearCalculationError: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isCalculating: false,
          calculationError: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر حساب الخصم حالياً.',
          ),
          clearCalculation: true,
        ),
      );
    }
  }

  Future<List<ProductModel>> _loadProductsSafely() async {
    try {
      return await _productApi.getProducts();
    } catch (_) {
      return const [];
    }
  }

  Future<List<CategoryModel>> _loadCategoriesSafely() async {
    try {
      return await _categoryApi.getCategories();
    } catch (_) {
      return const [];
    }
  }
}
