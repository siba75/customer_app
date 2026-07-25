// lib/screens/checkout_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/core/helpers/app_error_messages.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/cubit_folder/cart_state.dart';
import 'package:customer_app/cubit_folder/customer_profile_cubit.dart';
import 'package:customer_app/cubit_folder/customer_profile_state.dart';
import 'package:customer_app/cubit_folder/order_cubit.dart';
import 'package:customer_app/dio/loyalty_rewards_api.dart';
import 'package:customer_app/model/cart_item_model.dart';
import 'package:customer_app/model/loyalty_policy_model.dart';
import 'package:customer_app/pages/orders_screen.dart';
import 'package:customer_app/widgets/product/authenticated_product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutScreen extends StatefulWidget {
  final double initialSubtotal;
  final double initialDelivery;
  final double initialDiscount;
  final String? initialDiscountName;

  const CheckoutScreen({
    super.key,
    this.initialSubtotal = 0,
    this.initialDelivery = 0,
    this.initialDiscount = 0,
    this.initialDiscountName,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _loyaltyPointsController = TextEditingController(
    text: '0',
  );
  String _selectedPaymentMethod = 'cod';
  String _selectedAddress = 'profile';
  bool _isProcessing = false;
  bool _isLoadingLoyaltyPolicy = true;
  LoyaltyPolicyModel _loyaltyPolicy = const LoyaltyPolicyModel.empty();
  String? _loyaltyPolicyError;
  int _loyaltyPointsUsed = 0;
  String? _createdOrderNumber;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyPolicy();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CartCubit>().loadDiscounts();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _loyaltyPointsController.dispose();
    super.dispose();
  }

  Future<void> _loadLoyaltyPolicy() async {
    try {
      final policy = await LoyaltyRewardsApi().getLoyaltyPolicy();
      if (!mounted) return;
      setState(() {
        _loyaltyPolicy = policy;
        _loyaltyPolicyError = null;
        _isLoadingLoyaltyPolicy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final message = e.toString().replaceFirst('Exception: ', '');
        _loyaltyPolicyError = AppErrorMessages.friendly(
          message,
          fallback: 'سيحسب الخادم قيمة النقاط عند تأكيد الطلب.',
        );
        _isLoadingLoyaltyPolicy = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);

    try {
      final cartCubit = context.read<CartCubit>();
      final cartState = cartCubit.state;
      final maxPoints = _maxUsablePoints(cartState);

      if (cartState.items.isEmpty) {
        throw Exception('السلة فارغة، الرجاء إضافة منتجات قبل تأكيد الطلب.');
      }

      if (_loyaltyPointsUsed > maxPoints) {
        throw Exception('عدد نقاط الولاء أكبر من الحد المسموح لهذا الطلب.');
      }

      final invalidStockItem = _firstInvalidStockItem(cartState.items);
      if (invalidStockItem != null) {
        throw Exception(
          'الكمية المطلوبة من ${invalidStockItem.name} أكبر من المخزون المتاح (${invalidStockItem.maxQuantity}).',
        );
      }

      final deliveryAddress = _deliveryAddress();
      if (_selectedAddress == 'custom' && deliveryAddress == null) {
        throw Exception('الرجاء إدخال عنوان التوصيل.');
      }

      final order = await context.read<OrderCubit>().createOrder(
        items: cartState.items,
        discountId: cartState.orderDiscountId,
        loyaltyPointsUsed: _loyaltyPointsUsed,
        deliveryAddress: deliveryAddress,
      );

      await cartCubit.clearCart();
      await _reloadProfileSafely();

      if (!mounted) return;
      setState(() {
        _createdOrderNumber = order.orderNumber;
        _isProcessing = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  CustomerProfileState? _readProfileState() {
    try {
      return context.read<CustomerProfileCubit>().state;
    } catch (_) {
      return null;
    }
  }

  Future<void> _reloadProfileSafely() async {
    try {
      await context.read<CustomerProfileCubit>().loadProfile();
    } catch (_) {
      // Profile is not always provided when checkout is opened directly.
    }
  }

  String? _deliveryAddress() {
    if (_selectedAddress == 'custom') {
      final customAddress = _addressController.text.trim();
      return customAddress.isEmpty ? null : customAddress;
    }

    final profileAddress = _readProfileState()?.profile?.address.trim() ?? '';
    return profileAddress.isEmpty ? null : profileAddress;
  }

  Map<String, double> _invoiceFor(CartState state) {
    final loyaltyDiscount = _loyaltyDiscountFor(state);
    return {
      'subtotal': state.subtotal,
      'delivery': state.delivery,
      'discount': state.discount,
      'loyaltyDiscount': loyaltyDiscount,
      'total': (state.total - loyaltyDiscount).clamp(0, double.infinity),
    };
  }

  int _availableLoyaltyPoints() {
    return _readProfileState()?.profile?.loyaltyPoints ?? 0;
  }

  int _maxUsablePoints(CartState state) {
    final available = _availableLoyaltyPoints();
    if (!_loyaltyPolicy.isConfigured) return available;

    final payableTotal = state.total;
    final maxByTotal = (payableTotal / _loyaltyPolicy.currencyPerPoint).floor();

    return available < maxByTotal ? available : maxByTotal;
  }

  double _loyaltyDiscountFor(CartState state) {
    final maxPoints = _maxUsablePoints(state);
    final safePoints = _loyaltyPointsUsed.clamp(0, maxPoints).toInt();
    return _loyaltyPolicy
        .discountForPoints(safePoints)
        .clamp(0, state.total)
        .toDouble();
  }

  void _setLoyaltyPoints(
    int value,
    CartState state, {
    bool updateController = true,
  }) {
    final maxPoints = _maxUsablePoints(state);
    final safeValue = value.clamp(0, maxPoints).toInt();
    setState(() {
      _loyaltyPointsUsed = safeValue;
      if (updateController) {
        _loyaltyPointsController.text = safeValue.toString();
        _loyaltyPointsController.selection = TextSelection.collapsed(
          offset: _loyaltyPointsController.text.length,
        );
      }
    });
  }

  void _syncLoyaltyPoints(CartState state) {
    final maxPoints = _maxUsablePoints(state);
    if (_loyaltyPointsUsed <= maxPoints) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _setLoyaltyPoints(maxPoints, state);
    });
  }

  CartItem? _firstInvalidStockItem(List<CartItem> items) {
    for (final item in items) {
      if (item.maxQuantity != null && item.quantity > item.maxQuantity!) {
        return item;
      }
    }

    return null;
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تم تقديم الطلب بنجاح!',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم الطلب: ${_createdOrderNumber ?? 'غير متوفر'}',
              style: AppTypography.bodyMedium.copyWith(
                color: context.appMutedText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'شكراً لتسوقك معنا',
              style: AppTypography.bodyMedium.copyWith(
                color: context.appMutedText,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'مواصلة التسوق',
                      style: TextStyle(color: context.appMutedText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final orderCubit = context.read<OrderCubit>();
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: orderCubit,
                            child: const OrdersScreen(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'عرض طلباتي',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        _syncLoyaltyPoints(cartState);
        return Scaffold(
          backgroundColor: context.appBackground,
          appBar: AppBar(
            title: const Text('إتمام الطلب'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: context.appText,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 8),
                _buildSectionHeader('عنوان التوصيل'),
                _buildAddressSection(),
                _buildSectionHeader('منتجات الطلب'),
                _buildOrderItemsPreview(cartState),
                _buildSectionHeader('نقاط الولاء'),
                _buildLoyaltySection(cartState),
                _buildSectionHeader('طريقة الدفع'),
                _buildPaymentSection(),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(cartState),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep(1, 'السلة', true),
          Expanded(child: _buildProgressLine(true)),
          _buildProgressStep(2, 'الدفع', true),
          Expanded(child: _buildProgressLine(false)),
          _buildProgressStep(3, 'تأكيد', false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.greyLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? AppColors.white : AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            color: isActive ? AppColors.primary : AppColors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? AppColors.primary : AppColors.greyLight,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: context.appText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    try {
      context.read<CustomerProfileCubit>();
      return BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
        builder: (context, profileState) {
          return _buildAddressContent(profileState);
        },
      );
    } catch (_) {
      return _buildAddressContent(null);
    }
  }

  Widget _buildAddressContent(CustomerProfileState? profileState) {
    final profileAddress = profileState?.profile?.address.trim() ?? '';
    final hasProfileAddress = profileAddress.isNotEmpty;

    if (!hasProfileAddress && _selectedAddress == 'profile') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedAddress = 'custom');
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        children: [
          if (hasProfileAddress)
            RadioListTile<String>(
              value: 'profile',
              // ignore: deprecated_member_use
              groupValue: _selectedAddress,
              // ignore: deprecated_member_use
              onChanged: (value) => setState(() => _selectedAddress = value!),
              title: Text(
                'عنوان حسابي',
                style: TextStyle(color: context.appText),
              ),
              subtitle: Text(
                profileAddress,
                style: TextStyle(color: context.appMutedText),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              activeColor: AppColors.primary,
            ),
          RadioListTile<String>(
            value: 'custom',
            // ignore: deprecated_member_use
            groupValue: _selectedAddress,
            // ignore: deprecated_member_use
            onChanged: (value) => setState(() => _selectedAddress = value!),
            title: Text(
              hasProfileAddress ? 'عنوان آخر' : 'عنوان التوصيل',
              style: TextStyle(color: context.appText),
            ),
            subtitle: Text(
              'اكتب العنوان الذي تريد استلام الطلب عليه',
              style: TextStyle(color: context.appMutedText),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_location_alt_outlined,
                size: 24,
                color: AppColors.secondary,
              ),
            ),
            activeColor: AppColors.primary,
          ),
          if (_selectedAddress == 'custom')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextField(
                controller: _addressController,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'مثال: دمشق - باب شرقي - شارع النصر',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey,
                  ),
                  filled: true,
                  fillColor: context.appBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.appSoftBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.appSoftBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsPreview(CartState state) {
    final invoice = _invoiceFor(state);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        children: [
          if (state.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'السلة فارغة',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.appMutedText,
                ),
              ),
            )
          else
            ..._buildCartItemRows(state.items),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                _buildInvoiceRow('المجموع', invoice['subtotal'] ?? 0),
                const SizedBox(height: 8),
                _buildInvoiceRow('التوصيل', invoice['delivery'] ?? 0),
                if (state.isCalculatingDiscount) ...[
                  const SizedBox(height: 8),
                  _buildInvoiceRow('جاري حساب الخصم', 0),
                ] else if ((invoice['discount'] ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  _buildInvoiceRow(
                    _discountLabel(state),
                    -(invoice['discount'] ?? 0),
                    valueColor: AppColors.success,
                  ),
                ],
                if ((invoice['loyaltyDiscount'] ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  _buildInvoiceRow(
                    'خصم نقاط الولاء',
                    -(invoice['loyaltyDiscount'] ?? 0),
                    valueColor: AppColors.success,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCartItemRows(List<CartItem> items) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      rows.add(_buildOrderItem(items[i]));
      if (i != items.length - 1) rows.add(const Divider());
    }
    return rows;
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: AuthenticatedProductImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primary,
              ),
              errorBuilder: (_) => const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الكمية: ${item.quantity}',
                  style: AppTypography.titleMedium.copyWith(
                    color: context.appMutedText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.originalTotal.toStringAsFixed(2)} ل.س',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.hasDiscount) ...[
                const SizedBox(height: 3),
                Text(
                  '${item.total.toStringAsFixed(2)} ل.س',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, double value, {Color? valueColor}) {
    final formattedValue = value < 0
        ? '-${value.abs().toStringAsFixed(2)} ل.س'
        : '${value.toStringAsFixed(2)} ل.س';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          formattedValue,
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _discountLabel(CartState state) {
    if (state.discountName != null && state.discountName!.isNotEmpty) {
      return 'الخصم - ${state.discountName}';
    }
    if (state.itemDiscount > 0) return 'خصم المنتجات';
    return 'الخصم';
  }

  Widget _buildLoyaltySection(CartState state) {
    final availablePoints = _availableLoyaltyPoints();
    final maxPoints = _maxUsablePoints(state);
    final loyaltyDiscount = _loyaltyDiscountFor(state);
    final estimatedEarned = _loyaltyPolicy.estimatedPointsForAmount(
      state.total - loyaltyDiscount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appSoftBorder),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.stars, color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رصيدك: $availablePoints نقطة',
                      style: AppTypography.titleSmall.copyWith(
                        color: context.appText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoadingLoyaltyPolicy
                          ? 'جاري تحميل سياسة النقاط...'
                          : _loyaltyPolicy.isConfigured
                          ? 'كل نقطة تساوي ${_formatMoney(_loyaltyPolicy.currencyPerPoint)} ل.س'
                          : 'سيحسب الخادم قيمة النقاط عند تأكيد الطلب',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.appMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: maxPoints == 0
                    ? null
                    : () => _setLoyaltyPoints(maxPoints, state),
                child: const Text('استخدام الكل'),
              ),
            ],
          ),
          if (_loyaltyPolicyError != null) ...[
            const SizedBox(height: 12),
            Text(
              _loyaltyPolicyError!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _loyaltyPointsController,
                  enabled: maxPoints > 0 && !_isProcessing,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'النقاط المستخدمة',
                    helperText: 'الحد الأقصى لهذا الطلب: $maxPoints',
                    prefixIcon: const Icon(Icons.redeem_outlined),
                  ),
                  onChanged: (value) => _setLoyaltyPoints(
                    int.tryParse(value) ?? 0,
                    state,
                    updateController: false,
                  ),
                ),
              ),
            ],
          ),
          if (maxPoints > 0) ...[
            const SizedBox(height: 12),
            Slider(
              value: _loyaltyPointsUsed.clamp(0, maxPoints).toDouble(),
              min: 0,
              max: maxPoints.toDouble(),
              divisions: maxPoints > 100 ? 100 : maxPoints,
              activeColor: AppColors.secondary,
              onChanged: _isProcessing
                  ? null
                  : (value) => _setLoyaltyPoints(value.round(), state),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LoyaltyInfoTile(
                  label: 'خصم النقاط',
                  value: _loyaltyPolicy.isConfigured
                      ? '${loyaltyDiscount.toStringAsFixed(2)} ل.س'
                      : 'يحسب عند الطلب',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LoyaltyInfoTile(
                  label: 'نقاط متوقعة',
                  value: '$estimatedEarned نقطة',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            value: 'cod',
            // ignore: deprecated_member_use
            groupValue: _selectedPaymentMethod,
            // ignore: deprecated_member_use
            onChanged: (value) =>
                setState(() => _selectedPaymentMethod = value!),
            title: Text(
              'الدفع عند الاستلام حصرا',
              style: AppTypography.titleLarge.copyWith(color: context.appText),
            ),
            subtitle: Text(
              'ادفع نقداً عند استلام طلبك',
              style: TextStyle(color: context.appMutedText),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.payments,
                size: 24,
                color: AppColors.success,
              ),
            ),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartState state) {
    final invoice = _invoiceFor(state);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: context.appCardShadow(
          alpha: 0.12,
          blur: 28,
          offset: const Offset(0, -10),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإجمالي',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(invoice['total'] ?? 0).toStringAsFixed(2)} ل.س',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isProcessing || state.items.isEmpty
                    ? null
                    : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تأكيد الطلب',
                            style: TextStyle(color: AppColors.white),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LoyaltyInfoTile({
    required this.label,
    required this.value,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.appMutedText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleSmall.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
