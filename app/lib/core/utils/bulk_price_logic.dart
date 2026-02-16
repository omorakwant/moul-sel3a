/// Bulk price adjustment modes for the Supplier Admin Portal.
///
/// From PROJECT_CONTEXT.md:
///   - Fixed Offset: Add/subtract specific amount (e.g., +10 DH)
///   - Percentage Shift: Increase/decrease by percentage (e.g., +5%)
///   - Flat Override: Set a specific price for all selected items
///
/// Safety Rule: Preview step is mandatory before confirming.
enum BulkPriceMode {
  fixedOffset,
  percentageShift,
  flatOverride,
}

class BulkPriceAdjustment {
  final BulkPriceMode mode;
  final double value; // offset in DH, percentage, or flat price
  final bool applyToAllTiers; // auto-calculate L2/L3 from L1?

  const BulkPriceAdjustment({
    required this.mode,
    required this.value,
    this.applyToAllTiers = false,
  });

  /// Compute new price from an existing price.
  double apply(double currentPrice) {
    switch (mode) {
      case BulkPriceMode.fixedOffset:
        final result = currentPrice + value;
        return result > 0 ? result : 0.01; // prevent negative/zero
      case BulkPriceMode.percentageShift:
        final result = currentPrice * (1 + value / 100);
        return result > 0 ? result : 0.01;
      case BulkPriceMode.flatOverride:
        return value > 0 ? value : 0.01;
    }
  }

  /// Apply adjustment to full price_tiers JSONB.
  ///
  /// If [applyToAllTiers] is true, adjusts all tiers.
  /// Otherwise, only adjusts Tier 1 (key "1").
  Map<String, double> applyToTiers(Map<String, dynamic> priceTiers) {
    final result = <String, double>{};

    if (applyToAllTiers) {
      // Adjust every tier
      for (final entry in priceTiers.entries) {
        final oldPrice = (entry.value as num).toDouble();
        result[entry.key] = double.parse(apply(oldPrice).toStringAsFixed(2));
      }
    } else {
      // Only adjust Tier 1, keep others unchanged
      for (final entry in priceTiers.entries) {
        final oldPrice = (entry.value as num).toDouble();
        if (entry.key == '1') {
          result[entry.key] = double.parse(apply(oldPrice).toStringAsFixed(2));
        } else {
          result[entry.key] = oldPrice;
        }
      }
    }

    return result;
  }
}

/// Preview result for the mandatory "Preview Change" step.
class BulkPricePreview {
  final String productId;
  final String productName;
  final Map<String, double> oldPrices;
  final Map<String, double> newPrices;

  const BulkPricePreview({
    required this.productId,
    required this.productName,
    required this.oldPrices,
    required this.newPrices,
  });
}
