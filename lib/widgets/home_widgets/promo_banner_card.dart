import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/ad_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PromoBannerCard extends StatelessWidget {
  final AdModel banner;

  const PromoBannerCard({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final cardHeight = (constraints.maxWidth * 0.62).clamp(218.0, 274.0);

        return SizedBox(
          height: cardHeight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDetails(context),
              borderRadius: BorderRadius.circular(24),
              child: Ink(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (banner.hasImage)
                        _BannerImage(imageUrl: banner.imageUrl!),
                      const _ImageOverlay(),
                      _BannerContent(banner: banner, isCompact: isCompact),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdDetailsSheet(banner: banner),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final AdModel banner;
  final bool isCompact;

  const _BannerContent({required this.banner, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final title = banner.title.trim().isEmpty
        ? context.tr('إعلان')
        : banner.title.trim();
    final description = banner.description.trim().isEmpty
        ? context.tr('لا يوجد وصف متاح لهذا الإعلان.')
        : banner.description.trim();

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _InfoPill(
                  icon: banner.icon,
                    label: context.tr(banner.placementLabel),
                  color: AppColors.white.withValues(alpha: 0.18),
                  textColor: AppColors.white,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _InfoPill(
                    icon: Icons.circle,
                    label: context.tr(banner.badge),
                    color: banner.statusColor.withValues(alpha: 0.18),
                    textColor: AppColors.white,
                    iconColor: banner.statusColor,
                  ),
                ),
              ],
            ),
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
            const SizedBox(height: 9),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                height: 1.32,
              ),
              maxLines: isCompact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    banner.dateRange,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _ActionHint(hasLink: banner.hasLink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionHint extends StatelessWidget {
  final bool hasLink;

  const _ActionHint({required this.hasLink});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasLink ? Icons.open_in_new_rounded : Icons.info_outline_rounded,
            color: AppColors.white,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            context.tr('تفاصيل'),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
            colors: [Color(0xB3000000), Color(0x66000000), Color(0xDD000000)],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color? iconColor;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdDetailsSheet extends StatelessWidget {
  final AdModel banner;

  const _AdDetailsSheet({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: context.appBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: context.appSoftBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: banner.colors.first.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(banner.icon, color: banner.colors.first),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.title.trim().isEmpty
                              ? context.tr('إعلان')
                              : banner.title.trim(),
                          style: AppTypography.titleLarge.copyWith(
                            color: context.appText,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(banner.placementLabel),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.appMutedText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusDot(
                    color: banner.statusColor,
                    label: context.tr(banner.badge),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (banner.hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      banner.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: context.appSoftPrimary,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              _DetailBlock(
                title: 'الوصف',
                value: banner.description.trim().isEmpty
                    ? context.tr('لا يوجد وصف متاح لهذا الإعلان.')
                    : banner.description.trim(),
              ),
              _DetailBlock(title: 'رقم الإعلان', value: '#${banner.id}'),
              _DetailBlock(title: 'بداية الإعلان', value: banner.startDateLabel),
              _DetailBlock(title: 'نهاية الإعلان', value: banner.endDateLabel),
              _DetailBlock(
                title: 'مكان الظهور',
                value: context.tr(banner.placementLabel),
              ),
              _DetailBlock(title: 'الحالة', value: context.tr(banner.badge)),
              _DetailBlock(title: 'تاريخ الإنشاء', value: banner.createdAtLabel),
              _DetailBlock(title: 'آخر تعديل', value: banner.updatedAtLabel),
              if (banner.hasLink)
                _LinkBlock(link: banner.linkUrl!)
              else
                _DetailBlock(
                  title: 'الرابط',
                  value: context.tr('لا يوجد رابط مرفق لهذا الإعلان.'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final String value;

  const _DetailBlock({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(title),
            style: AppTypography.bodySmall.copyWith(
              color: context.appMutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr(value),
            style: AppTypography.bodyMedium.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkBlock extends StatelessWidget {
  final String link;

  const _LinkBlock({required this.link});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: link));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('تم نسخ رابط الإعلان'))),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: _DetailBlock(title: 'الرابط', value: link),
    );
  }
}
