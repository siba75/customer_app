import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/otp_verification_cubit.dart';
import 'package:customer_app/cubit_folder/otp_verification_state.dart';
import 'package:customer_app/dio/auth_api.dart';
import 'package:customer_app/model/verify_otp_model.dart';
import 'package:customer_app/pages/login_screen.dart';
import 'package:customer_app/widgets/responsive_keyboard_page.dart';
import 'package:customer_app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.email, this.token});

  final String email;
  final String? token;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 8;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  String get _code => _controllers.map((controller) => controller.text).join();

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _verifyOtp(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_code.length != _otpLength) {
      showCustomSnackBar(
        context,
        'الرجاء إدخال رمز التحقق كاملًا',
        backgroundColor: AppColors.error,
        icon: Icons.error_outline,
      );
      return;
    }

    context.read<OtpVerificationCubit>().verify(
      model: VerifyOtpModel(email: widget.email, code: _code),
      token: widget.token,
    );
  }

  void _handleOtpChanged(String value, int index) {
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');

    if (cleanValue.length > 1) {
      _fillOtpFromPaste(cleanValue);
      return;
    }

    if (cleanValue.isEmpty) {
      _controllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    _controllers[index].text = cleanValue;
    _controllers[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  void _fillOtpFromPaste(String value) {
    final endIndex = value.length > _otpLength ? _otpLength : value.length;
    final digits = value.substring(0, endIndex);

    for (var i = 0; i < _otpLength; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }

    final nextIndex = digits.length >= _otpLength
        ? _otpLength - 1
        : digits.length;
    _focusNodes[nextIndex].requestFocus();

    if (digits.length == _otpLength) {
      _focusNodes[nextIndex].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpVerificationCubit(AuthApi()),
      child: BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            showCustomSnackBar(
              context,
              state.message,
              backgroundColor: AppColors.success,
              icon: Icons.verified_outlined,
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          } else if (state is OtpVerificationError) {
            showCustomSnackBar(
              context,
              state.message,
              backgroundColor: AppColors.error,
              icon: Icons.error_outline,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OtpVerificationLoading;

          return ResponsiveKeyboardPage(
            appBar: AppBar(
              title: const Text('تأكيد الحساب'),
              leading: IconButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildOtpCard(isLoading),
                const SizedBox(height: 24),
                _buildVerifyButton(context, isLoading),
                const SizedBox(height: 16),
                _buildBackToLoginButton(isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 46,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'تحقق من بريدك الإلكتروني',
          textAlign: TextAlign.center,
          style: AppTypography.headlineSmall.copyWith(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'أدخل رمز التحقق المرسل إلى',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: context.appMutedText),
        ),
        const SizedBox(height: 6),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: AppTypography.titleSmall.copyWith(color: context.appText),
        ),
      ],
    );
  }

  Widget _buildOtpCard(bool isLoading) {
    return Card(
      elevation: 0,
      color: context.appSurface,
      shadowColor: context.shadowColor(0.14),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    Icons.password_outlined,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'رمز التحقق',
                    style: AppTypography.titleMedium.copyWith(
                      color: context.appText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: List.generate(_otpLength, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _otpLength - 1 ? 0 : 6,
                      ),
                      child: _buildOtpField(index, isLoading),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'يتكون الرمز من 8 أرقام. يمكنك لصق الرمز كاملًا هنا.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: context.appMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpField(int index, bool isLoading) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: !isLoading,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: index == _otpLength - 1
            ? TextInputAction.done
            : TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(_otpLength),
        ],
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: context.appBackground,
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.appSoftBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (value) => _handleOtpChanged(value, index),
        onFieldSubmitted: (_) {
          if (index == _otpLength - 1 && !isLoading) {
            _verifyOtp(context);
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _verifyOtp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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
                'تأكيد الرمز',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton(bool isLoading) {
    return TextButton.icon(
      onPressed: isLoading
          ? null
          : () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
      icon: const Icon(Icons.login_outlined),
      label: const Text('العودة لتسجيل الدخول'),
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    );
  }
}
