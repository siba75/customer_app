class AppErrorMessages {
  static String friendly(String? message, {String? fallback}) {
    final text = message?.trim() ?? '';
    if (text.isEmpty) return fallback ?? 'حدث خطأ غير متوقع، حاول مرة أخرى.';

    final lower = text.toLowerCase();
    if (isBackendSchemaError(text)) {
      return 'الخدمة غير متاحة حالياً، يرجى المحاولة لاحقاً.';
    }

    if (lower.contains('request timeout')) {
      return 'الخادم تأخر بالاستجابة، حاول مرة أخرى.';
    }

    if (lower.contains('forbidden')) {
      return 'لا تملك صلاحية الوصول لهذه البيانات.';
    }

    if (lower.contains('insufficient loyalty points')) {
      return 'نقاطك غير كافية لاستبدال هذه المكافأة.';
    }

    if (lower.contains('record not found') &&
        lower.contains('loyaltydiscountoffer')) {
      return 'هذه المكافأة لم تعد متاحة للاستبدال.';
    }

    return text;
  }

  static bool isBackendSchemaError(String? message) {
    final lower = message?.toLowerCase() ?? '';
    return lower.contains('prisma') ||
        lower.contains('column ') ||
        lower.contains('does not exist') ||
        lower.contains('relation ') ||
        lower.contains('validation error') ||
        lower.contains('internal server error');
  }
}
