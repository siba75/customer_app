class LoyaltyPolicyModel {
  final double pointsPerCurrency;
  final double currencyPerPoint;

  const LoyaltyPolicyModel({
    required this.pointsPerCurrency,
    required this.currencyPerPoint,
  });

  const LoyaltyPolicyModel.empty()
    : pointsPerCurrency = 0,
      currencyPerPoint = 0;

  factory LoyaltyPolicyModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyPolicyModel(
      pointsPerCurrency: _toDouble(json['pointsPerCurrency']),
      currencyPerPoint: _toDouble(json['currencyPerPoint']),
    );
  }

  bool get isConfigured => pointsPerCurrency > 0 && currencyPerPoint > 0;

  double discountForPoints(int points) {
    if (points <= 0 || currencyPerPoint <= 0) return 0;
    return points * currencyPerPoint;
  }

  int estimatedPointsForAmount(double amount) {
    if (amount <= 0 || pointsPerCurrency <= 0) return 0;
    return (amount * pointsPerCurrency).floor();
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
