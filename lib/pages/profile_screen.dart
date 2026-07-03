// lib/screens/profile/profile_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/core/theem/theme_controller.dart';
import 'package:customer_app/cubit_folder/customer_profile_cubit.dart';
import 'package:customer_app/cubit_folder/customer_profile_state.dart';
import 'package:customer_app/cubit_folder/order_cubit.dart';
import 'package:customer_app/cubit_folder/order_state.dart';
import 'package:customer_app/dio/customer_api.dart';
import 'package:customer_app/dio/order_api.dart';
import 'package:customer_app/model/customer_profile_model.dart';
import 'package:customer_app/pages/loyalty_rewards_screen.dart';
import 'package:customer_app/pages/notifications_screen.dart';
import 'package:customer_app/widgets/customer/profile_header.dart';
import 'package:customer_app/widgets/customer/profile_menu_item.dart';
import 'package:customer_app/widgets/customer/profile_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final bool useExistingCubit;

  const ProfileScreen({super.key, this.useExistingCubit = false});

  @override
  Widget build(BuildContext context) {
    if (useExistingCubit) {
      return const _ProfileView();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CustomerProfileCubit(CustomerApi())..loadProfile(),
        ),
        BlocProvider(create: (_) => OrderCubit(OrderApi())..loadOrders()),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerProfileCubit, CustomerProfileState>(
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message == null) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: state.errorMessage == null
                ? AppColors.success
                : AppColors.error,
          ),
        );

        if (state.successMessage != null && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.profile == null) {
          return Scaffold(
            backgroundColor: context.appBackground,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state.profile == null) {
          return _ProfileErrorView(
            message: state.errorMessage ?? 'تعذر تحميل بيانات الحساب',
            onRetry: context.read<CustomerProfileCubit>().loadProfile,
          );
        }

        final profile = state.profile!;

        return Scaffold(
          backgroundColor: context.appBackground,
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: context.read<CustomerProfileCubit>().loadProfile,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: ProfileHeader(profile: profile)),
                SliverToBoxAdapter(child: _StatsSection(profile: profile)),
                SliverToBoxAdapter(child: _MenuSection(profile: profile)),
                const SliverToBoxAdapter(child: _Footer()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatsSection extends StatelessWidget {
  final CustomerProfileModel profile;

  const _StatsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        final ordersCount = orderState.isLoading && orderState.orders.isEmpty
            ? '...'
            : orderState.orders.length.toString();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: ProfileStatsCard(
                  title: 'الطلبات',
                  value: ordersCount,
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProfileStatsCard(
                  title: 'نقاط الولاء',
                  value: profile.loyaltyPoints.toString(),
                  icon: Icons.star_outline,
                  color: AppColors.secondary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoyaltyRewardsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProfileStatsCard(
                  title: 'إجمالي الشراء',
                  value: _formatTotalSpent(profile.totalSpent),
                  icon: Icons.payments_outlined,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTotalSpent(double totalSpent) {
    return totalSpent.toStringAsFixed(
      totalSpent.truncateToDouble() == totalSpent ? 0 : 2,
    );
  }
}

class _MenuSection extends StatelessWidget {
  final CustomerProfileModel profile;

  const _MenuSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = [
      _item(
        Icons.person_outline,
        'تعديل المعلومات الشخصية',
        '${profile.fullName}، ${profile.phoneNumber}',
        () => _showEditProfileSheet(context, profile),
      ),
      _item(
        Icons.location_on_outlined,
        'عنواني',
        profile.address.isEmpty ? 'لم يتم إضافة عنوان' : profile.address,
        () {},
        showChevron: false,
      ),
      _item(
        Icons.card_giftcard_outlined,
        'مكافآت الولاء',
        'العروض المتاحة حسب نقاطك',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoyaltyRewardsScreen()),
        ),
      ),
      _item(
        Icons.notifications_none,
        'الإشعارات',
        'إعدادات التنبيهات',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        ),
        trailing: _badge(),
      ),
      _item(
        Icons.language_outlined,
        'اللغة',
        'العربية (Arabic)',
        () => _showLanguageDialog(context),
      ),
      _item(
        Icons.dark_mode_outlined,
        'الوضع الداكن',
        'تبديل مظهر التطبيق',
        () => ThemeController.setDarkMode(!ThemeController.isDarkMode),
        trailing: _themeSwitch(),
      ),
      _item(
        Icons.help_outline,
        'المساعدة والدعم',
        'الأسئلة الشائعة والتواصل معنا',
        () => _snack(context),
      ),
      _item(
        Icons.info_outline,
        'عن التطبيق',
        'الإصدار 1.0.0',
        () => _showAppInfoDialog(context),
      ),
      _item(
        Icons.logout,
        'تسجيل الخروج',
        'الخروج من حسابك',
        () => _showLogoutDialog(context),
        isLogout: true,
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: _box(context),
      child: Column(
        children: List.generate(
          items.length,
          (index) => Column(
            children: [
              items[index],
              if (index != items.length - 1) _divider(context),
            ],
          ),
        ),
      ),
    );
  }

  ProfileMenuItem _item(
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap, {
    Widget? trailing,
    bool isLogout = false,
    bool showChevron = true,
  }) {
    return ProfileMenuItem(
      icon: icon,
      title: title,
      subtitle: sub,
      onTap: onTap,
      trailing: trailing,
      isLogout: isLogout,
      showChevron: showChevron,
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: context.appSoftBorder,
    );
  }

  BoxDecoration _box(BuildContext context) {
    return BoxDecoration(
      color: context.appSurface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: context.appSoftBorder),
      boxShadow: context.appCardShadow(
        alpha: 0.1,
        blur: 26,
        offset: const Offset(0, 10),
      ),
    );
  }

  Widget _themeSwitch() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;

        return Switch(
          value: isDark,
          activeThumbColor: AppColors.secondary,
          activeTrackColor: AppColors.secondarySoft,
          inactiveThumbColor: AppColors.primary,
          inactiveTrackColor: AppColors.primarySoft,
          onChanged: ThemeController.setDarkMode,
        );
      },
    );
  }

  Widget _badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '3 جديد',
        style: TextStyle(
          color: AppColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _snack(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري التطوير...')));
  }

  void _showEditProfileSheet(
    BuildContext context,
    CustomerProfileModel profile,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomerProfileCubit>(),
        child: _EditProfileSheet(profile: profile),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'اختر اللغة',
            style: AppTypography.titleMedium.copyWith(color: context.appText),
          ),
          _lang(context, 'العربية', true),
          _lang(context, 'English', false),
        ],
      ),
    );
  }

  Widget _lang(BuildContext context, String lang, bool selected) {
    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.primary : AppColors.grey,
      ),
      title: Text(lang, style: TextStyle(color: context.appText)),
      onTap: () {
        Navigator.pop(context);
        _snack(context);
      },
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('عن التطبيق'),
        content: Text('Smart Store\nالإصدار 1.0.0'),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('خروج', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final CustomerProfileModel profile;

  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _addressController = TextEditingController(text: widget.profile.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<CustomerProfileCubit>().updateProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: context.appCardShadow(
                alpha: 0.16,
                blur: 32,
                offset: const Offset(0, -10),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.appSoftBorder,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'تعديل معلومات الحساب',
                      style: AppTypography.titleLarge.copyWith(
                        color: context.appText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(
                      controller: _nameController,
                      label: 'الاسم الكامل',
                      icon: Icons.person_outline,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _addressController,
                      label: 'العنوان',
                      icon: Icons.location_on_outlined,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state.isUpdating ? null : _submit,
                        child: state.isUpdating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'حفظ التعديلات',
                                style: TextStyle(color: AppColors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
}

class _ProfileErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: Center(
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
                style: AppTypography.bodyLarge.copyWith(
                  color: context.appMutedText,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          '© 2026 Smart Store',
          style: TextStyle(fontSize: 11, color: AppColors.grey),
        ),
      ),
    );
  }
}
