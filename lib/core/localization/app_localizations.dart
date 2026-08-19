import 'package:customer_app/core/localization/language_controller.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations._();

  static const List<Locale> supportedLocales = [
    Locale(LanguageController.arabicCode, 'SA'),
    Locale(LanguageController.englishCode, 'US'),
  ];

  static TextDirection directionOf(Locale locale) {
    return locale.languageCode == LanguageController.arabicCode
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  static String translate(String text, {Locale? locale}) {
    final targetLocale = locale ?? LanguageController.locale.value;
    if (targetLocale.languageCode == LanguageController.arabicCode) {
      return text;
    }

    return _en[text] ?? text;
  }

  static String translateWithArgs(
    String text,
    Map<String, Object?> args, {
    Locale? locale,
  }) {
    var translated = translate(text, locale: locale);
    for (final entry in args.entries) {
      translated = translated.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return translated;
  }

  static String formatCurrency(num value, {Locale? locale}) {
    final targetLocale = locale ?? LanguageController.locale.value;
    final amount = value.toStringAsFixed(2);
    return targetLocale.languageCode == LanguageController.arabicCode
        ? '$amount ل.س'
        : 'SYP $amount';
  }

  static const Map<String, String> _en = {
    'Smart Store': 'Smart Store',
    'تسوق بذكاء مع أفضل العروض': 'Shop smarter with the best offers',
    'مرحباً بك': 'Welcome back',
    'مرحباً {name}': 'Hello {name}',
    'ماذا تريد أن تطلب اليوم؟': 'What would you like to order today?',
    'سجل الدخول للمتابعة': 'Sign in to continue',
    'البريد الإلكتروني': 'Email address',
    'كلمة المرور': 'Password',
    'الرجاء إدخال كلمة المرور': 'Please enter your password',
    'الرجاء إدخال البريد الإلكتروني': 'Please enter your email address',
    'الرجاء إدخال بريد إلكتروني صحيح': 'Please enter a valid email address',
    'نسيت كلمة المرور؟': 'Forgot password?',
    'نسيت كلمة المرور': 'Forgot password',
    'تم الإرسال': 'Sent',
    'تم إرسال رابط إعادة تعيين كلمة المرور إلى {email}':
        'A password reset link has been sent to {email}',
    'حسناً': 'OK',
    'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين':
        'Enter your email and we will send you a reset link',
    'إرسال رابط إعادة التعيين': 'Send reset link',
    'تسجيل الدخول': 'Sign in',
    'إنشاء حساب جديد': 'Create new account',
    'الاسم الكامل': 'Full name',
    'رقم الهاتف': 'Phone number',
    'العنوان': 'Address',
    'تأكيد كلمة المرور': 'Confirm password',
    'رقم الهوية': 'Identity number',
    'الرجاء إدخال الاسم': 'Please enter your name',
    'الرجاء إدخال البريد': 'Please enter your email',
    'الرجاء إدخال رقم الهاتف': 'Please enter your phone number',
    'الرجاء تأكيد كلمة المرور': 'Please confirm your password',
    'كلمتا المرور غير متطابقتين': 'Passwords do not match',
    'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل':
        'Password must be at least 8 characters',
    'الرجاء إدخال رقم الهوية': 'Please enter your identity number',
    'لديك حساب بالفعل؟ تسجيل الدخول': 'Already have an account? Sign in',
    'تأكيد الحساب': 'Verify account',
    'تحقق من بريدك الإلكتروني': 'Check your email',
    'أدخل رمز التحقق المرسل إلى': 'Enter the verification code sent to',
    'رمز التحقق': 'Verification code',
    'الرجاء إدخال رمز التحقق كاملًا': 'Please enter the full verification code',
    'يتكون الرمز من 8 أرقام. يمكنك لصق الرمز كاملًا هنا.':
        'The code contains 8 digits. You can paste the full code here.',
    'تأكيد الرمز': 'Verify code',
    'العودة لتسجيل الدخول': 'Back to sign in',
    'الرئيسية': 'Home',
    'السلة': 'Cart',
    'طلباتي': 'Orders',
    'حسابي': 'Account',
    'سلة التسوق': 'Shopping cart',
    'إتمام الطلب': 'Checkout',
    'السلة فارغة، الرجاء إضافة منتجات قبل تأكيد الطلب.':
        'Your cart is empty. Please add products before confirming the order.',
    'الكمية المطلوبة من {name} أكبر من المخزون المتاح ({quantity}).':
        'The requested quantity for {name} exceeds the available stock ({quantity}).',
    'الرجاء إدخال عنوان التوصيل.': 'Please enter the delivery address.',
    'تم تقديم الطلب بنجاح!': 'Order placed successfully!',
    'رقم الطلب: {number}': 'Order number: {number}',
    'شكراً لتسوقك معنا': 'Thank you for shopping with us',
    'مواصلة التسوق': 'Continue shopping',
    'عرض طلباتي': 'View my orders',
    'منتجات الطلب': 'Order products',
    'الدفع': 'Payment',
    'تأكيد': 'Confirm',
    'عنوان حسابي': 'My account address',
    'عنوان آخر': 'Another address',
    'اكتب العنوان الذي تريد استلام الطلب عليه':
        'Write the address where you want to receive the order',
    'مثال: دمشق - باب شرقي - شارع النصر':
        'Example: Damascus - Bab Sharqi - Al Nasr Street',
    'جاري حساب أفضل خصم': 'Calculating best discount',
    'الكمية: {quantity}': 'Quantity: {quantity}',
    'رصيدك: {points} نقطة': 'Your balance: {points} points',
    'اضغطي هنا لاختيار مكافأة. بعد الاستبدال تتحول النقاط إلى خصم صالح للطلب.':
        'Tap here to choose a reward. After redemption, your points become a discount valid for checkout.',
    'الدفع عند الاستلام حصرا': 'Cash on delivery only',
    'ادفع نقداً عند استلام طلبك': 'Pay cash when you receive your order',
    'تأكيد الطلب': 'Confirm order',
    'خصم جاهز مطبق على طلبك': 'Ready discount applied to your order',
    'بشو أستبدل النقاط؟': 'What can I redeem my points for?',
    '{name} وفر عليك {amount}.': '{name} saved you {amount}.',
    'اختاري عرضاً من صفحة مكافآت الولاء. بعد الاستبدال يتحول العرض إلى خصم، ويطبقه النظام هنا عندما يكون أفضل خصم متاح للطلب.':
        'Choose an offer from Loyalty Rewards. After redemption, the offer becomes a discount and the system applies it here when it is the best available discount for the order.',
    'التصنيفات': 'Categories',
    'عرض الكل': 'View all',
    'المنتجات': 'Products',
    'ابحث عن منتج...': 'Search for a product...',
    'لا توجد تصنيفات حالياً': 'No categories available right now',
    'لا توجد منتجات ضمن هذا التصنيف': 'No products in this category',
    'لا توجد نتائج مطابقة للبحث': 'No matching search results',
    'سلتك فارغة': 'Your cart is empty',
    'أضيفي منتجاتك المفضلة وارجعي لإكمال الطلب بسهولة.':
        'Add products to your cart and come back to complete your order easily.',
    'المجموع قبل الخصم': 'Subtotal before discount',
    'المجموع': 'Total',
    'الخصم': 'Discount',
    'الإجمالي للدفع': 'Total to pay',
    'المبلغ للدفع': 'Amount due',
    'حساب الخصم': 'Calculating discount',
    'لكل {unit}': 'Per {unit}',
    'المجموع: {total}': 'Total: {total}',
    '{count} منتجات جاهزة لإتمام الطلب': '{count} items ready for checkout',
    'أضف إلى السلة': 'Add to cart',
    '{price} • {quantity} منتجات': '{price} • {quantity} items',
    'قطعة': 'Piece',
    'خصم متاح': 'Discount available',
    'الوصف': 'Description',
    'لا يوجد وصف متاح لهذا المنتج.':
        'No description is available for this product.',
    'قيمة العرض: {label}، ويطبق عند إتمام الطلب إذا كان أفضل خصم متاح.':
        'Offer value: {label}. It is applied at checkout if it is the best available discount.',
    'المورد': 'Supplier',
    'الحالة': 'Status',
    'متوفر في المخزون': 'In stock',
    'غير متوفر': 'Unavailable',
    'متوفر': 'Available',
    'اختاري الكمية': 'Choose quantity',
    'المتوفر حالياً: {quantity}': 'Available now: {quantity}',
    'غير متوفر حالياً': 'Currently unavailable',
    'هذا المنتج غير متوفر حالياً': 'This product is currently unavailable',
    'لا يمكن إضافة كمية أكبر من المخزون المتاح':
        'You cannot add more than the available stock',
    'تم إضافة {quantity} × {name} إلى السلة':
        'Added {quantity} × {name} to cart',
    'الطلبات': 'Orders',
    'نقاط الولاء': 'Loyalty points',
    'إجمالي الشراء': 'Total spent',
    'تعديل المعلومات الشخصية': 'Edit personal information',
    'عنواني': 'My address',
    'لم يتم إضافة عنوان': 'No address added',
    'مكافآت الولاء': 'Loyalty rewards',
    'تحديث المكافآت': 'Refresh rewards',
    'بشو بتحب تستبدل نقاطك؟': 'What would you like to redeem?',
    'اختاري عرضاً واضحاً، أكدي الاستبدال، وبعدها يتحول العرض إلى خصم جاهز لإتمام الطلب.':
        'Choose a clear offer, confirm redemption, then it becomes a discount ready for checkout.',
    'استخدم نقاطك كخصم عند إتمام الطلب':
        'Use your points as a checkout discount',
    'كسب النقاط': 'Earn points',
    'قيمة النقطة': 'Point value',
    'غير محدد': 'Not specified',
    '{points} نقطة / ل.س': '{points} points / SYP',
    'سيتم خصم {points} نقطة من رصيدك مقابل {reward}.':
        '{points} points will be deducted from your balance for {reward}.',
    'تم تحويل {points} نقطة إلى خصم يمكن تطبيقه عند إتمام الطلب.':
        '{points} points were converted into a discount that can be applied at checkout.',
    'جاهز للاستخدام': 'Ready to use',
    'سيظهر في إتمام الطلب ويطبقه النظام عندما يكون أفضل خصم متاح':
        'It will appear at checkout and the system will apply it when it is the best available discount.',
    'العروض المتاحة حسب نقاطك': 'Offers available for your points',
    'الإشعارات': 'Notifications',
    'إعدادات التنبيهات': 'Notification settings',
    'اللغة': 'Language',
    'العربية (Arabic)': 'English',
    'الوضع الداكن': 'Dark mode',
    'تبديل مظهر التطبيق': 'Change app appearance',
    'الأسئلة الشائعة والتواصل معنا': 'FAQ and contact us',
    'الإصدار 1.0.0': 'Version 1.0.0',
    'تسجيل الخروج': 'Sign out',
    'الخروج من حسابك': 'Leave your account',
    'اختر اللغة': 'Choose language',
    'العربية': 'Arabic',
    'English': 'English',
    'هل أنت متأكد؟': 'Are you sure?',
    'إلغاء': 'Cancel',
    'خروج': 'Sign out',
    'تعديل معلومات الحساب': 'Edit account information',
    'حفظ التعديلات': 'Save changes',
    'هذا الحقل مطلوب': 'This field is required',
    'إعادة المحاولة': 'Try again',
    'تعذر تحميل بيانات الحساب': 'Could not load account data',
    'مركز الإشعارات': 'Notification center',
    'كل الإشعارات مقروءة': 'All notifications are read',
    '{unread} غير مقروء من أصل {total}': '{unread} unread out of {total}',
    'قراءة الكل': 'Mark all as read',
    'الكل': 'All',
    'غير مقروء': 'Unread',
    'مقروء': 'Read',
    'إشعار جديد': 'New notification',
    'لديك تحديث جديد في حسابك.': 'You have a new account update.',
    'الآن': 'Now',
    'أمس': 'Yesterday',
    'وقت غير محدد': 'Unknown time',
    'منذ {count} دقيقة': '{count} min ago',
    'منذ {count} ساعة': '{count} hr ago',
    'منذ {count} أيام': '{count} days ago',
    'صيغة بيانات الإشعارات غير صحيحة.': 'Notifications data format is invalid.',
    'عنوان التوصيل': 'Delivery address',
    'طريقة الدفع': 'Payment method',
    'الدفع عند الاستلام': 'Cash on delivery',
    // 'المنتجات': 'Products',
    'الخصم المطبق': 'Applied discount',
    'ملخص الأسعار': 'Price summary',
    'سعر المنتجات': 'Products price',
    'رسوم التوصيل': 'Delivery fee',
    'إجمالي المبلغ للدفع': 'Total amount to pay',
    'إغلاق': 'Close',
    'معلومات التتبع': 'Tracking information',
    'رقم التتبع: {number}': 'Tracking number: {number}',
    'موعد التوصيل المتوقع: {date}': 'Expected delivery: {date}',
    'تم التوصيل في: {date}': 'Delivered at: {date}',
    'مطبق على الطلب': 'Applied to this order',
    'قيمة الخصم غير مرجعة من الخادم لهذا الطلب.':
        'The discount amount was not returned by the server for this order.',
    'تفاصيل الطلب': 'Order details',
    'تتبع الطلب': 'Track order',
    'جاري إلغاء الطلب': 'Cancelling order',
    'إلغاء الطلب': 'Cancel order',
    'تم إلغاء الطلب بنجاح': 'Order cancelled successfully',
    'تحديث الطلبات': 'Refresh orders',
    'هل أنت متأكد من إلغاء الطلب {orderNumber}؟':
        'Are you sure you want to cancel order {orderNumber}?',
    '{count} منتجات': '{count} items',
    'خصم مطبق': 'Discount applied',
    'لا توجد طلبات': 'No orders',
    'لم تقم بإجراء أي طلبات بعد': 'You have not placed any orders yet',
    'لم تقم بإجراء أي طلبات بعد. تصفح المنتجات وأضف أول طلب لك بسهولة.':
        'You have not placed any orders yet. Browse products and place your first order easily.',
    'تسوق الآن': 'Shop now',
    'تحديث الإشعارات': 'Refresh notifications',
    'لا توجد إشعارات جديدة': 'No new notifications',
    'لا توجد إشعارات مقروءة': 'No read notifications',
    'لا توجد إشعارات': 'No notifications',
    'كل شيء مقروء ومرتب لديك.': 'Everything is read and tidy.',
    'الإشعارات التي تقرئينها ستظهر هنا.':
        'Notifications you read will appear here.',
    'كل إشعارات الطلبات والعروض وتحديثات الحساب ستظهر هنا.':
        'All order, offer, and account update notifications will appear here.',
    '{count} جديد': '{count} new',
    '99+ جديد': '99+ new',
    'للمساعدة، راجعي الأسئلة الشائعة داخل التطبيق أو تواصلي مع فريق الدعم الخاص بالمتجر.':
        'For help, review the in-app FAQs or contact the store support team.',
    'وصل {time}': 'Received {time}',
    'وصل {time} - {date}': 'Received {time} - {date}',
    'تراجع': 'Back',
    'قيد الانتظار': 'Pending',
    'قيد التحضير': 'Preparing',
    'خرج للتوصيل': 'Out for delivery',
    'تم التوصيل': 'Delivered',
    'ملغي': 'Cancelled',
    'غير معروف': 'Unknown',
    'تم استلام الطلب': 'Order received',
    'تم استلام الطلب وينتظر بدء التحضير':
        'Order received and waiting for preparation',
    'يتم تجهيز الطلب قبل التسليم': 'Your order is being prepared',
    'الطلب مع المندوب وفي طريقه إليك':
        'The order is with the courier and on its way',
    'وصل الطلب إلى العميل': 'The order has been delivered',
    'نقاطك غير كافية لاستبدال هذه المكافأة.':
        'You do not have enough points to redeem this reward.',
    'تم تحويل {points} نقطة إلى خصم جاهز للاستخدام عند إتمام الطلب.':
        '{points} points were converted to a discount ready for checkout.',
    'تأكيد استبدال النقاط': 'Confirm points redemption',
    'الخصم الناتج': 'Generated discount',
    'مدة الصلاحية': 'Validity',
    'عدد مرات الاستخدام': 'Usage limit',
    'تأكيد الاستبدال': 'Confirm redemption',
    'صار عندك خصم جاهز': 'Your discount is ready',
    'رقم الخصم': 'Discount number',
    'الاستخدام': 'Usage',
    'تمام': 'Done',
    'النقاط المطلوبة': 'Required points',
    'قيمة الخصم': 'Discount value',
    'جاري الاستبدال...': 'Redeeming...',
    'استبدال المكافأة': 'Redeem reward',
    'نقاطك غير كافية': 'Not enough points',
    'متاحة للاستبدال': 'Available to redeem',
    'غير متاحة حالياً': 'Currently unavailable',
    'المكافأة فعالة': 'Reward is active',
    'المكافأة غير فعالة': 'Reward is inactive',
    'لا توجد مكافآت حالياً': 'No rewards currently available',
    'عند توفر مكافآت ولاء جديدة ستظهر هنا مباشرة.':
        'New loyalty rewards will appear here as soon as they are available.',
    'إعلان': 'Ad',
    'فعال الآن': 'Live now',
    'غير فعال': 'Inactive',
    'مجدول': 'Scheduled',
    'منتهي': 'Expired',
    'الشريط الجانبي': 'Sidebar',
    'عام': 'General',
    'مستمر': 'Ongoing',
    'بدون مدة محددة': 'No fixed duration',
    'حتى {end}': 'Until {end}',
    'من {start} إلى {end}': 'From {start} to {end}',
    'غير متاح': 'Not available',
    'اكتشف العرض': 'Explore offer',
    'عرض التفاصيل': 'View details',
    'تفاصيل': 'Details',
    'رقم الإعلان': 'Ad number',
    'بداية الإعلان': 'Start date',
    'نهاية الإعلان': 'End date',
    'مكان الظهور': 'Placement',
    'تاريخ الإنشاء': 'Created at',
    'آخر تعديل': 'Last updated',
    'الرابط': 'Link',
    'لا يوجد رابط مرفق لهذا الإعلان.': 'No link is attached to this ad.',
    'لا يوجد وصف متاح لهذا الإعلان.':
        'No description is available for this ad.',
    'تم نسخ رابط الإعلان': 'Ad link copied',
    'موافق': 'OK',
    'حدث خطأ غير متوقع، حاول مرة أخرى.':
        'Something went wrong. Please try again.',
    'الخدمة غير متاحة حالياً، يرجى المحاولة لاحقاً.':
        'The service is currently unavailable. Please try again later.',
    'الخادم تأخر بالاستجابة، حاول مرة أخرى.':
        'The server took too long to respond. Please try again.',
    'لا تملك صلاحية الوصول لهذه البيانات.':
        'You do not have permission to access this data.',
    'هذه المكافأة لم تعد متاحة للاستبدال.':
        'This reward is no longer available for redemption.',
    'تعذر تحميل الإعلانات': 'Could not load ads',
    'تعذر تحميل الإشعارات.': 'Could not load notifications.',
    'تعذر تحميل المنتجات': 'Could not load products',
    'تعذر تحميل التصنيفات.': 'Could not load categories.',
    'انتهت الجلسة، الرجاء تسجيل الدخول مرة أخرى.':
        'Your session has expired. Please sign in again.',
    'تعذر الوصول إلى السيرفر': 'Cannot reach the server',
    'التطبيق لا يستطيع الوصول للسيرفر حالياً. تسجيل دخولك محفوظ، اضغطي إعادة المحاولة بعد تشغيل السيرفر.':
        'The app cannot reach the server right now. Your sign-in is saved; tap Retry after starting the server.',
    'عنوان السيرفر الحالي: {url}': 'Current server URL: {url}',
    'جاري التحقق...': 'Checking...',
    'تسجيل الدخول بحساب آخر': 'Sign in with another account',
    'مركز الخصومات': 'Discount center',
    'اعرفي الخصم المناسب قبل إتمام الطلب.':
        'Find the right discount before checkout.',
    'المتاحة': 'Available',
    'للمنتجات': 'Products',
    'لحسابك': 'For you',
    'حاسبة أفضل خصم': 'Best discount calculator',
    'النظام يحسب نفس نتيجة الباك قبل الطلب.':
        'The system calculates the same backend result before ordering.',
    'قيمة الطلب': 'Order value',
    'كل الطلب': 'Whole order',
    'منتج': 'Product',
    'فئة': 'Category',
    'اختاري المنتج أولاً.': 'Choose a product first.',
    'اختاري الفئة أولاً.': 'Choose a category first.',
    'احسبي أفضل خصم': 'Calculate best discount',
    'لا توجد منتجات متاحة حالياً': 'No products are available right now',
    'اختاري المنتج': 'Choose product',
    'لا توجد فئات متاحة حالياً': 'No categories are available right now',
    'اختاري الفئة': 'Choose category',
    'قبل الخصم': 'Before discount',
    'بعد الخصم': 'After discount',
    'ابحثي باسم الخصم أو المنتج أو الفئة':
        'Search by discount, product, or category',
    'عامة': 'Global',
    'منتجات': 'Products',
    'فئات': 'Categories',
    'خاصة بي': 'Mine',
    'لا توجد خصومات متاحة حالياً': 'No discounts are available right now',
    'تعذر تحميل الخصومات حالياً.': 'Could not load discounts right now.',
    'أدخلي قيمة طلب صحيحة حتى نحسب الخصم.':
        'Enter a valid order value to calculate the discount.',
    'لا يوجد خصم مناسب لهذه القيمة حالياً.':
        'No suitable discount is available for this value right now.',
    'تعذر حساب الخصم حالياً.': 'Could not calculate the discount right now.',
    'اختيار الخصم': 'Choose discount',
    'خيارات الخصم': 'Discount options',
    'جاري حساب الخصم المناسب للسلة...':
        'Calculating the right discount for the cart...',
    'تم اختيار هذا الخصم يدوياً وسيتم إرساله مع الطلب.':
        'This discount was selected manually and will be sent with the order.',
    'تم اختيار خصم يدوي. يمكنك الرجوع للأفضل تلقائياً بأي وقت.':
        'A manual discount is selected. You can return to automatic best discount anytime.',
    'النظام اختار أفضل خصم مناسب للسلة تلقائياً.':
        'The system selected the best suitable discount automatically.',
    'النظام اختار أعلى توفير مناسب للمنتجات الموجودة في السلة.':
        'The system selected the highest saving suitable for the items in your cart.',
    'اختاري خصماً أو اتركي النظام يطبق الأفضل تلقائياً.':
        'Choose a discount or let the system apply the best one automatically.',
    'يمكنك اختيار خصم يدوي أو ترك النظام يطبّق أعلى توفير تلقائياً.':
        'You can choose a manual discount or let the system apply the highest saving automatically.',
    'اسم الخصم': 'Discount name',
    'وفرتِ': 'You saved',
    'اختاري خصم': 'Choose discount',
    'أفضل خصم': 'Best discount',
    'أفضل خصم تلقائي': 'Automatic best discount',
    'خصم مختار يدوياً': 'Manually selected discount',
    '{count} خصومات': '{count} discounts',
    'لا توجد خصومات': 'No discounts',
    'لا يوجد خصم مناسب لمحتوى السلة الحالي.':
        'No discount matches the current cart contents.',
    'اتركي النظام يختار أعلى توفير مناسب للسلة.':
        'Let the system choose the highest saving for the cart.',
    'اختاري الخصم المناسب': 'Choose the right discount',
    'تم تطبيق الخصم على السلة': 'Discount applied to cart',
    'تطبيق على السلة': 'Apply to cart',
    'تعذر العثور على الخصم لتطبيقه على السلة.':
        'Could not find this discount to apply it to cart.',
    'هذا الخصم لا ينطبق على المنتجات الموجودة في السلة.':
        'This discount does not apply to the products in your cart.',
    'هذا الخصم لا يعطي تخفيضاً على السلة الحالية.':
        'This discount does not reduce the current cart.',
    'منتج محدد': 'Specific product',
    'فئة محددة': 'Specific category',
    'خصم خاص بحسابك': 'Account discount',
    'خصم منتج': 'Product discount',
    'خصم فئة': 'Category discount',
    'خصم خاص': 'Private discount',
    'خصم عام': 'Global discount',
    'حد الخصم': 'Discount cap',
    'بدون حد': 'No cap',
    'مستمر بدون تاريخ انتهاء': 'Ongoing with no end date',
    'صالح حتى {date}': 'Valid until {date}',
    '{used}/{max} استخدام': '{used}/{max} uses',
    'استخدام مفتوح': 'Unlimited uses',
    'العروض العامة والخاصة بحسابك':
        'Global offers and discounts linked to your account',
  };
}

extension AppLocalizationExtension on BuildContext {
  String tr(String text) => AppLocalizations.translate(text);

  String trArgs(String text, Map<String, Object?> args) {
    return AppLocalizations.translateWithArgs(text, args);
  }

  String money(num value) => AppLocalizations.formatCurrency(value);
}
