import 'package:customer_app/model/product_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String description;
  final int productsCount;
  final List<ProductModel> products;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.productsCount,
    this.products = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] is Map<String, dynamic>
        ? json['_count'] as Map<String, dynamic>
        : <String, dynamic>{};
    final products = json['products'] is List
        ? (json['products'] as List)
              .whereType<Map<String, dynamic>>()
              .map(ProductModel.fromJson)
              .toList()
        : <ProductModel>[];

    return CategoryModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      productsCount: _toInt(count['products']),
      products: products,
    );
  }

  Map<String, dynamic> toUiMap() {
    return {
      'id': id.toString(),
      'name': name,
      'description': description,
      'products_count': productsCount,
      'icon': iconName,
    };
  }

  String get iconName {
    final normalizedName = name.trim().toLowerCase();

    for (final rule in _iconRules) {
      if (rule.matches(normalizedName)) return rule.iconName;
    }

    return 'category';
  }

  static const List<_CategoryIconRule> _iconRules = [
    _CategoryIconRule(
      iconName: 'devices',
      keywords: [
        'electronic',
        'electronics',
        'device',
        'devices',
        'كهرب',
        'إلكترون',
      ],
    ),
    _CategoryIconRule(
      iconName: 'eco',
      keywords: ['vegetable', 'vegetables', 'veggies', 'خضار', 'خضروات'],
    ),
    _CategoryIconRule(
      iconName: 'apple',
      keywords: ['fruit', 'fruits', 'فاكه', 'فواكه'],
    ),
    _CategoryIconRule(
      iconName: 'local_drink',
      keywords: [
        'drink',
        'drinks',
        'beverage',
        'juice',
        'مشروب',
        'مشروبات',
        'عصير',
      ],
    ),
    _CategoryIconRule(
      iconName: 'bakery',
      keywords: ['bakery', 'bread', 'خبز', 'مخبز', 'مخبوزات'],
    ),
    _CategoryIconRule(
      iconName: 'cake',
      keywords: ['sweet', 'sweets', 'dessert', 'cake', 'حلويات', 'حلوى', 'كيك'],
    ),
    _CategoryIconRule(
      iconName: 'egg',
      keywords: [
        'dairy',
        'milk',
        'cheese',
        'لبن',
        'حليب',
        'ألبان',
        'البان',
        'جبن',
      ],
    ),
    _CategoryIconRule(
      iconName: 'restaurant',
      keywords: [
        'meat',
        'chicken',
        'fish',
        'لحم',
        'لحوم',
        'دجاج',
        'سمك',
        'أسماك',
      ],
    ),
    _CategoryIconRule(
      iconName: 'kitchen',
      keywords: ['canned', 'can', 'kitchen', 'معلب', 'معلبات', 'مطبخ'],
    ),
    _CategoryIconRule(
      iconName: 'grain',
      keywords: ['grain', 'rice', 'pasta', 'حبوب', 'أرز', 'ارز', 'معكرونة'],
    ),
    _CategoryIconRule(
      iconName: 'spice',
      keywords: ['spice', 'spices', 'بهار', 'بهارات', 'توابل'],
    ),
    _CategoryIconRule(
      iconName: 'frozen',
      keywords: ['frozen', 'ice', 'مجمد', 'مجمدات', 'مثلج'],
    ),
    _CategoryIconRule(
      iconName: 'cleaning',
      keywords: ['clean', 'cleaning', 'detergent', 'تنظيف', 'منظف', 'منظفات'],
    ),
    _CategoryIconRule(
      iconName: 'pharmacy',
      keywords: ['pharmacy', 'medicine', 'health', 'صيدلية', 'دواء', 'صحة'],
    ),
    _CategoryIconRule(
      iconName: 'checkroom',
      keywords: ['clothes', 'clothing', 'fashion', 'ملابس', 'أزياء', 'ازياء'],
    ),
    _CategoryIconRule(
      iconName: 'toys',
      keywords: ['toy', 'toys', 'game', 'ألعاب', 'العاب', 'لعبة'],
    ),
    _CategoryIconRule(
      iconName: 'book',
      keywords: ['book', 'books', 'stationery', 'كتاب', 'كتب', 'قرطاسية'],
    ),
  ];

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _CategoryIconRule {
  final String iconName;
  final List<String> keywords;

  const _CategoryIconRule({required this.iconName, required this.keywords});

  bool matches(String categoryName) {
    return keywords.any(categoryName.contains);
  }
}
