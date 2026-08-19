import 'package:customer_app/core/localization/app_localizations.dart';
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
  final NotificationsCubit? cubit;

  const NotificationsScreen({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    final existingCubit = cubit;

    if (existingCubit != null) {
      return BlocProvider.value(
        value: existingCubit,
        child: const _NotificationsView(),
      );
    }

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
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 220) return;

    context.read<NotificationsCubit>().loadMore();
  }

  List<CustomerNotification> _filteredNotifications(
    List<CustomerNotification> notifications,
  ) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications
            .where((notification) => !notification.isRead)
            .toList();
      case 'read':
        return notifications
            .where((notification) => notification.isRead)
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
        title: Text(context.tr('الإشعارات')),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              return IconButton(
                tooltip: context.tr('تحديث الإشعارات'),
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
            onRefresh: () =>
                context.read<NotificationsCubit>().loadNotifications(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: NotificationSummaryHeader(
                    totalCount: state.total,
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
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(child: _LoadMoreIndicator()),
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
      case 'read':
        return 'لا توجد إشعارات مقروءة';
      default:
        return 'لا توجد إشعارات';
    }
  }

  String get _emptySubtitle {
    switch (_selectedFilter) {
      case 'unread':
        return 'كل شيء مقروء ومرتب لديك.';
      case 'read':
        return 'الإشعارات التي تقرئينها ستظهر هنا.';
      default:
        return 'كل إشعارات الطلبات والعروض وتحديثات الحساب ستظهر هنا.';
    }
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
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
              child: Text(
                context.tr('إعادة المحاولة'),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
