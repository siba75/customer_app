import 'package:customer_app/cubit_folder/category_state.dart';
import 'package:customer_app/dio/category_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryApi _categoryApi;

  CategoryCubit(this._categoryApi) : super(const CategoryState.initial());

  Future<void> loadCategories() async {
    try {
      emit(state.copyWith(isLoading: true));
      final categories = await _categoryApi.getCategories();
      emit(state.copyWith(categories: categories, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
