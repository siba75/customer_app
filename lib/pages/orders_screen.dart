// lib/screens/orders/orders_screen.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/theem/theme_colors.dart';
import 'package:customer_app/model/order_model.dart';
import 'package:customer_app/widgets/order_widgets/empty_state.dart';
import 'package:customer_app/widgets/order_widgets/mach_Order.dart';
import 'package:customer_app/widgets/order_widgets/order_card.dart';
import 'package:customer_app/widgets/order_widgets/order_details_sheet.dart';
import 'package:customer_app/widgets/order_widgets/order_tracking_dialog.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'all';

  List<Order> get _filteredOrders {
    switch (_selectedFilter) {
      case 'pending':
        return mockOrders.where((order) => order.isPending).toList();
      case 'processing':
        return mockOrders.where((order) => order.isProcessing).toList();
      case 'delivered':
        return mockOrders.where((order) => order.isDelivered).toList();
      default:
        return mockOrders;
    }
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(title: Text('طلباتي')),
      body: filteredOrders.isEmpty
          ? const OrderEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return OrderCard(
                  order: filteredOrders[index],
                  onTap: () => _showOrderDetails(filteredOrders[index]),
                  onTrack: () => _showTrackDialog(filteredOrders[index]),
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
