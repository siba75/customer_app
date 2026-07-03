class LoyaltyRewardModel {
  final String id;
  final int pointsThreshold;
  final String rewardDescription;
  final String discountValue;
  final bool isActive;
  final bool canRedeem;

  const LoyaltyRewardModel({
    required this.id,
    required this.pointsThreshold,
    required this.rewardDescription,
    required this.discountValue,
    required this.isActive,
    required this.canRedeem,
  });

  factory LoyaltyRewardModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyRewardModel(
      id: json['id']?.toString() ?? '',
      pointsThreshold: _toInt(json['pointsThreshold']),
      rewardDescription: json['rewardDescription']?.toString() ?? '',
      discountValue: json['discountValue']?.toString() ?? '0',
      isActive: _toBool(json['isActive']),
      canRedeem: _toBool(json['canRedeem']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1';
  }
}
