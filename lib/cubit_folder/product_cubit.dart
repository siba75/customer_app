import 'package:customer_app/cubit_folder/product_state.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/dio/category_api.dart';
import 'package:customer_app/dio/discount_api.dart';
import 'package:customer_app/dio/product_api.dart';
import 'package:customer_app/dio/product_photo_api.dart';
import 'package:customer_app/model/category_model.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:customer_app/model/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductApi _productApi;
  final DiscountApi _discountApi;
  final CategoryApi _categoryApi;
  final ProductPhotoApi _productPhotoApi;

  ProductCubit(
    this._productApi,
    this._discountApi, [
    CategoryApi? categoryApi,
    ProductPhotoApi? productPhotoApi,
  ]) : _categoryApi = categoryApi ?? CategoryApi(),
       _productPhotoApi = productPhotoApi ?? ProductPhotoApi(),
       super(const ProductState.initial());

  Future<void> loadProducts() async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          products: const [],
          clearSelectedCategory: true,
        ),
      );

      final products = await _attachProductPhotos(
        await _productApi.getProducts(),
      );
      final discounts = await _loadDiscountsSafely();
      emit(
        state.copyWith(
          products: products,
          discounts: discounts,
          isLoading: false,
          clearSelectedCategory: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل المنتجات',
          ),
        ),
      );
    }
  }

  Future<void> loadProductsByCategory(CategoryModel category) async {
    try {
      emit(
        state.copyWith(
          selectedCategory: category,
          isLoading: true,
          products: const [],
        ),
      );

      final detailedCategory = await _categoryApi.getCategory(category.id);
      final products = await _attachProductPhotos(detailedCategory.products);
      final discounts = await _loadDiscountsSafely();
      emit(
        state.copyWith(
          selectedCategory: detailedCategory,
          products: products,
          discounts: discounts,
          isLoading: false,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessages.friendly(
            message,
            fallback: 'تعذر تحميل منتجات التصنيف',
          ),
        ),
      );
    }
  }

  Future<void> refreshProducts() async {
    final category = state.selectedCategory;

    if (category == null) {
      await loadProducts();
      return;
    }

    await loadProductsByCategory(category);
  }

  Future<List<DiscountModel>> _loadDiscountsSafely() async {
    try {
      return await _discountApi.getActiveDiscounts();
    } catch (_) {
      return state.discounts;
    }
  }

  Future<List<ProductModel>> _attachProductPhotos(
    List<ProductModel> products,
  ) async {
    return Future.wait(
      products.map((product) async {
        if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
          return product;
        }

        try {
          final photoUrl = await _productPhotoApi.getPrimaryPhotoUrl(
            product.id,
          );
          return photoUrl == null
              ? product
              : product.copyWith(imageUrl: photoUrl);
        } catch (_) {
          return product;
        }
      }),
    );
  }
}
