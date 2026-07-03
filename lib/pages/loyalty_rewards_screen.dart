import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/loyalty_rewards_cubit.dart';
import 'package:customer_app/cubit_folder/loyalty_rewards_state.dart';
import 'package:customer_app/dio/loyalty_rewards_api.dart';
import 'package:customer_app/model/loyalty_reward_model.dart';
import 'package:customer_app/widgets/loyalty_widgets/loyalty_rewards_loading_skeleton.dart';
import 'package:customer_app/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltyRewardsScreen extends StatelessWidget {
  const LoyaltyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoyaltyRewardsCubit(LoyaltyRewardsApi())..loadRewards(),
      child: const _LoyaltyRewardsView(),
    );
  }
}

class _LoyaltyRewardsView extends StatelessWidget {
  const _LoyaltyRewardsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        title: const Text('مكافآت الولاء'),
        actions: [
          BlocBuilder<LoyaltyRewardsCubit, LoyaltyRewardsState>(
            builder: (context, state) {
              final isLoading = state is LoyaltyRewardsLoading;

              return IconButton(
                tooltip: 'تحديث المكافآت',
                onPressed: isLoading
                    ? null
                    : context.read<LoyaltyRewardsCubit>().loadRewards,
                icon: isLoading
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
      body: BlocConsumer<LoyaltyRewardsCubit, LoyaltyRewardsState>(
        listener: (context, state) {
          if (state is! LoyaltyRewardsError) return;

          showCustomSnackBar(
            context,
            state.message,
            backgroundColor: AppColors.error,
            icon: Icons.error_outline,
          );
        },
        builder: (context, state) {
          if (state is LoyaltyRewardsLoading) {
            return const LoyaltyRewardsLoadingSkeleton();
          }

          if (state is LoyaltyRewardsError) {
            return _ErrorView(
              message: state.message,
              onRetry: context.read<LoyaltyRewardsCubit>().loadRewards,
            );
          }

          final rewards = state is LoyaltyRewardsSuccess
              ? state.rewards
              : const <LoyaltyRewardModel>[];

          if (rewards.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: context.appSurface,
              onRefresh: context.read<LoyaltyRewardsCubit>().loadRewards,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [_EmptyRewardsView()],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: context.appSurface,
            onRefresh: context.read<LoyaltyRewardsCubit>().loadRewards,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: rewards.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _RewardCard(reward: rewards[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final LoyaltyRewardModel reward;

  const _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final canRedeem = reward.canRedeem;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: canRedeem
              ? AppColors.success.withValues(alpha: 0.32)
              : context.appSoftBorder,
        ),
        boxShadow: context.appCardShadow(
          alpha: 0.1,
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RewardIcon(canRedeem: canRedeem),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reward.rewardDescription.isEmpty
                      ? 'مكافأة ولاء'
                      : reward.rewardDescription,
                  style: AppTypography.titleMedium.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RedeemBadge(canRedeem: canRedeem),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _RewardInfoTile(
                  icon: Icons.stars_outlined,
                  label: 'النقاط المطلوبة',
                  value: '${reward.pointsThreshold}',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RewardInfoTile(
                  icon: Icons.local_offer_outlined,
                  label: 'قيمة الخصم',
                  value: reward.discountValue,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ActiveStatus(isActive: reward.isActive),
        ],
      ),
    );
  }
}

class _RewardIcon extends StatelessWidget {
  final bool canRedeem;

  const _RewardIcon({required this.canRedeem});

  @override
  Widget build(BuildContext context) {
    final color = canRedeem ? AppColors.success : AppColors.primary;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.card_giftcard_outlined, color: color),
    );
  }
}

class _RedeemBadge extends StatelessWidget {
  final bool canRedeem;

  const _RedeemBadge({required this.canRedeem});

  @override
  Widget build(BuildContext context) {
    final color = canRedeem ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        canRedeem ? 'متاحة للاستبدال' : 'غير متاحة حالياً',
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RewardInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.appMutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveStatus extends StatelessWidget {
  final bool isActive;

  const _ActiveStatus({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.grey;

    return Row(
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 8),
        Text(
          isActive ? 'المكافأة فعالة' : 'المكافأة غير فعالة',
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyRewardsView extends StatelessWidget {
  const _EmptyRewardsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.card_giftcard_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'لا توجد مكافآت حالياً',
            style: AppTypography.titleMedium.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عند توفر مكافآت ولاء جديدة ستظهر هنا مباشرة.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: context.appMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

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
