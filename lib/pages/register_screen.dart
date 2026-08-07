import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/core/services/notification_service.dart';
import 'package:customer_app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_app/cubit_folder/singup_cubit.dart';
import 'package:customer_app/cubit_folder/singup_state.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:customer_app/model/signup_model.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/pages/otp_verification_screen.dart';
import 'package:customer_app/widgets/responsive_keyboard_page.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(AuthApi()),
      child: ResponsiveKeyboardPage(
        maxWidth: 520,
        child: Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.appSoftBorder),
            boxShadow: context.appCardShadow(
              alpha: 0.12,
              blur: 30,
              offset: const Offset(0, 14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // أيقونة
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.store,
                        size: 44,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'إنشاء حساب جديد',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineMedium.copyWith(
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // الاسم الكامل
                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'الرجاء إدخال الاسم' : null,
                  ),
                  const SizedBox(height: 16),

                  // البريد
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'الرجاء إدخال البريد' : null,
                  ),
                  const SizedBox(height: 16),

                  // الهاتف
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'الرجاء إدخال رقم الهاتف' : null,
                  ),
                  const SizedBox(height: 16),

                  // كلمة المرور
                  StatefulBuilder(
                    builder: (context, setStateSB) {
                      return TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setStateSB(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if ((v?.isEmpty ?? true)) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          if (v!.length < 8) {
                            return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // تأكيد كلمة المرور
                  StatefulBuilder(
                    builder: (context, setStateSB) {
                      return TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'تأكيد كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setStateSB(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if ((v?.isEmpty ?? true)) {
                            return 'الرجاء تأكيد كلمة المرور';
                          }
                          if (_passwordController.text != v) {
                            return 'كلمتا المرور غير متطابقتين';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // رقم الهوية
                  TextFormField(
                    controller: _nationalIdController,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهوية',
                      prefixIcon: Icon(Icons.card_membership_outlined),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'الرجاء إدخال رقم الهوية' : null,
                  ),
                  const SizedBox(height: 24),

                  BlocConsumer<RegisterCubit, RegisterState>(
                    listener: (context, state) async {
                      if (state is RegisterSuccess) {
                        if (state.token != null) {
                          await SecureStorage.write('auth_token', state.token!);
                          await NotificationService.prepareForSignedInUser();
                        }

                        showCustomSnackBar(
                          context,
                          state.message,
                          backgroundColor: AppColors.success,
                          icon: Icons.check_circle_outline,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OtpVerificationScreen(
                              email: state.email,
                              token: state.token,
                            ),
                          ),
                        );
                      } else if (state is RegisterError) {
                        // إظهار الخطأ باستخدام SnackBar
                        showCustomSnackBar(
                          context,
                          state.message,
                          backgroundColor: AppColors.error,
                        );
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: state is RegisterLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_passwordController.text !=
                                        _confirmPasswordController.text) {
                                      showCustomSnackBar(
                                        context,
                                        'كلمتا المرور غير متطابقتين',
                                        backgroundColor: AppColors.error,
                                      );
                                      return;
                                    }

                                    final model = SignupModel(
                                      fullName: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      phoneNumber: _phoneController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      nationalId: _nationalIdController.text
                                          .trim(),
                                    );

                                    context.read<RegisterCubit>().register(
                                      model,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: state is RegisterLoading
                              ? const CircularProgressIndicator(
                                  color: AppColors.white,
                                )
                              : const Text(
                                  'إنشاء الحساب',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      'لديك حساب بالفعل؟ تسجيل الدخول',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
