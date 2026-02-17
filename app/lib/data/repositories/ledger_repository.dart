import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ledger_transaction.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import 'base_repository.dart';

/// Repository for Ledger Transactions — the financial source of truth.
final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerRepository(ref.watch(supabaseClientProvider));
});

class LedgerRepository with SupabaseErrorHandler {
  final SupabaseClient _client;

  LedgerRepository(this._client);

  /// Fetch all transactions for a specific supplier-retailer relation.
  Future<List<LedgerTransaction>> getByRelation(String relationId) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.ledgerTable)
        .select()
        .eq('relation_id', relationId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => LedgerTransaction.fromJson(e))
        .toList();
  });

  /// Fetch pending transactions for supplier verification.
  Future<List<LedgerTransaction>> getPendingForSupplier() => guard(() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from(SupabaseConstants.ledgerTable)
        .select('''
          *,
          relation:relation_id(
            supplier_id,
            retailer:retailer_id(shop_name)
          )
        ''')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    // Filter to only this supplier's relations
    final filtered = (response as List).where((tx) {
      final relation = tx['relation'] as Map<String, dynamic>?;
      return relation?['supplier_id'] == userId;
    }).toList();

    return filtered.map((e) => LedgerTransaction.fromJson(e)).toList();
  });

  /// Create a payment declaration (Retailer action).
  /// Status is ALWAYS 'pending' — supplier must verify.
  Future<LedgerTransaction> declarePayment({
    required String relationId,
    required double amount,
    required String paymentMethod,
    String? evidenceUrl,
    String? referenceCode,
    String? notes,
  }) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.ledgerTable)
        .insert({
          'relation_id': relationId,
          'transaction_type': 'payment_decrease',
          'amount': amount,
          'payment_method': paymentMethod,
          'evidence_url': evidenceUrl,
          'reference_code': referenceCode,
          'notes': notes,
          'status': 'pending', // ⚠️ ALWAYS pending
        })
        .select()
        .single();

    return LedgerTransaction.fromJson(response);
  });

  /// Create an order increase transaction (usually triggered after order delivery).
  Future<LedgerTransaction> createOrderIncrease({
    required String relationId,
    required String orderId,
    required double amount,
  }) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.ledgerTable)
        .insert({
          'relation_id': relationId,
          'order_id': orderId,
          'transaction_type': 'order_increase',
          'amount': amount,
          'status': 'pending',
        })
        .select()
        .single();

    return LedgerTransaction.fromJson(response);
  });

  /// Verify a transaction (Supplier action).
  /// This triggers fn_update_rolling_balance in the DB.
  Future<void> verifyTransaction(String transactionId) => guard(() async {
    final userId = _client.auth.currentUser!.id;

    await _client
        .from(SupabaseConstants.ledgerTable)
        .update({
          'status': 'verified',
          'verified_by': userId,
        })
        .eq('id', transactionId);
  });

  /// Reject a transaction (Supplier action).
  Future<void> rejectTransaction(String transactionId, {String? notes}) => guard(() async {
    await _client
        .from(SupabaseConstants.ledgerTable)
        .update({
          'status': 'rejected',
          if (notes != null) 'notes': notes,
        })
        .eq('id', transactionId);
  });
}
