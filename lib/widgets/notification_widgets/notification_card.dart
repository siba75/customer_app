import 'package:customer_app/core/localization/app_localizations.dart';
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final CustomerNotification notification;
  final bool isUpdating;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.isUpdating = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : notification.color.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor(notification.isRead ? 0.08 : 0.13),
              blurRadius: notification.isRead ? 22 : 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIcon(notification: notification),
            const SizedBox(width: 12),
            Expanded(child: _NotificationBody(notification: notification)),
            if (isUpdating)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (!notification.isRead)
              const _UnreadDot(),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final CustomerNotification notification;

  const _NotificationIcon({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: notification.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(notification.icon, color: notification.color, size: 23),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  final CustomerNotification notification;

  const _NotificationBody({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: AppTypography.titleSmall.copyWith(
                  color: context.appText,
                  fontWeight: notification.isRead
                      ? FontWeight.w600
                      : FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (notification.time.isNotEmpty)
              Text(
                notification.time,
                style: AppTypography.bodySmall.copyWith(
                  color: context.appMutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          notification.message,
          style: AppTypography.bodyMedium.copyWith(
            color: context.appMutedText,
            height: 1.45,
          ),
        ),
        if (notification.actionText != null) ...[
          const SizedBox(height: 12),
          Text(
            notification.actionText!,
            style: AppTypography.bodyMedium.copyWith(
              color: notification.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 15,
              color: context.appMutedText.withValues(alpha: 0.82),
            ),
            Text(
              notification.receivedDate.isEmpty
                  ? context.trArgs('وصل {time}', {
                      'time': notification.receivedTime,
                    })
                  : context.trArgs('وصل {time} - {date}', {
                      'time': notification.receivedTime,
                      'date': notification.receivedDate,
                    }),
              style: AppTypography.bodySmall.copyWith(
                color: context.appMutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      margin: const EdgeInsets.only(top: 8, left: 2),
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
    );
  }
}
