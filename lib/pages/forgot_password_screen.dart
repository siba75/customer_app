// lib/screens/forgot_password_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/widgets/responsive_keyboard_page.dart';
import 'package:flutter/material.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تم الإرسال'),
          content: Text('تم إرسال رابط إعادة تعيين كلمة المرور إلى ${_emailController.text}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً', style: TextStyle(color: AppColors.primary))),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKeyboardPage(
      appBar: AppBar(title: const Text('نسيت كلمة المرور')),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text('نسيت كلمة المرور؟', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text('أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين', style: AppTypography.bodyLarge),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _sendResetLink,
                child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('إرسال رابط إعادة التعيين'),
              ),
            ),
          ],
      ),
    );
  }
}
