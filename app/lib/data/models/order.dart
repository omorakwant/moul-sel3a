import 'package:equatable/equatable.dart';

/// Line item within an Order (stored in orders.items JSONB array).
class OrderItem extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final int? adjustedQuantity; // set during partial receipt
  final double unitPrice;
  final double lineTotal;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    this.adjustedQuantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  /// The effective quantity after partial receipt adjustment.
  int get effectiveQuantity => adjustedQuantity ?? quantity;

  /// The effective line total after adjustment.
  double get effectiveTotal => effectiveQuantity * unitPrice;

  /// Whether this item was adjusted during partial receipt.
  bool get wasAdjusted =>
      adjustedQuantity != null && adjustedQuantity != quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      name: json['name'] as String,
      quantity: json['qty'] as int,
      adjustedQuantity: json['adjusted_qty'] as int?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      lineTotal: (json['line_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'qty': quantity,
      if (adjustedQuantity != null) 'adjusted_qty': adjustedQuantity,
      'unit_price': unitPrice,
      'line_total': lineTotal,
    };
  }

  OrderItem copyWithAdjustedQty(int newQty) {
    return OrderItem(
      productId: productId,
      name: name,
      quantity: quantity,
      adjustedQuantity: newQty,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
    );
  }

  @override
  List<Object?> get props => [productId, quantity, adjustedQuantity, unitPrice];
}

/// Order model — the "Digital Bon" (الطلبية).
/// Maps to `public.orders`.
///
/// Key features from PROJECT_CONTEXT.md:
///   - adjusted_total for partial receipt
///   - driver_name for assigned drivers
///   - items as JSONB array of OrderItem
class Order extends Equatable {
  final String id;
  final String supplierId;
  final String retailerId;
  final String relationId;
  final List<OrderItem> items;
  final double originalTotal;
  final double? adjustedTotal; // set after partial receipt
  final String? driverName;
  final String status; // pending → confirmed → ready_for_pickup → shipped → delivered
  final String? deliveryType; // 'in_house' | 'bid_driver'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Joined fields ──
  final String? supplierName;
  final String? retailerName;

  const Order({
    required this.id,
    required this.supplierId,
    required this.retailerId,
    required this.relationId,
    required this.items,
    required this.originalTotal,
    this.adjustedTotal,
    this.driverName,
    required this.status,
    this.deliveryType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.supplierName,
    this.retailerName,
  });

  /// The final total: adjusted (if partial receipt) or original.
  double get finalTotal => adjustedTotal ?? originalTotal;

  /// Number of line items.
  int get itemCount => items.length;

  /// Total number of pieces across all items.
  int get totalPieces => items.fold(0, (sum, item) => sum + item.effectiveQuantity);

  /// Whether this order has been partially received.
  bool get isPartiallyReceived =>
      adjustedTotal != null && adjustedTotal != originalTotal;

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return Order(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      retailerId: json['retailer_id'] as String,
      relationId: json['relation_id'] as String,
      items: itemsList,
      originalTotal: (json['original_total'] as num).toDouble(),
      adjustedTotal: json['adjusted_total'] != null
          ? (json['adjusted_total'] as num).toDouble()
          : null,
      driverName: json['driver_name'] as String?,
      status: json['status'] as String,
      deliveryType: json['delivery_type'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      supplierName: (json['supplier'] as Map<String, dynamic>?)?['shop_name'] as String?,
      retailerName: (json['retailer'] as Map<String, dynamic>?)?['shop_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'retailer_id': retailerId,
      'relation_id': relationId,
      'items': items.map((e) => e.toJson()).toList(),
      'original_total': originalTotal,
      if (adjustedTotal != null) 'adjusted_total': adjustedTotal,
      if (driverName != null) 'driver_name': driverName,
      'status': status,
      if (deliveryType != null) 'delivery_type': deliveryType,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, status, originalTotal, adjustedTotal];
}
