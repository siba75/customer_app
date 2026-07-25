// lib/models/order_model.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String? image;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : <String, dynamic>{};

    return OrderItem(
      name: product['name']?.toString() ?? json['name']?.toString() ?? '',
      quantity: _toInt(json['quantity']),
      price: _toDouble(json['unitPrice'] ?? json['price']),
      image: json['image']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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
  final int loyaltyPointsUsed;
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
  final String? appliedDiscountName;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.dateFormatted,
    required this.time,
    required this.total,
    required this.subtotal,
    required this.delivery,
    required this.discount,
    required this.loyaltyPointsUsed,
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
    this.appliedDiscountName,
  });

  bool get isPending => status == 'pending';
  bool get isPreparing => status == 'preparing';
  bool get isProcessing => isPreparing;
  bool get isOutForDelivery => status == 'out_for_delivery';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isTrackingFinished => isDelivered || isCancelled;
  bool get canCancel => isPending || isPreparing;
  bool get hasTracking => trackingNumber != null && trackingNumber!.isNotEmpty;

  factory Order.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final status = (json['status']?.toString() ?? '').toLowerCase();
    final appliedDiscount = json['appliedDiscount'] is Map<String, dynamic>
        ? json['appliedDiscount'] as Map<String, dynamic>
        : <String, dynamic>{};

    final subtotal = _toDouble(json['subtotal']);
    final delivery = _toDouble(json['deliveryFee'] ?? json['delivery']);
    final discount = _toDouble(json['discountAmount']);
    final total = _toDouble(json['total']);

    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: 'ORD-${json['id'] ?? ''}',
      date: _dateValue(createdAt),
      dateFormatted: _dateFormatted(createdAt),
      time: _timeFormatted(createdAt),
      total: total > 0
          ? total
          : (subtotal + delivery - discount)
                .clamp(0, double.infinity)
                .toDouble(),
      subtotal: subtotal,
      delivery: delivery,
      discount: discount,
      loyaltyPointsUsed: _toInt(json['loyaltyPointsUsed']),
      status: status,
      statusText: _statusText(status),
      statusColor: _getStatusColor(status),
      items: json['items'] is List
          ? (json['items'] as List)
                .whereType<Map<String, dynamic>>()
                .map(OrderItem.fromJson)
                .toList()
          : const [],
      address: json['deliveryAddress']?.toString() ?? 'العنوان الافتراضي',
      paymentMethod: 'cod',
      paymentText: 'الدفع عند الاستلام',
      appliedDiscountName: appliedDiscount['name']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _dateValue(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  static String _dateFormatted(DateTime? date) {
    if (date == null) return 'غير معروف';
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  static String _timeFormatted(DateTime? date) {
    if (date == null) return '';
    return '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _statusText(String status) {
    switch (status) {
      case 'delivered':
        return 'تم التوصيل';
      case 'preparing':
        return 'قيد التحضير';
      case 'out_for_delivery':
        return 'خرج للتوصيل';
      case 'pending':
        return 'قيد الانتظار';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'preparing':
        return AppColors.secondary;
      case 'out_for_delivery':
        return AppColors.primaryLight;
      case 'pending':
        return AppColors.primaryDark;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }
}
