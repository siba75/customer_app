// lib/screens/login_screen.dart
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/login_cubit.dart';
import 'package:customer_app/cubit_folder/login_state.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:customer_app/model/signin_model.dart';
import 'package:customer_app/pages/forgot_password_screen.dart';
import 'package:customer_app/pages/home_screen.dart';
import 'package:customer_app/pages/register_screen.dart';
import 'package:customer_app/widgets/responsive_keyboard_page.dart';
import 'package:customer_app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<LoginCubit>().login(
      SigninModel(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(AuthApi()),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state is LoginSuccess) {
            await SecureStorage.write('auth_token', state.token);
            await SecureStorage.write('user_email', state.email);

            if (!context.mounted) return;

            showCustomSnackBar(
              context,
              state.message,
              backgroundColor: AppColors.success,
              icon: Icons.check_circle_outline,
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is LoginError) {
            showCustomSnackBar(
              context,
              state.message,
              backgroundColor: AppColors.error,
              icon: Icons.error_outline,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return ResponsiveKeyboardPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 24),
                Text(
                  'مرحباً بك',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سجل الدخول للمتابعة',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.appMutedText,
                  ),
                ),
                const SizedBox(height: 32),
                _buildForm(context, isLoading),
                const SizedBox(height: 8),
                _buildForgotPasswordButton(isLoading),
                const SizedBox(height: 24),
                _buildLoginButton(context, isLoading),
                const SizedBox(height: 16),
                _buildRegisterButton(isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.store, size: 44, color: AppColors.white),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'الرجاء إدخال كلمة المرور' : null,
            onFieldSubmitted: (_) {
              if (!isLoading) {
                _login(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordButton(bool isLoading) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: isLoading
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
        child: const Text(
          'نسيت كلمة المرور؟',
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _login(context),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Text(
                'تسجيل الدخول',
                style: TextStyle(color: AppColors.white),
              ),
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
        child: const Text(
          'إنشاء حساب جديد',
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }

    return null;
  }
}
