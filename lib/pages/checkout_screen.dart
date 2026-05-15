// lib/screens/checkout_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:flutter/material.dart';

import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  String _selectedPaymentMethod = 'cod';
  String _selectedAddress = 'home';
  bool _isProcessing = false;

  // بيانات وهمية للعنوان
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 'home',
      'title': 'المنزل',
      'address': 'دمشق - باب شرقي - شارع النصر',
      'icon': Icons.home_outlined,
      'isDefault': true,
    },
    {
      'id': 'work',
      'title': 'العمل',
      'address': 'دمشق - كفرسوسة - طريق المطار',
      'icon': Icons.work_outline,
      'isDefault': false,
    },
  ];

  // بيانات الفاتورة
  final Map<String, dynamic> _invoice = {
    'subtotal': 25.50,
    'delivery': 5.00,
    'discount': 2.50,
    'tax': 0.00,
    'total': 28.00,
  };

  void _placeOrder() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
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
                color: AppColors.success.withOpacity(0.1),
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
              'رقم الطلب: #ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13)}',
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
                    onPressed: () => Navigator.pop(context),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
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
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: context.appText,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                _buildProgressIndicator(),

                const SizedBox(height: 8),

                // Delivery Address Section
                _buildSectionHeader(' عنوان التوصيل'),
                _buildAddressSection(),

                // Order Items Preview
                _buildSectionHeader('🛍️ منتجاتك'),
                _buildOrderItemsPreview(),

                // Payment Method
                _buildSectionHeader('💳 طريقة الدفع'),
                _buildPaymentSection(),

                // Order Notes
                _buildSectionHeader('📝 ملاحظات إضافية'),
                _buildNotesSection(),
              ],
            ),
          ),

          // Bottom Bar with Total & Checkout Button
          _buildBottomBar(),
        ],
      ),
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
    final color = isActive ? AppColors.primary : AppColors.grey;
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
        // style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        style: AppTypography.titleMedium.copyWith(
          color: context.appText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
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
            value: 'home',
            groupValue: _selectedAddress,
            onChanged: (value) => setState(() => _selectedAddress = value!),
            title: Text('المنزل', style: TextStyle(color: context.appText)),
            subtitle: Text(
              'دمشق - باب شرقي - شارع النصر',
              style: TextStyle(color: context.appMutedText),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home, size: 24, color: AppColors.primary),
            ),
            activeColor: AppColors.primary,
          ),
          RadioListTile<String>(
            value: 'work',
            groupValue: _selectedAddress,
            onChanged: (value) => setState(() => _selectedAddress = value!),
            title: Text('العمل', style: TextStyle(color: context.appText)),
            subtitle: Text(
              'دمشق - كفرسوسة - طريق المطار',
              style: TextStyle(color: context.appMutedText),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.work,
                size: 24,
                color: AppColors.secondary,
              ),
            ),
            activeColor: AppColors.primary,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة عنوان جديد'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsPreview() {
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
          _buildOrderItem(
            'طماطم',
            5.50,
            2,
            'https://picsum.photos/200/200?random=1',
          ),
          const Divider(),
          _buildOrderItem(
            'خيار',
            3.00,
            1,
            'https://picsum.photos/200/200?random=2',
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموع',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_invoice['subtotal']} ل.س',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    String name,
    double price,
    int quantity,
    String imageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shopping_bag, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الكمية: $quantity',
                  style: AppTypography.titleMedium.copyWith(
                    color: context.appMutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(price * quantity).toStringAsFixed(2)} ل.س',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
            groupValue: _selectedPaymentMethod,
            onChanged: (value) =>
                setState(() => _selectedPaymentMethod = value!),
            title: Text(
              'الدفع عند الاستلام حصرا',
              style: AppTypography.titleLarge.copyWith(color: context.appText),
            ),
            subtitle: Text(
              ' ادفع نقداً عند استلام طلبك  ',
              style: TextStyle(color: context.appMutedText),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
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

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'أضف ملاحظات للطلب (اختياري)...',
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey),
          border: InputBorder.none,
          filled: true,
          fillColor: context.appBackground,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
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
                          '${_invoice['total'].toStringAsFixed(2)} ل.س',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _placeOrder,
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
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
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
            ],
          ),
        ),
      ),
    );
  }
}
