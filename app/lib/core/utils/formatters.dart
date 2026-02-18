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

  /// Human-readable time-ago string (e.g., "il y a 2h", "il y a 5min").
  /// Used in Screen G (Verification Desk) receipt header.
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return date(dt);
  }

  /// Compact price for dashboard cards (e.g., "12.5k DH" or "1.2M DH").
  /// Used in supplier dashboard stat cards.
  static String compactPrice(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ${AppConstants.currencyCode}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k ${AppConstants.currencyCode}';
    }
    return price(amount);
  }

  /// Time-only format: HH:mm (e.g., "14:30").
  /// Used in verification desk receipt timestamps.
  static String timeOnly(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Short date: DD/MM (without year).
  static String dateShort(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
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

  /// Generate a bilingual WhatsApp order message following Moroccan B2B norms.
  ///
  /// Template (from PROJECT_CONTEXT.md + ideation.txt):
  ///   1. Salaam greeting — mandatory for Moroccan business etiquette
  ///   2. Order ID — for dispute resolution / DB lookup
  ///   3. Client name — the retailer's shop
  ///   4. Bullet-point line items: • QTYx Name (unit_price DH)
  ///   5. "Total Estimé" — we say "estimated" because partial receipt
  ///      may adjust the final amount later
  ///   6. Deep-link placeholder for in-app order view
  static String generateWhatsAppOrderMessage({
    required String orderId,
    required String retailerName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? notes,
  }) {
    // Build bullet-point item list
    final itemDetails = items
        .map((item) =>
            '• ${item['qty']}x ${item['name']} (${price(item['price_per_unit'] as double)} )')
        .join('\n');

    final orderRef = orderId.length >= 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId.toUpperCase();

    final buffer = StringBuffer()
      ..writeln('السلام عليكم')
      ..writeln('Nouvelle Commande: #$orderRef')
      ..writeln('Client: $retailerName')
      ..writeln('------------------')
      ..writeln(itemDetails)
      ..writeln('------------------')
      ..writeln('Total Estimé: ${price(totalAmount)}');

    if (notes != null && notes.isNotEmpty) {
      buffer.writeln('\nNotes: $notes');
    }

    buffer.writeln(
        '\nConsulter sur l\'app: lcarnet://order/$orderId');

    return buffer.toString();
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
