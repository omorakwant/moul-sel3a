import 'package:equatable/equatable.dart';

/// The "Carnet" — rolling debt account between a Supplier and a Retailer.
/// Maps to `public.supplier_retailer_relations`.
///
/// Key rule from PROJECT_CONTEXT.md:
///   current_balance is updated ONLY by the verified-transaction trigger.
///   Positive = retailer owes supplier.
class SupplierRetailerRelation extends Equatable {
  final String id;
  final String supplierId;
  final String retailerId;
  final double creditLimit;
  final double currentBalance; // positive = retailer owes supplier
  final String status; // 'active' | 'suspended' | 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Joined fields (for display) ──
  final String? supplierName;
  final String? retailerName;
  final String? supplierPhone;

  const SupplierRetailerRelation({
    required this.id,
    required this.supplierId,
    required this.retailerId,
    required this.creditLimit,
    required this.currentBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.supplierName,
    this.retailerName,
    this.supplierPhone,
  });

  /// Percentage of credit used (for progress bars on dashboard).
  double get creditUsagePercent {
    if (creditLimit <= 0) return 0;
    return (currentBalance / creditLimit).clamp(0.0, 1.0);
  }

  /// Whether the retailer has exceeded their credit limit.
  bool get isOverLimit => creditLimit > 0 && currentBalance > creditLimit;

  /// Whether this relation is active and can accept new orders.
  bool get isActive => status == 'active';

  factory SupplierRetailerRelation.fromJson(Map<String, dynamic> json) {
    // Handle joined supplier profile data
    final supplier = json['supplier'] as Map<String, dynamic>?;
    final retailer = json['retailer'] as Map<String, dynamic>?;

    return SupplierRetailerRelation(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      retailerId: json['retailer_id'] as String,
      creditLimit: (json['credit_limit'] as num).toDouble(),
      currentBalance: (json['current_balance'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      supplierName: supplier?['shop_name'] as String?,
      retailerName: retailer?['shop_name'] as String?,
      supplierPhone: supplier?['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'retailer_id': retailerId,
      'credit_limit': creditLimit,
      'status': status,
      // current_balance is NEVER set by the client — trigger only
    };
  }

  @override
  List<Object?> get props => [id, supplierId, retailerId, currentBalance];
}
