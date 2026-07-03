import 'dart:async';

import 'package:customer_app/model/ad_model.dart';
import 'package:customer_app/widgets/home_widgets/promo_banner_card.dart';
import 'package:customer_app/widgets/home_widgets/promo_banner_indicator.dart';
import 'package:flutter/material.dart';

class PromoBannerCarousel extends StatefulWidget {
  final List<dynamic> banners;

  const PromoBannerCarousel({super.key, required this.banners});

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
  void didUpdateWidget(covariant PromoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.banners.length == widget.banners.length) return;

    _timer?.cancel();
    _currentIndex = 0;
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<AdModel> get _banners {
    return widget.banners
        .map(_asAdModel)
        .whereType<AdModel>()
        .toList(growable: false);
  }

  void _startAutoPlay() {
    if (_banners.length < 2) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % _banners.length;
      });
    });
  }

  AdModel? _asAdModel(dynamic banner) {
    if (banner is AdModel) return banner;

    try {
      return AdModel(
        id: banner.hashCode,
        title: banner.title?.toString() ?? '',
        description: banner.subtitle?.toString() ?? '',
        placement: 'HOME',
        isActive: true,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final banners = _banners;
    if (banners.isEmpty) return const SizedBox.shrink();

    if (_currentIndex >= banners.length) {
      _currentIndex = 0;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
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
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: PromoBannerCard(
                  key: ValueKey(banners[_currentIndex].id),
                  banner: banners[_currentIndex],
                ),
              ),
              const SizedBox(height: 10),
              PromoBannerIndicator(
                count: banners.length,
                currentIndex: _currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
