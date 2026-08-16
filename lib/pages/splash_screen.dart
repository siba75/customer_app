// lib/screens/splash_screen.dart
import 'dart:async';

import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/core/const/secure_storage.dart';
import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/services/notification_service.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/dio/customer_api.dart';
import 'package:customer_app/pages/home_screen.dart';
import 'package:customer_app/pages/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2200), _goToNextScreen);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToNextScreen() async {
    if (!mounted) return;

    final session = await _resolveSavedSession();

    if (session.status == _SessionStatus.authenticated) {
      unawaited(NotificationService.prepareForSignedInUser());
    }

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (context, animation, secondaryAnimation) {
          return switch (session.status) {
            _SessionStatus.authenticated => const HomeScreen(),
            _SessionStatus.serverUnavailable => ServerUnavailableScreen(
              message: session.message,
            ),
            _SessionStatus.unauthenticated => const LoginScreen(),
          };
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  Future<_SessionCheckResult> _resolveSavedSession() async {
    final token = await SecureStorage.read(SecureStorage.authTokenKey);
    if (token == null || token.isEmpty) {
      return const _SessionCheckResult(_SessionStatus.unauthenticated);
    }

    try {
      await CustomerApi().getProfile();
      return const _SessionCheckResult(_SessionStatus.authenticated);
    } on CustomerSessionExpiredException {
      await SecureStorage.clearAuthSession(
        notice: 'انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.',
      );
      NotificationService.disconnectSocketNotifications();
      return const _SessionCheckResult(_SessionStatus.unauthenticated);
    } on CustomerConnectionException catch (e) {
      NotificationService.disconnectSocketNotifications();
      return _SessionCheckResult(
        _SessionStatus.serverUnavailable,
        message: e.message,
      );
    } catch (e) {
      NotificationService.disconnectSocketNotifications();
      return _SessionCheckResult(
        _SessionStatus.serverUnavailable,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              Color(0xFF6B4DB3),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(top: -80, right: -46, child: _SoftCircle(190)),
            const Positioned(bottom: -88, left: -58, child: _SoftCircle(220)),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: const _SplashContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SessionStatus { authenticated, unauthenticated, serverUnavailable }

class _SessionCheckResult {
  final _SessionStatus status;
  final String? message;

  const _SessionCheckResult(this.status, {this.message});
}

class ServerUnavailableScreen extends StatefulWidget {
  final String? message;

  const ServerUnavailableScreen({super.key, this.message});

  @override
  State<ServerUnavailableScreen> createState() =>
      _ServerUnavailableScreenState();
}

class _ServerUnavailableScreenState extends State<ServerUnavailableScreen> {
  bool _isRetrying = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
  }

  Future<void> _retry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    try {
      await CustomerApi().getProfile();
      await NotificationService.prepareForSignedInUser();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on CustomerSessionExpiredException {
      await SecureStorage.clearAuthSession(
        notice: 'انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.',
      );
      NotificationService.disconnectSocketNotifications();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on CustomerConnectionException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.message;
        _isRetrying = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _isRetrying = false;
      });
    }
  }

  Future<void> _signInAgain() async {
    await SecureStorage.clearAuthSession();
    NotificationService.disconnectSocketNotifications();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('تعذر الوصول إلى السيرفر'),
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall.copyWith(
                  color: context.appText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _message ??
                    context.tr(
                      'التطبيق لا يستطيع الوصول للسيرفر حالياً. تسجيل دخولك محفوظ، اضغطي إعادة المحاولة بعد تشغيل السيرفر.',
                    ),
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.appMutedText,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  context.trArgs('عنوان السيرفر الحالي: {url}', {
                    'url': ApiConfig.baseUrl,
                  }),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isRetrying ? null : _retry,
                  icon: _isRetrying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    _isRetrying
                        ? context.tr('جاري التحقق...')
                        : context.tr('إعادة المحاولة'),
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isRetrying ? null : _signInAgain,
                child: Text(context.tr('تسجيل الدخول بحساب آخر')),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StoreLogo(),
        const SizedBox(height: 30),
        Text(
          'Smart Store',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تسوق بذكاء مع أفضل العروض',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.white.withValues(alpha: 0.84),
          ),
        ),
        const SizedBox(height: 44),
        const _LoadingBar(),
      ],
    );
  }
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.26),
            blurRadius: 42,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.storefront_rounded,
          size: 66,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          minHeight: 5,
          backgroundColor: AppColors.white.withValues(alpha: 0.18),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;

  const _SoftCircle(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
    );
  }
}
