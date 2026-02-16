import 'package:equatable/equatable.dart';

/// Ledger transaction model — the financial source of truth.
/// Maps to `public.ledger_transactions`.
///
/// From PROJECT_CONTEXT.md:
///   Balance_new = Balance_old + (Amount × Direction)
///   Where Direction = +1 for order_increase, -1 for payment_decrease
///
/// ⚠️ current_balance ONLY updates when status becomes 'verified'.
class LedgerTransaction extends Equatable {
  final String id;
  final String relationId;
  final String? orderId;
  final String transactionType; // 'order_increase' | 'payment_decrease'
  final double amount; // always positive
  final String? paymentMethod; // 'wafacash' | 'cashplus' | 'bank_transfer' | 'driver_cash' | 'check'
  final String? evidenceUrl; // photo of receipt
  final String? referenceCode; // Wafacash/CashPlus transaction ID
  final String? notes;
  final String status; // 'pending' | 'verified' | 'rejected'
  final DateTime? verifiedAt;
  final String? verifiedBy; // supplier UUID who verified
  final DateTime createdAt;
  final DateTime updatedAt;

  const LedgerTransaction({
    required this.id,
    required this.relationId,
    this.orderId,
    required this.transactionType,
    required this.amount,
    this.paymentMethod,
    this.evidenceUrl,
    this.referenceCode,
    this.notes,
    required this.status,
    this.verifiedAt,
    this.verifiedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this is an order (debt increase).
  bool get isOrderIncrease => transactionType == 'order_increase';

  /// Whether this is a payment (debt decrease).
  bool get isPaymentDecrease => transactionType == 'payment_decrease';

  /// Whether this transaction has been verified.
  bool get isVerified => status == 'verified';

  /// Whether this transaction is still pending.
  bool get isPending => status == 'pending';

  /// Whether this transaction was rejected.
  bool get isRejected => status == 'rejected';

  /// The signed amount for display: +amount for orders, -amount for payments.
  double get signedAmount =>
      isOrderIncrease ? amount : -amount;

  /// Human-readable payment method label.
  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'wafacash':
        return 'Wafacash';
      case 'cashplus':
        return 'CashPlus';
      case 'bank_transfer':
        return 'Virement';
      case 'driver_cash':
        return 'Cash Livreur';
      case 'check':
        return 'Chèque';
      default:
        return paymentMethod ?? '-';
    }
  }

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    return LedgerTransaction(
      id: json['id'] as String,
      relationId: json['relation_id'] as String,
      orderId: json['order_id'] as String?,
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      evidenceUrl: json['evidence_url'] as String?,
      referenceCode: json['reference_code'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      verifiedBy: json['verified_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Create a new payment declaration (Retailer → Supplier).
  /// Status is always 'pending' per PROJECT_CONTEXT.md rules.
  Map<String, dynamic> toPaymentDeclarationJson() {
    return {
      'relation_id': relationId,
      'transaction_type': 'payment_decrease',
      'amount': amount,
      'payment_method': paymentMethod,
      'evidence_url': evidenceUrl,
      'reference_code': referenceCode,
      'notes': notes,
      'status': 'pending', // ⚠️ ALWAYS pending — supplier must verify
    };
  }

  /// Create an order increase entry (usually created server-side).
  Map<String, dynamic> toOrderIncreaseJson() {
    return {
      'relation_id': relationId,
      'order_id': orderId,
      'transaction_type': 'order_increase',
      'amount': amount,
      'status': 'pending',
    };
  }

  @override
  List<Object?> get props => [id, transactionType, amount, status];
}
