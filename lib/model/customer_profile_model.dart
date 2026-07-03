class CustomerProfileModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final int loyaltyPoints;
  final double totalSpent;

  const CustomerProfileModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.loyaltyPoints,
    required this.totalSpent,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CustomerProfileModel(
      fullName: _toText(json['fullName']),
      email: _toText(json['email']),
      phoneNumber: _toText(json['phoneNumber']),
      address: _toText(customer['address'], fallback: _toText(json['address'])),
      loyaltyPoints: _toInt(customer['loyaltyPoints'] ?? json['loyaltyPoints']),
      totalSpent: _toDouble(customer['totalSpent'] ?? json['totalSpent']),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  CustomerProfileModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    int? loyaltyPoints,
    double? totalSpent,
  }) {
    return CustomerProfileModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalSpent: totalSpent ?? this.totalSpent,
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

  static String _toText(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return fallback;
    if (text.toLowerCase() == 'null' || text.toLowerCase() == 'undefined') {
      return fallback;
    }
    return text;
  }
}
