import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/model/ad_model.dart';
import 'package:flutter/material.dart';

class PromoBannerCard extends StatelessWidget {
  final AdModel banner;

  const PromoBannerCard({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final cardHeight = (constraints.maxWidth * 0.62).clamp(214.0, 268.0);

        return SizedBox(
          height: cardHeight,
          child: Container(
            width: double.infinity,
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
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (banner.hasImage) _BannerImage(imageUrl: banner.imageUrl!),
                const _ImageOverlay(),
                const Positioned(
                  top: -36,
                  left: -24,
                  child: _GlowCircle(size: 118, opacity: 0.12),
                ),
                const Positioned(
                  bottom: -46,
                  right: 88,
                  child: _GlowCircle(size: 92, opacity: 0.08),
                ),
                _BannerContent(banner: banner, isCompact: isCompact),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BannerContent extends StatelessWidget {
  final AdModel banner;
  final bool isCompact;

  const _BannerContent({required this.banner, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final title = banner.title.trim().isEmpty ? 'إعلان' : banner.title.trim();
    final description = banner.description.trim().isEmpty
        ? 'لا يوجد وصف متاح لهذا الإعلان.'
        : banner.description.trim();

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: AppColors.white,
                fontSize: isCompact ? 20 : 23,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                height: 1.32,
              ),
              maxLines: isCompact ? 3 : 4,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  final String imageUrl;

  const _BannerImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}

class _ImageOverlay extends StatelessWidget {
  const _ImageOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xAA000000), Color(0x66000000), Color(0xCC000000)],
          ),
        ),
      ),
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
