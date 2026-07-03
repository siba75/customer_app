import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/notifications_cubit.dart';
import 'package:customer_app/cubit_folder/notifications_state.dart';
import 'package:customer_app/dio/notifications_api.dart';
import 'package:customer_app/model/notification_model.dart';
import 'package:customer_app/widgets/home_widgets/home_shimmer.dart';
import 'package:customer_app/widgets/notification_widgets/notification_card.dart';
import 'package:customer_app/widgets/notification_widgets/notification_empty_state.dart';
import 'package:customer_app/widgets/notification_widgets/notification_filter_tabs.dart';
import 'package:customer_app/widgets/notification_widgets/notification_summary_header.dart';
import 'package:customer_app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NotificationsCubit(NotificationsApi())..loadNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  String _selectedFilter = 'all';

  List<CustomerNotification> _filteredNotifications(
    List<CustomerNotification> notifications,
  ) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications
            .where((notification) => !notification.isRead)
            .toList();
      case 'orders':
        return notifications
            .where(
              (notification) => notification.type == NotificationType.order,
            )
            .toList();
      case 'offers':
        return notifications
            .where(
              (notification) => notification.type == NotificationType.offer,
            )
            .toList();
      default:
        return notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'تحديث الإشعارات',
                onPressed: state.isLoading
                    ? null
                    : context.read<NotificationsCubit>().loadNotifications,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationsCubit, NotificationsState>(
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null) return;

          showCustomSnackBar(
            context,
            message,
            backgroundColor: AppColors.error,
            icon: Icons.error_outline,
          );
        },
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const _NotificationsLoadingView();
          }

          if (state.errorMessage != null && state.notifications.isEmpty) {
            return _NotificationsErrorView(
              message: state.errorMessage!,
              onRetry: context.read<NotificationsCubit>().loadNotifications,
            );
          }

          final filteredNotifications = _filteredNotifications(
            state.notifications,
          );

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: context.appSurface,
            onRefresh: context.read<NotificationsCubit>().loadNotifications,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: NotificationSummaryHeader(
                    totalCount: state.notifications.length,
                    unreadCount: state.unreadCount,
                    onMarkAllRead: context
                        .read<NotificationsCubit>()
                        .markAllAsRead,
                  ),
                ),
                SliverToBoxAdapter(
                  child: NotificationFilterTabs(
                    selectedFilter: _selectedFilter,
                    onChanged: (filter) =>
                        setState(() => _selectedFilter = filter),
                  ),
                ),
                if (filteredNotifications.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: NotificationEmptyState(
                      title: _emptyTitle,
                      subtitle: _emptySubtitle,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];

                        return NotificationCard(
                          notification: notification,
                          isUpdating:
                              state.updatingNotificationId == notification.id,
                          onTap: () => context
                              .read<NotificationsCubit>()
                              .markAsRead(notification),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String get _emptyTitle {
    switch (_selectedFilter) {
      case 'unread':
        return 'لا توجد إشعارات جديدة';
      case 'orders':
        return 'لا توجد إشعارات طلبات';
      case 'offers':
        return 'لا توجد عروض حالياً';
      default:
        return 'لا توجد إشعارات';
    }
  }

  String get _emptySubtitle {
    switch (_selectedFilter) {
      case 'unread':
        return 'كل شيء مقروء ومرتب لديك.';
      case 'orders':
        return 'سنخبرك هنا بكل تحديثات الطلبات القادمة.';
      case 'offers':
        return 'العروض والخصومات الجديدة ستظهر هنا.';
      default:
        return '...';
    }
  }
}

class _NotificationsLoadingView extends StatelessWidget {
  const _NotificationsLoadingView();

  @override
  Widget build(BuildContext context) {
    return HomeShimmer(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: context.appCardShadow(
              alpha: 0.08,
              blur: 22,
              offset: const Offset(0, 10),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 46, height: 46),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150, height: 16),
                    SizedBox(height: 10),
                    ShimmerBox(width: double.infinity, height: 12),
                    SizedBox(height: 7),
                    ShimmerBox(width: 210, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NotificationsErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 46),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: context.appMutedText,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
