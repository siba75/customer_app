class LoyaltyRewardModel {
  final String id;
  final String name;
  final String description;
  final int pointsThreshold;
  final String rewardDescription;
  final int pointsCost;
  final String discountType;
  final String discountValue;
  final int? maxUses;
  final int? validityDays;
  final bool isActive;
  final bool canRedeem;

  const LoyaltyRewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsThreshold,
    required this.rewardDescription,
    required this.pointsCost,
    required this.discountType,
    required this.discountValue,
    this.maxUses,
    this.validityDays,
    required this.isActive,
    required this.canRedeem,
  });

  factory LoyaltyRewardModel.fromJson(Map<String, dynamic> json) {
    final pointsCost = _toInt(json['pointsCost'] ?? json['pointsThreshold']);
    final description =
        json['description']?.toString() ??
        json['rewardDescription']?.toString() ??
        '';
    final discountType = json['discountType']?.toString().toUpperCase() ?? '';

    return LoyaltyRewardModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'مكافأة ولاء',
      description: description,
      pointsThreshold: pointsCost,
      rewardDescription: description,
      pointsCost: pointsCost,
      discountType: discountType,
      discountValue: json['discountValue']?.toString() ?? '0',
      maxUses: _toNullableInt(json['maxUses']),
      validityDays: _toNullableInt(json['validityDays']),
      isActive: _toBool(json['isActive']),
      canRedeem: json.containsKey('canRedeem')
          ? _toBool(json['canRedeem'])
          : true,
    );
  }

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

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1';
  }

  String get displayTitle => name.isEmpty ? 'مكافأة ولاء' : name;

  String get displayDescription {
    if (description.isNotEmpty) return description;
    if (rewardDescription.isNotEmpty) return rewardDescription;
    return 'استبدل نقاطك واحصل على خصم.';
  }

  String get displayDiscountValue {
    final value = _trimMoney(discountValue);
    if (discountType == 'PERCENTAGE') return '$value%';
    if (discountType == 'FIXED_AMOUNT') return '$value ل.س';
    return value;
  }

  String get displayValidity {
    if (validityDays == null || validityDays! <= 0) return 'بدون مدة محددة';
    return '$validityDays أيام';
  }

  static String _trimMoney(String value) {
    final number = double.tryParse(value);
    if (number == null) return value;
    if (number == number.roundToDouble()) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}

class LoyaltyRedemptionModel {
  final String id;
  final int customerId;
  final String offerId;
  final int discountId;
  final int pointsSpent;
  final DateTime? redeemedAt;
  final LoyaltyRewardModel? offer;

  const LoyaltyRedemptionModel({
    required this.id,
    required this.customerId,
    required this.offerId,
    required this.discountId,
    required this.pointsSpent,
    required this.redeemedAt,
    this.offer,
  });

  factory LoyaltyRedemptionModel.fromJson(Map<String, dynamic> json) {
    final offer = json['offer'] is Map<String, dynamic>
        ? LoyaltyRewardModel.fromJson(json['offer'] as Map<String, dynamic>)
        : null;

    return LoyaltyRedemptionModel(
      id: json['id']?.toString() ?? '',
      customerId: LoyaltyRewardModel._toInt(json['customerId']),
      offerId: json['offerId']?.toString() ?? '',
      discountId: LoyaltyRewardModel._toInt(json['discountId']),
      pointsSpent: LoyaltyRewardModel._toInt(json['pointsSpent']),
      redeemedAt: DateTime.tryParse(json['redeemedAt']?.toString() ?? ''),
      offer: offer,
    );
  }
}
