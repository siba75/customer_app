class DiscountModel {
  final int id;
  final String name;
  final String type;
  final double value;
  final String scope;
  final double maxInvoiceValue;
  final int? maxUses;
  final int usedCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.scope,
    required this.maxInvoiceValue,
    required this.maxUses,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      value: _toDouble(json['value']),
      scope: json['scope']?.toString() ?? '',
      maxInvoiceValue: _toDouble(json['maxInvoiceValue']),
      maxUses: _toNullableInt(json['maxUses']),
      usedCount: _toInt(json['usedCount']),
      startDate: _toDate(json['startDate']),
      endDate: _toDate(json['endDate']),
      isActive: json['isActive'] == true,
    );
  }

  bool get isPercentage => type.toUpperCase() == 'PERCENTAGE';
  bool get isFixedAmount => type.toUpperCase() == 'FIXED_AMOUNT';
  bool get isGlobalScope => scope.toUpperCase() == 'GLOBAL';
  bool get isProductScope => scope.toUpperCase() == 'PRODUCT';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
