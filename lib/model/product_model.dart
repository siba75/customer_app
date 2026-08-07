import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/model/discount_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String barcode;
  final double sellingPrice;
  final int quantityInStock;
  final int minQuantity;
  final int? categoryId;
  final int? supplierId;
  final String? categoryName;
  final String? supplierName;
  final String? description;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.sellingPrice,
    required this.quantityInStock,
    required this.minQuantity,
    this.categoryId,
    this.supplierId,
    this.categoryName,
    this.supplierName,
    this.description,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : <String, dynamic>{};
    final supplier = json['supplier'] is Map<String, dynamic>
        ? json['supplier'] as Map<String, dynamic>
        : <String, dynamic>{};
    final photos = json['productPhotos'] is List
        ? json['productPhotos'] as List
        : const [];

    return ProductModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      sellingPrice: _toDouble(json['sellingPrice'] ?? json['price']),
      quantityInStock: _toInt(json['quantityInStock']),
      minQuantity: _toInt(json['minQuantity']),
      categoryId: _toNullableInt(json['categoryId'] ?? category['id']),
      supplierId: _toNullableInt(json['supplierId']),
      categoryName: category['name']?.toString(),
      supplierName: supplier['fullName']?.toString(),
      description: json['description']?.toString(),
      imageUrl:
          json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          _readFirstPhotoUrl(photos),
    );
  }

  ProductModel copyWith({
    String? imageUrl,
    int? categoryId,
    String? categoryName,
  }) {
    return ProductModel(
      id: id,
      name: name,
      barcode: barcode,
      sellingPrice: sellingPrice,
      quantityInStock: quantityInStock,
      minQuantity: minQuantity,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId,
      categoryName: categoryName ?? this.categoryName,
      supplierName: supplierName,
      description: description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toUiMap({
    String? categoryName,
    List<DiscountModel> discounts = const [],
  }) {
    final resolvedImage = _absoluteImageUrl(imageUrl);
    final discount = _bestDiscount(discounts);
    final originalPrice = _roundMoney(sellingPrice);
    final hasDiscount = discount != null;

    return {
      'id': id.toString(),
      'name': name,
      'barcode': barcode,
      'price': originalPrice,
      'old_price': null,
      'discount_id': hasDiscount ? discount.id : null,
      'discount_name': hasDiscount ? discount.name : null,
      'discount_scope': hasDiscount ? discount.scope : null,
      'discount_type': hasDiscount ? discount.type : null,
      'discount_value': hasDiscount ? discount.value : null,
      'discount_label': hasDiscount ? _discountLabel(discount) : null,
      'unit': 'قطعة',
      'image': resolvedImage,
      'has_image': resolvedImage != null,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'category': categoryName ?? this.categoryName,
      'supplier': supplierName,
      'description':
          description ??
          (barcode.isEmpty
              ? 'لا يوجد وصف متاح لهذا المنتج.'
              : 'باركود: $barcode'),
      'quantity_in_stock': quantityInStock,
      'min_quantity': minQuantity,
      'in_stock': quantityInStock > 0,
    };
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

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _readFirstPhotoUrl(List<dynamic> photos) {
    for (final photo in photos) {
      if (photo is! Map<String, dynamic>) continue;
      final storedFile = photo['storedFile'] is Map<String, dynamic>
          ? photo['storedFile'] as Map<String, dynamic>
          : <String, dynamic>{};
      final storedFileId =
          photo['storedFileId']?.toString() ?? storedFile['id']?.toString();
      if (storedFileId != null && storedFileId.isNotEmpty) {
        return '${ApiConfig.productPhotosEndpoint}/download/$storedFileId';
      }
    }

    return null;
  }

  static String? _absoluteImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiConfig.baseUrl}$url';
    return '${ApiConfig.baseUrl}/$url';
  }

  DiscountModel? _bestDiscount(List<DiscountModel> discounts) {
    DiscountModel? bestDiscount;
    var bestAmount = 0.0;

    for (final discount in discounts) {
      if (!_discountApplies(discount)) continue;

      final discountAmount = sellingPrice - _discountedPrice(sellingPrice, discount);
      if (discountAmount > bestAmount) {
        bestAmount = discountAmount;
        bestDiscount = discount;
      }
    }

    return bestDiscount;
  }

  bool _discountApplies(DiscountModel discount) {
    if (!discount.isActive) return false;

    if (discount.isProductScope) {
      return discount.productId == id;
    }

    if (discount.isCategoryScope) {
      return categoryId != null && discount.categoryId == categoryId;
    }

    return false;
  }

  double _discountedPrice(double price, DiscountModel discount) {
    if (discount.isPercentage) {
      var discountAmount = price * discount.value / 100;
      if (discount.maxInvoiceValue > 0 &&
          discountAmount > discount.maxInvoiceValue) {
        discountAmount = discount.maxInvoiceValue;
      }
      return (price - discountAmount).clamp(0, price).toDouble();
    }

    if (discount.isFixedAmount) {
      return (price - discount.value).clamp(0, price).toDouble();
    }

    return price;
  }

  double _roundMoney(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  String _discountLabel(DiscountModel discount) {
    final value = _formatDiscountValue(discount.value);
    if (discount.isPercentage) return '$value%';
    if (discount.isFixedAmount) return '$value ل.س';
    return 'خصم متاح';
  }

  String _formatDiscountValue(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}
