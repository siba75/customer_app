class CartItem {
  final String id;
  final String name;
  final String unit;
  final double price;
  final double? oldPrice;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    this.oldPrice,
  });

  double get total => price * quantity;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      unit: unit,
      price: price,
      oldPrice: oldPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

const List<CartItem> mockCartItems = [
  CartItem(
    id: '1',
    name: 'طماطم طازجة',
    unit: 'كجم',
    price: 5.50,
    oldPrice: 7.00,
    quantity: 2,
  ),
  CartItem(id: '2', name: 'خيار بلدي', unit: 'كجم', price: 3.00, quantity: 1),
  CartItem(
    id: '3',
    name: 'عصير برتقال طبيعي',
    unit: 'لتر',
    price: 12.00,
    oldPrice: 15.00,
    quantity: 1,
  ),
];
