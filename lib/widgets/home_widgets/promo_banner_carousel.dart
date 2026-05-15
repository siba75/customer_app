import 'dart:async';

import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/model/promo_banner_model.dart';
import 'package:flutter/material.dart';

class PromoBannerCarousel extends StatefulWidget {
  final List<PromoBannerModel> banners;
  final VoidCallback onActionTap;

  const PromoBannerCarousel({
    super.key,
    required this.banners,
    required this.onActionTap,
  });

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.banners.length < 2) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.banners.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 520),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slideAnimation, child: child),
              );
            },
            child: _PromoBanner(
              key: ValueKey(widget.banners[_currentIndex].title),
              banner: widget.banners[_currentIndex],
              onActionTap: widget.onActionTap,
            ),
          ),
          const SizedBox(height: 10),
          _BannerIndicator(
            count: widget.banners.length,
            currentIndex: _currentIndex,
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final PromoBannerModel banner;
  final VoidCallback onActionTap;

  const _PromoBanner({
    super.key,
    required this.banner,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final iconSize = (constraints.maxWidth * 0.2).clamp(54.0, 78.0);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isCompact ? 14 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: banner.colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: banner.colors.first.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -36,
                left: -24,
                child: _GlowCircle(size: 118, opacity: 0.14),
              ),
              Positioned(
                bottom: -46,
                right: 88,
                child: _GlowCircle(size: 92, opacity: 0.1),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _BannerText(
                      banner: banner,
                      onTap: onActionTap,
                      isCompact: isCompact,
                    ),
                  ),
                  SizedBox(width: isCompact ? 8 : 12),
                  if (constraints.maxWidth > 300)
                    _BannerIcon(icon: banner.icon, size: iconSize),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerText extends StatelessWidget {
  final PromoBannerModel banner;
  final VoidCallback onTap;
  final bool isCompact;

  const _BannerText({
    required this.banner,
    required this.onTap,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 12,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            banner.badge,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: isCompact ? 9 : 11),
        Text(
          banner.title,
          style: TextStyle(
            color: AppColors.white,
            fontSize: isCompact ? 22 : 25,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          banner.subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.white.withValues(alpha: 0.84),
          ),
          maxLines: isCompact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isCompact ? 10 : 13),
        SizedBox(
          height: 34,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: banner.colors.first,
              minimumSize: Size(isCompact ? 96 : 118, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              banner.actionText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isCompact ? 12 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _BannerIcon({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size < 70 ? 18 : 22),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, size: size * 0.54, color: AppColors.white),
    );
  }
}

class _BannerIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _BannerIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isActive ? 22 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.greyLight,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
