import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class PromoBannerModel {
  final String badge;
  final String title;
  final String subtitle;
  final String actionText;
  final IconData icon;
  final List<Color> colors;

  const PromoBannerModel({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.icon,
    required this.colors,
  });
}

const List<PromoBannerModel> mockPromoBanners = [
  PromoBannerModel(
    badge: 'عرض محدود',
    title: 'خصم يصل إلى 40%',
    subtitle: 'على الخضروات والفواكه الطازجة',
    actionText: 'تسوق الآن',
    icon: Icons.eco_outlined,
    colors: [AppColors.primary, AppColors.primaryDark],
  ),
  PromoBannerModel(
    badge: 'توصيل أسرع',
    title: 'توصيل مجاني',
    subtitle: 'للطلبات التي تتجاوز 75 ل.س اليوم',
    actionText: 'ابدأ الطلب',
    icon: Icons.delivery_dining_outlined,
    colors: [AppColors.secondary, AppColors.secondaryLight],
  ),
  PromoBannerModel(
    badge: 'اختياراتك اليومية',
    title: 'سلة طازجة',
    subtitle: 'منتجات مختارة بعناية لعائلتك',
    actionText: 'اكتشف المزيد',
    icon: Icons.shopping_basket_outlined,
    colors: [AppColors.success, Color(0xFF0F766E)],
  ),
];
