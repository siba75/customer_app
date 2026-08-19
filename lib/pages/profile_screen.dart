// lib/screens/profile/profile_screen.dart
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/localization/language_controller.dart';
import 'package:customer_app/core/services/notification_service.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/core/theem/theme_controller.dart';
import 'package:customer_app/cubit_folder/cart_cubit.dart';
import 'package:customer_app/cubit_folder/customer_profile_cubit.dart';
import 'package:customer_app/cubit_folder/customer_profile_state.dart';
import 'package:customer_app/cubit_folder/notifications_cubit.dart';
import 'package:customer_app/cubit_folder/notifications_state.dart';
import 'package:customer_app/cubit_folder/order_cubit.dart';
import 'package:customer_app/cubit_folder/order_state.dart';
import 'package:customer_app/dio/customer_api.dart';
import 'package:customer_app/dio/notifications_api.dart';
import 'package:customer_app/dio/order_api.dart';
import 'package:customer_app/model/customer_profile_model.dart';
import 'package:customer_app/pages/discounts_screen.dart';
import 'package:customer_app/pages/login_screen.dart';
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
        BlocProvider(
          create: (_) =>
              NotificationsCubit(NotificationsApi())..loadNotifications(),
        ),
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
                  value: context.money(profile.totalSpent),
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
        Icons.local_offer_outlined,
        'الخصومات',
        'العروض العامة والخاصة بحسابك',
        () {
          CartCubit? cartCubit;
          try {
            cartCubit = context.read<CartCubit>();
          } catch (_) {
            cartCubit = null;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscountsScreen(cartCubit: cartCubit),
            ),
          );
        },
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
        () {
          final notificationsCubit = context.read<NotificationsCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotificationsScreen(cubit: notificationsCubit),
            ),
          );
        },
        trailing: _notificationBadge(),
      ),
      _item(
        Icons.language_outlined,
        'اللغة',
        LanguageController.isArabic ? 'العربية (Arabic)' : 'English',
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

  Widget _notificationBadge() {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (previous, current) =>
          previous.unreadCount != current.unreadCount ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        if (state.isLoading && state.notifications.isEmpty) {
          return const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final unreadCount = state.unreadCount;
        if (unreadCount <= 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            unreadCount > 99
                ? context.tr('99+ جديد')
                : context.trArgs('{count} جديد', {'count': unreadCount}),
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
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
            context.tr('اختر اللغة'),
            style: AppTypography.titleMedium.copyWith(color: context.appText),
          ),
          _lang(context, 'العربية', LanguageController.arabicCode),
          _lang(context, 'English', LanguageController.englishCode),
        ],
      ),
    );
  }

  Widget _lang(BuildContext context, String lang, String languageCode) {
    final selected =
        LanguageController.locale.value.languageCode == languageCode;

    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.primary : AppColors.grey,
      ),
      title: Text(context.tr(lang), style: TextStyle(color: context.appText)),
      onTap: () async {
        await LanguageController.setLanguage(languageCode);
        if (!context.mounted) return;
        Navigator.pop(context);
      },
    );
  }



  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('تسجيل الخروج')),
        content: Text(context.tr('هل أنت متأكد؟')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('إلغاء')),
          ),
          ElevatedButton(
            onPressed: () async {
              await SecureStorage.clearAuthSession();
              NotificationService.disconnectSocketNotifications();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              context.tr('خروج'),
              style: const TextStyle(color: AppColors.white),
            ),
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
                      context.tr('تعديل معلومات الحساب'),
                      style: AppTypography.titleLarge.copyWith(
                        color: context.appText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _field(
                      controller: _nameController,
                      label: context.tr('الاسم الكامل'),
                      icon: Icons.person_outline,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _phoneController,
                      label: context.tr('رقم الهاتف'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _addressController,
                      label: context.tr('العنوان'),
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
                            : Text(
                                context.tr('حفظ التعديلات'),
                                style: const TextStyle(color: AppColors.white),
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
      return AppLocalizations.translate('هذا الحقل مطلوب');
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
                child: Text(
                  context.tr('إعادة المحاولة'),
                  style: const TextStyle(color: AppColors.white),
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
