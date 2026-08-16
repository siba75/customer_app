import 'package:customer_app/core/localization/app_localizations.dart';

class AppErrorMessages {
  static String friendly(String? message, {String? fallback}) {
    final text = message?.trim() ?? '';
    final fallbackMessage = fallback ?? 'حدث خطأ غير متوقع، حاول مرة أخرى.';
    if (text.isEmpty) return AppLocalizations.translate(fallbackMessage);

    final lower = text.toLowerCase();
    if (isBackendSchemaError(text)) {
      return AppLocalizations.translate(
        'الخدمة غير متاحة حالياً، يرجى المحاولة لاحقاً.',
      );
    }

    if (lower.contains('request timeout')) {
      return AppLocalizations.translate(
        'الخادم تأخر بالاستجابة، حاول مرة أخرى.',
      );
    }

    if (lower.contains('forbidden')) {
      return AppLocalizations.translate('لا تملك صلاحية الوصول لهذه البيانات.');
    }

    if (lower.contains('insufficient loyalty points')) {
      return AppLocalizations.translate(
        'نقاطك غير كافية لاستبدال هذه المكافأة.',
      );
    }

    if (lower.contains('record not found') &&
        lower.contains('loyaltydiscountoffer')) {
      return AppLocalizations.translate(
        'هذه المكافأة لم تعد متاحة للاستبدال.',
      );
    }

    return AppLocalizations.translate(text);
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
