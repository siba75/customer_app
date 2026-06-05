class DiscountCalculationModel {
  final int discountId;
  final String discountName;
  final String type;
  final String scope;
  final double subtotal;
  final double discountAmount;
  final double total;

  const DiscountCalculationModel({
    required this.discountId,
    required this.discountName,
    required this.type,
    required this.scope,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
  });

  factory DiscountCalculationModel.fromJson(Map<String, dynamic> json) {
    return DiscountCalculationModel(
      discountId: _toInt(json['discountId']),
      discountName: json['discountName']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      scope: json['scope']?.toString() ?? '',
      subtotal: _toDouble(json['subtotal']),
      discountAmount: _toDouble(json['discountAmount']),
      total: _toDouble(json['total']),
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
