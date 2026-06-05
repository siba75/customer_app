class CartItem {
  final String id;
  final String name;
  final String unit;
  final double price;
  final double? oldPrice;
  final int quantity;
  final String? imageUrl;
  final int? productId;
  final int? categoryId;
  final int? discountId;
  final String? discountName;
  final String? discountScope;
  final int? maxQuantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    this.oldPrice,
    this.imageUrl,
    this.productId,
    this.categoryId,
    this.discountId,
    this.discountName,
    this.discountScope,
    this.maxQuantity,
  });

  double get total => price * quantity;

  double get originalPrice => oldPrice ?? price;

  double get originalTotal => originalPrice * quantity;

  double get lineDiscount {
    if (!hasDiscount) return 0;
    return (oldPrice! - price) * quantity;
  }

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  factory CartItem.fromProductMap(
    Map<String, dynamic> product, {
    int quantity = 1,
  }) {
    final id = product['id']?.toString() ?? '';
    final productPrice = _toDouble(product['price']);
    final productOldPrice = product['old_price'] == null
        ? null
        : _toDouble(product['old_price']);
    final discountScope = product['discount_scope']?.toString().toUpperCase();

    return CartItem(
      id: id,
      productId: int.tryParse(id),
      categoryId: _toNullableInt(product['category_id']),
      discountId: _toNullableInt(product['discount_id']),
      discountName: product['discount_name']?.toString(),
      discountScope: discountScope,
      maxQuantity: _toNullableInt(
        product['quantity_in_stock'] ?? product['quantityInStock'],
      ),
      name: product['name']?.toString() ?? '',
      unit: product['unit']?.toString() ?? 'قطعة',
      price: productPrice,
      oldPrice: productOldPrice,
      quantity: quantity,
      imageUrl: product['image']?.toString(),
    );
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      unit: unit,
      price: price,
      oldPrice: oldPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      productId: productId,
      categoryId: categoryId,
      discountId: discountId,
      discountName: discountName,
      discountScope: discountScope,
      maxQuantity: maxQuantity,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
