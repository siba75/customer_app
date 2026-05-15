// lib/models/order_model.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String image;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
  });

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'price': price, 'image': image};
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String date;
  final String dateFormatted;
  final String time;
  final double total;
  final double subtotal;
  final double delivery;
  final double discount;
  final String status;
  final String statusText;
  final Color statusColor;
  final List<OrderItem> items;
  final String address;
  final String paymentMethod;
  final String paymentText;
  final String? trackingNumber;
  final String? deliveredAt;
  final String? estimatedDelivery;
  final String? cancelledReason;

  Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.dateFormatted,
    required this.time,
    required this.total,
    required this.subtotal,
    required this.delivery,
    required this.discount,
    required this.status,
    required this.statusText,
    required this.statusColor,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.paymentText,
    this.trackingNumber,
    this.deliveredAt,
    this.estimatedDelivery,
    this.cancelledReason,
  });

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get hasTracking => trackingNumber != null;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      date: json['date'],
      dateFormatted: json['dateFormatted'],
      time: json['time'],
      total: json['total'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      delivery: json['delivery'].toDouble(),
      discount: json['discount'].toDouble(),
      status: json['status'],
      statusText: json['status_text'],
      statusColor: _getStatusColor(json['status']),
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      address: json['address'],
      paymentMethod: json['payment_method'],
      paymentText: json['payment_text'],
      trackingNumber: json['tracking_number'],
      deliveredAt: json['delivered_at'],
      estimatedDelivery: json['estimated_delivery'],
      cancelledReason: json['cancelled_reason'],
    );
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'processing':
        return AppColors.secondary;
      case 'pending':
        return AppColors.primaryDark;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }
}
