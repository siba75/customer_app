class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static bool get isLocalhost {
    final uri = Uri.tryParse(baseUrl);
    final host = uri?.host.toLowerCase() ?? '';
    return host == 'localhost' || host == '127.0.0.1';
  }

  static const String signupEndpoint = '/authentication/customer/signup';
  static const String signinEndpoint = '/authentication/customer/signin';
  static const String verifyEndpoint = '/authentication/verify';
  static const String customerMeEndpoint = '/customer/me';
  static const String adsEndpoint = '/ads';
  static const String categoriesEndpoint = '/category';
  static const String productsEndpoint = '/product';
  static const String productPhotosEndpoint = '/product-photo';
  static const String activeDiscountsEndpoint = '/discount/active';
  static const String bestDiscountEndpoint = '/discount/best';
  static const String calculateDiscountEndpoint = '/discount/calculate';
  static const String ordersEndpoint = '/orders';
  static const String customerOrdersEndpoint = '/orders/customer';
  static const String loyaltyRewardsAvailableEndpoint =
      '/loyalty-rewards/available';
  static const String loyaltyRewardsEndpoint = '/loyalty-rewards';
  static const String notificationsMeEndpoint = '/notifications/me';
  static const String notificationsEndpoint = '/notifications';

  // static const String jwtTokenKey = 'JWT_TOKEN';
}
