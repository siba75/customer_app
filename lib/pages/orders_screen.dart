// lib/screens/orders/orders_screen.dart
import 'package:customer_app/core/theem/app_typography.dart';
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/cubit_folder/order_cubit.dart';
import 'package:customer_app/cubit_folder/order_state.dart';
import 'package:customer_app/model/order_model.dart';
import 'package:customer_app/widgets/order_widgets/empty_state.dart';
import 'package:customer_app/widgets/order_widgets/order_card.dart';
import 'package:customer_app/widgets/order_widgets/order_details_sheet.dart';
import 'package:customer_app/widgets/order_widgets/order_tracking_dialog.dart';
import 'package:customer_app/widgets/order_widgets/orders_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final String _selectedFilter = 'all';

  List<Order> _filteredOrders(List<Order> orders) {
    switch (_selectedFilter) {
      case 'pending':
        return orders.where((order) => order.isPending).toList();
      case 'preparing':
      case 'processing':
        return orders.where((order) => order.isProcessing).toList();
      case 'out_for_delivery':
        return orders.where((order) => order.isOutForDelivery).toList();
      case 'delivered':
        return orders.where((order) => order.isDelivered).toList();
      default:
        return orders;
    }
  }

  Future<void> _refreshOrders() {
    return context.read<OrderCubit>().loadOrders();
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }

  Future<void> _confirmCancelOrder(Order order) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إلغاء الطلب'),
        content: Text('هل أنت متأكد من إلغاء الطلب ${order.orderNumber}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('تراجع', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'إلغاء الطلب',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !mounted) return;

    try {
      await context.read<OrderCubit>().cancelOrder(order);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الطلب بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        title: const Text('طلباتي'),
        actions: [
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'تحديث الطلبات',
                onPressed: state.isLoading ? null : _refreshOrders,
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
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          final filteredOrders = _filteredOrders(state.orders);

          if (state.isLoading && state.orders.isEmpty) {
            return const OrdersLoadingSkeleton();
          }

          if (state.errorMessage != null && state.orders.isEmpty) {
            return _OrdersMessage(
              icon: Icons.error_outline,
              message: state.errorMessage!,
              onRetry: _refreshOrders,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: context.appSurface,
            onRefresh: _refreshOrders,
            child: filteredOrders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [OrderEmptyState()],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: filteredOrders[index],
                        onTap: () => _showOrderDetails(filteredOrders[index]),
                        onTrack: () => _showTrackDialog(filteredOrders[index]),
                        onCancel: () =>
                            _confirmCancelOrder(filteredOrders[index]),
                        isCancelling:
                            state.cancellingOrderId?.toString() ==
                            filteredOrders[index].id,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void _showTrackDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderTrackingDialog(order: order),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const _OrdersMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: context.appMutedText,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
