import 'package:customer_app/core/theem/coler.dart';
import 'package:customer_app/core/const/config.dart';
import 'package:flutter/material.dart';

class AdModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? linkUrl;
  final String placement;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  const AdModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.linkUrl,
    required this.placement,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: _absoluteImageUrl(_nullableString(json['imageUrl'])),
      linkUrl: _nullableString(json['linkUrl']),
      placement: json['placement']?.toString().toUpperCase() ?? '',
      isActive: json['isActive'] == true,
      startDate: _toDate(json['startDate']),
      endDate: _toDate(json['endDate']),
    );
  }

  bool get isHomePlacement => placement == 'HOME';

  bool get isCurrentlyVisible {
    if (!isActive) return false;

    final now = DateTime.now().toUtc();
    if (startDate != null && now.isBefore(startDate!.toUtc())) return false;
    if (endDate != null && now.isAfter(endDate!.toUtc())) return false;

    return true;
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get subtitle => description;

  String get badge => isActive ? 'إعلان فعال' : 'إعلان غير فعال';

  String get placementLabel {
    switch (placement) {
      case 'HOME':
        return 'الرئيسية';
      case 'CHECKOUT':
        return 'إتمام الطلب';
      case 'SIDEBAR':
        return 'الشريط الجانبي';
      default:
        return placement.isEmpty ? 'عام' : placement;
    }
  }

  String get dateRange {
    final start = _formatDate(startDate);
    final end = endDate == null ? 'مستمر' : _formatDate(endDate);

    if (start == null && endDate == null) return 'بدون مدة محددة';
    if (start == null) return 'حتى $end';
    return 'من $start إلى $end';
  }

  String get actionText =>
      linkUrl == null || linkUrl!.isEmpty ? 'اكتشف العرض' : 'عرض التفاصيل';

  IconData get icon {
    switch (placement) {
      case 'CHECKOUT':
        return Icons.local_shipping_outlined;
      case 'SIDEBAR':
        return Icons.new_releases_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  List<Color> get colors {
    switch (placement) {
      case 'CHECKOUT':
        return [AppColors.secondary, AppColors.secondaryLight];
      case 'SIDEBAR':
        return [AppColors.success, const Color(0xFF0F766E)];
      default:
        return [AppColors.primary, AppColors.primaryDark];
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _formatDate(DateTime? value) {
    if (value == null) return null;
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  static String? _absoluteImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiConfig.baseUrl}$url';
    return '${ApiConfig.baseUrl}/$url';
  }
}
