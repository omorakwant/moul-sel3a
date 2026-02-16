/// Cart item used locally before order submission.
/// Not persisted to database — exists only in-memory/local cache.
class CartItem {
  final String productId;
  final String productName;
  final String? imageUrl;
  final Map<String, dynamic> priceTiers;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.priceTiers,
    this.quantity = 1,
  });

  /// Current unit price based on tiered pricing logic.
  double get unitPrice {
    if (priceTiers.isEmpty) return 0.0;

    final thresholds = priceTiers.keys
        .map((k) => int.tryParse(k))
        .where((k) => k != null)
        .cast<int>()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final threshold in thresholds) {
      if (quantity >= threshold) {
        return (priceTiers[threshold.toString()] as num).toDouble();
      }
    }

    if (thresholds.isNotEmpty) {
      return (priceTiers[thresholds.last.toString()] as num).toDouble();
    }

    return 0.0;
  }

  /// Line total = unitPrice × quantity.
  double get lineTotal => unitPrice * quantity;

  /// Convert to order item JSON for the orders.items JSONB field.
  Map<String, dynamic> toOrderItemJson() {
    return {
      'product_id': productId,
      'name': productName,
      'qty': quantity,
      'unit_price': unitPrice,
      'line_total': lineTotal,
    };
  }
}
