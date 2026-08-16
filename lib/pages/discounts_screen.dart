import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/cubit_folder/discounts_cubit.dart';
import 'package:customer_app/cubit_folder/discounts_state.dart';
import 'package:customer_app/dio/discount_api.dart';
import 'package:customer_app/model/category_model.dart';
import 'package:customer_app/model/discount_calculation_model.dart';
import 'package:customer_app/model/discount_model.dart';
import 'package:customer_app/model/product_model.dart';
import 'package:customer_app/widgets/discount_widgets/discount_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscountsScreen extends StatelessWidget {
  final DiscountsCubit? cubit;
  final CartCubit? cartCubit;

  const DiscountsScreen({super.key, this.cubit, this.cartCubit});

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (cubit != null) {
      child = BlocProvider.value(value: cubit!, child: const _DiscountsView());
    } else {
      child = BlocProvider(
        create: (_) => DiscountsCubit(DiscountApi())..loadDiscounts(),
        child: const _DiscountsView(),
      );
    }

    if (cartCubit == null) return child;

    return BlocProvider.value(value: cartCubit!, child: child);
  }
}

class _DiscountsView extends StatefulWidget {
  const _DiscountsView();

  @override
  State<_DiscountsView> createState() => _DiscountsViewState();
}

class _DiscountsViewState extends State<_DiscountsView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subtotalController = TextEditingController(
    text: '120',
  );
  DiscountCalculatorTarget _target = DiscountCalculatorTarget.order;
  int? _selectedProductId;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _subtotalController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<DiscountsCubit>().setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('الخصومات'),
          style: AppTypography.titleLarge.copyWith(
            color: context.appText,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<DiscountsCubit>().loadDiscounts(),
            icon: const Icon(Icons.refresh_rounded),
            color: context.appText,
            tooltip: context.tr('تحديث'),
          ),
        ],
      ),
      body: BlocBuilder<DiscountsCubit, DiscountsState>(
        builder: (context, state) {
          final hasCartProvider = _hasCartProvider(context);

          if (state.isLoading && state.discounts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.errorMessage != null && state.discounts.isEmpty) {
            return _DiscountsError(
              message: state.errorMessage!,
              onRetry: context.read<DiscountsCubit>().loadDiscounts,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: context.read<DiscountsCubit>().loadDiscounts,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _Header(state: state)),
                SliverToBoxAdapter(
                  child: _CalculatorCard(
                    state: state,
                    subtotalController: _subtotalController,
                    target: _target,
                    selectedProductId: _selectedProductId,
                    selectedCategoryId: _selectedCategoryId,
                    onTargetChanged: (target) {
                      setState(() => _target = target);
                    },
                    onProductChanged: (id) {
                      setState(() => _selectedProductId = id);
                    },
                    onCategoryChanged: (id) {
                      setState(() => _selectedCategoryId = id);
                    },
                    onCalculate: _calculateBestDiscount,
                    onApplyCalculation: hasCartProvider
                        ? (calculation) {
                            _applyCalculatedDiscountToCart(
                              context,
                              state,
                              calculation,
                            );
                          }
                        : null,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SearchAndFilters(
                    controller: _searchController,
                    state: state,
                    onFilterChanged: context
                        .read<DiscountsCubit>()
                        .setScopeFilter,
                  ),
                ),
                if (state.visibleDiscounts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyDiscounts(query: state.query),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: state.visibleDiscounts.length,
                      itemBuilder: (context, index) {
                        final discount = state.visibleDiscounts[index];
                        return DiscountCard(
                          discount: discount,
                          targetName: state.targetNameFor(discount),
                          onApply: hasCartProvider
                              ? () => _applyDiscountToCart(context, discount)
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _calculateBestDiscount() {
    final subtotal = double.tryParse(_subtotalController.text.trim()) ?? 0;

    if (_target == DiscountCalculatorTarget.product &&
        _selectedProductId == null) {
      _showMessage(context.tr('اختاري المنتج أولاً.'));
      return;
    }

    if (_target == DiscountCalculatorTarget.category &&
        _selectedCategoryId == null) {
      _showMessage(context.tr('اختاري الفئة أولاً.'));
      return;
    }

    context.read<DiscountsCubit>().calculateBestDiscount(
      subtotal: subtotal,
      target: _target,
      productId: _selectedProductId,
      categoryId: _selectedCategoryId,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  bool _hasCartProvider(BuildContext context) {
    try {
      context.read<CartCubit>();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _applyCalculatedDiscountToCart(
    BuildContext context,
    DiscountsState state,
    DiscountCalculationModel calculation,
  ) async {
    DiscountModel? discount;
    for (final item in state.discounts) {
      if (item.id == calculation.discountId) {
        discount = item;
        break;
      }
    }

    if (discount == null) {
      _showMessage(context.tr('تعذر العثور على الخصم لتطبيقه على السلة.'));
      return;
    }

    await _applyDiscountToCart(context, discount);
  }

  Future<void> _applyDiscountToCart(
    BuildContext context,
    DiscountModel discount,
  ) async {
    try {
      final cartCubit = context.read<CartCubit>();
      await cartCubit.applyDiscount(discount);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('تم تطبيق الخصم على السلة')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _Header extends StatelessWidget {
  final DiscountsState state;

  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: context.appCardShadow(
            alpha: 0.17,
            blur: 32,
            offset: const Offset(0, 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('مركز الخصومات'),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('اعرفي الخصم المناسب قبل إتمام الطلب.'),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.82),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeaderStat(
                  label: context.tr('المتاحة'),
                  value: '${state.discounts.length}',
                ),
                const SizedBox(width: 10),
                _HeaderStat(
                  label: context.tr('للمنتجات'),
                  value: '${state.productDiscountsCount}',
                ),
                const SizedBox(width: 10),
                _HeaderStat(
                  label: context.tr('لحسابك'),
                  value: '${state.customerDiscountsCount}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  final DiscountsState state;
  final TextEditingController subtotalController;
  final DiscountCalculatorTarget target;
  final int? selectedProductId;
  final int? selectedCategoryId;
  final ValueChanged<DiscountCalculatorTarget> onTargetChanged;
  final ValueChanged<int?> onProductChanged;
  final ValueChanged<int?> onCategoryChanged;
  final VoidCallback onCalculate;
  final ValueChanged<DiscountCalculationModel>? onApplyCalculation;

  const _CalculatorCard({
    required this.state,
    required this.subtotalController,
    required this.target,
    required this.selectedProductId,
    required this.selectedCategoryId,
    required this.onTargetChanged,
    required this.onProductChanged,
    required this.onCategoryChanged,
    required this.onCalculate,
    this.onApplyCalculation,
  });

  @override
  Widget build(BuildContext context) {
    final calculation = state.calculation;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.09,
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('حاسبة أفضل خصم'),
                      style: AppTypography.titleMedium.copyWith(
                        color: context.appText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      context.tr('النظام يحسب نفس نتيجة الباك قبل الطلب.'),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.appMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: subtotalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.tr('قيمة الطلب'),
              prefixIcon: const Icon(Icons.payments_outlined),
              filled: true,
              fillColor: context.appBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.appSoftBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.appSoftBorder),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TargetChip(
                label: context.tr('كل الطلب'),
                icon: Icons.storefront_outlined,
                selected: target == DiscountCalculatorTarget.order,
                onTap: () => onTargetChanged(DiscountCalculatorTarget.order),
              ),
              _TargetChip(
                label: context.tr('منتج'),
                icon: Icons.inventory_2_outlined,
                selected: target == DiscountCalculatorTarget.product,
                onTap: () => onTargetChanged(DiscountCalculatorTarget.product),
              ),
              _TargetChip(
                label: context.tr('فئة'),
                icon: Icons.category_outlined,
                selected: target == DiscountCalculatorTarget.category,
                onTap: () => onTargetChanged(DiscountCalculatorTarget.category),
              ),
            ],
          ),
          if (target == DiscountCalculatorTarget.product) ...[
            const SizedBox(height: 12),
            _ProductDropdown(
              products: state.products,
              value: selectedProductId,
              onChanged: onProductChanged,
            ),
          ],
          if (target == DiscountCalculatorTarget.category) ...[
            const SizedBox(height: 12),
            _CategoryDropdown(
              categories: state.categories,
              value: selectedCategoryId,
              onChanged: onCategoryChanged,
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: state.isCalculating ? null : onCalculate,
              icon: state.isCalculating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(context.tr('احسبي أفضل خصم')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (calculation != null) ...[
            const SizedBox(height: 14),
            _CalculationResult(
              calculation: calculation,
              onApply: onApplyCalculation == null
                  ? null
                  : () => onApplyCalculation!(calculation),
            ),
          ],
          if (state.calculationError != null) ...[
            const SizedBox(height: 12),
            _InlineMessage(
              icon: Icons.info_outline,
              text: state.calculationError!,
              color: AppColors.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  final List<ProductModel> products;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _ProductDropdown({
    required this.products,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: products.any((product) => product.id == value) ? value : null,
      items: products
          .map(
            (product) => DropdownMenuItem<int>(
              value: product.id,
              child: Text(product.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: products.isEmpty ? null : onChanged,
      decoration: _dropdownDecoration(
        context,
        products.isEmpty
            ? context.tr('لا توجد منتجات متاحة حالياً')
            : context.tr('اختاري المنتج'),
        Icons.inventory_2_outlined,
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? value;
  final ValueChanged<int?> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: categories.any((category) => category.id == value) ? value : null,
      items: categories
          .map(
            (category) => DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: categories.isEmpty ? null : onChanged,
      decoration: _dropdownDecoration(
        context,
        categories.isEmpty
            ? context.tr('لا توجد فئات متاحة حالياً')
            : context.tr('اختاري الفئة'),
        Icons.category_outlined,
      ),
    );
  }
}

InputDecoration _dropdownDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: context.appBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: context.appSoftBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: context.appSoftBorder),
    ),
  );
}

class _TargetChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TargetChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        icon,
        size: 17,
        color: selected ? AppColors.white : AppColors.primary,
      ),
      label: Text(label),
      selectedColor: AppColors.primary,
      backgroundColor: context.appSurface,
      side: BorderSide(
        color: selected ? AppColors.primary : context.appSoftBorder,
      ),
      labelStyle: AppTypography.bodySmall.copyWith(
        color: selected ? AppColors.white : context.appText,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CalculationResult extends StatelessWidget {
  final DiscountCalculationModel calculation;
  final VoidCallback? onApply;

  const _CalculationResult({required this.calculation, this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  calculation.discountName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ResultMetric(
                  label: context.tr('قبل الخصم'),
                  value: context.money(calculation.subtotal),
                ),
              ),
              Expanded(
                child: _ResultMetric(
                  label: context.tr('قيمة الخصم'),
                  value: '-${context.money(calculation.discountAmount)}',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _ResultMetric(
                  label: context.tr('بعد الخصم'),
                  value: context.money(calculation.total),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (onApply != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: Text(context.tr('تطبيق على السلة')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _ResultMetric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(color: context.appMutedText),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleSmall.copyWith(
            color: color ?? context.appText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final DiscountsState state;
  final ValueChanged<DiscountScopeFilter> onFilterChanged;

  const _SearchAndFilters({
    required this.controller,
    required this.state,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: context.tr('ابحثي باسم الخصم أو المنتج أو الفئة'),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: controller.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: context.appSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: context.appSoftBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: context.appSoftBorder),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: context.tr('الكل'),
                  icon: Icons.grid_view_rounded,
                  selected: state.scopeFilter == DiscountScopeFilter.all,
                  onTap: () => onFilterChanged(DiscountScopeFilter.all),
                ),
                _FilterChip(
                  label: context.tr('عامة'),
                  icon: Icons.storefront_outlined,
                  selected: state.scopeFilter == DiscountScopeFilter.global,
                  onTap: () => onFilterChanged(DiscountScopeFilter.global),
                ),
                _FilterChip(
                  label: context.tr('منتجات'),
                  icon: Icons.inventory_2_outlined,
                  selected: state.scopeFilter == DiscountScopeFilter.product,
                  onTap: () => onFilterChanged(DiscountScopeFilter.product),
                ),
                _FilterChip(
                  label: context.tr('فئات'),
                  icon: Icons.category_outlined,
                  selected: state.scopeFilter == DiscountScopeFilter.category,
                  onTap: () => onFilterChanged(DiscountScopeFilter.category),
                ),
                _FilterChip(
                  label: context.tr('خاصة بي'),
                  icon: Icons.person_pin_circle_outlined,
                  selected: state.scopeFilter == DiscountScopeFilter.customer,
                  onTap: () => onFilterChanged(DiscountScopeFilter.customer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : context.appSurface,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? AppColors.primary : context.appSoftBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppColors.white : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: selected ? AppColors.white : context.appText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InlineMessage({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: context.appText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDiscounts extends StatelessWidget {
  final String query;

  const _EmptyDiscounts({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 52,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            query.trim().isEmpty
                ? context.tr('لا توجد خصومات متاحة حالياً')
                : context.tr('لا توجد نتائج مطابقة للبحث'),
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DiscountsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.titleSmall.copyWith(color: context.appText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: Text(context.tr('إعادة المحاولة')),
            ),
          ],
        ),
      ),
    );
  }
}
