// lib/widgets/orders/order_filter_chips.dart
import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class OrderFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const OrderFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<Map<String, dynamic>> _filters = const [
    {'id': 'all', 'label': 'الكل', 'icon': Icons.list_alt},
    {'id': 'pending', 'label': 'قيد الانتظار', 'icon': Icons.pending_actions},
    {'id': 'preparing', 'label': 'قيد التحضير', 'icon': Icons.restaurant_menu},
    {
      'id': 'out_for_delivery',
      'label': 'خرج للتوصيل',
      'icon': Icons.local_shipping_outlined,
    },
    {'id': 'delivered', 'label': 'تم التوصيل', 'icon': Icons.delivery_dining},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = selectedFilter == filter['id'];
          return FilterChip(
            label: Text(filter['label'] as String),
            selected: isSelected,
            onSelected: (_) => onFilterChanged(filter['id'] as String),
            avatar: Icon(filter['icon'] as IconData, size: 18),
            selectedColor: AppColors.primarySoft,
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.greyDark,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.greyLight,
              ),
            ),
          );
        },
      ),
    );
  }
}
