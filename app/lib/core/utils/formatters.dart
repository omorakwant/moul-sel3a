import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Formatting utilities following PROJECT_CONTEXT.md rules:
///   - Currency: X.XX DH
///   - Date: DD/MM/YYYY
class Formatters {
  Formatters._();

  static final _dateFormat = DateFormat(AppConstants.dateFormat);
  static final _dateTimeFormat = DateFormat(AppConstants.dateTimeFormat);

  /// Format a price as "X.XX DH" per PROJECT_CONTEXT.md spec.
  /// Uses dot as decimal separator (standard in Moroccan B2B paper bons).
  static String price(double amount) {
    return '${amount.toStringAsFixed(2)} ${AppConstants.currencyCode}';
  }

  /// Format a date as DD/MM/YYYY
  static String date(DateTime dt) {
    return _dateFormat.format(dt);
  }

  /// Format a datetime as DD/MM/YYYY HH:mm
  static String dateTime(DateTime dt) {
    return _dateTimeFormat.format(dt);
  }

  /// Build a WhatsApp deep link with pre-filled message.
  /// Handles Morocco numbers: 06/07 → +2126/+2127
  static String whatsappLink({required String phone, String? message}) {
    // Clean phone number: remove spaces, dashes, parentheses
    var cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Morocco prefix normalization: 06xxxxxxxx → 2126xxxxxxxx
    if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      cleanPhone = '212${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1); // wa.me uses no + prefix
    }

    final encoded = message != null ? Uri.encodeComponent(message) : '';
    return '${AppConstants.whatsappBaseUrl}$cleanPhone${encoded.isNotEmpty ? '?text=$encoded' : ''}';
  }

  /// Resolve tiered price from JSONB price_tiers map.
  ///
  /// Logic from PROJECT_CONTEXT.md:
  ///   The app must look for the highest key that is ≤ the current cart quantity.
  ///
  /// Example: {"1": 15.0, "10": 12.0, "50": 10.0}
  ///   qty=5  → 15.0 DH
  ///   qty=10 → 12.0 DH
  ///   qty=55 → 10.0 DH
  static double resolveTieredPrice(Map<String, dynamic> priceTiers, int qty) {
    if (priceTiers.isEmpty) return 0.0;

    // Parse keys to integers and sort descending
    final thresholds = priceTiers.keys
        .map((k) => int.tryParse(k))
        .where((k) => k != null)
        .cast<int>()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Find the highest threshold ≤ qty
    for (final threshold in thresholds) {
      if (qty >= threshold) {
        final value = priceTiers[threshold.toString()];
        if (value is num) return value.toDouble();
      }
    }

    // Fallback: return the smallest tier price
    if (thresholds.isNotEmpty) {
      final smallest = thresholds.last;
      final value = priceTiers[smallest.toString()];
      if (value is num) return value.toDouble();
    }

    return 0.0;
  }
}
