import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/model/ad_model.dart';
import 'package:flutter/material.dart';

class PromoBannerCard extends StatelessWidget {
  final AdModel banner;
  final VoidCallback onActionTap;

  const PromoBannerCard({
    super.key,
    required this.banner,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return SizedBox(
          height: isCompact ? 318 : 304,
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
                _BannerContent(
                  banner: banner,
                  isCompact: isCompact,
                  onActionTap: onActionTap,
                ),
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
  final VoidCallback onActionTap;

  const _BannerContent({
    required this.banner,
    required this.isCompact,
    required this.onActionTap,
  });

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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(text: banner.badge),
                _InfoPill(text: banner.placementLabel),
              ],
            ),
            const Spacer(flex: 2),
            Text(
              title,
              style: TextStyle(
                color: AppColors.white,
                fontSize: isCompact ? 21 : 24,
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
              maxLines: isCompact ? 4 : 5,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            _AdMetaRow(banner: banner),
            const SizedBox(height: 12),
            _ActionButton(
              label: banner.actionText,
              color: banner.colors.first,
              isCompact: isCompact,
              onPressed: onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdMetaRow extends StatelessWidget {
  final AdModel banner;

  const _AdMetaRow({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          banner.icon,
          color: AppColors.white.withValues(alpha: 0.82),
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            banner.dateRange,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isCompact;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isCompact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 36,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: isCompact ? 112 : 124,
            maxWidth: isCompact ? 132 : 156,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: color,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isCompact ? 12 : 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;

  const _InfoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
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
