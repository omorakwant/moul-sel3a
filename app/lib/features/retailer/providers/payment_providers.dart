import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/ledger_transaction.dart';
import '../../../data/repositories/ledger_repository.dart';

// ═════════════════════════════════════════════════════════════════════════════
// PAYMENT PROVIDERS — State management for Payment Declaration &
// Ledger History screens.
//
// PROJECT_CONTEXT.md — Payment Declaration Flow:
//   Retailer → photos receipt → enters amount + reference code
//   → creates ledger_transaction (status: pending)
//   → Supplier verifies → balance updates
// ═════════════════════════════════════════════════════════════════════════════

/// Fetches ledger transactions for a specific relation.
final relationLedgerProvider =
    FutureProvider.family.autoDispose<List<LedgerTransaction>, String>(
        (ref, relationId) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.getByRelation(relationId);
});

/// Declare a payment (creates pending ledger_transaction).
final declarePaymentProvider = FutureProvider.family
    .autoDispose<LedgerTransaction, Map<String, dynamic>>(
        (ref, params) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  final tx = await repo.declarePayment(
    relationId: params['relation_id'] as String,
    amount: params['amount'] as double,
    paymentMethod: params['payment_method'] as String,
    evidenceUrl: params['evidence_url'] as String?,
    referenceCode: params['reference_code'] as String?,
    notes: params['notes'] as String?,
  );
  // Invalidate ledger for this relation so history refreshes
  ref.invalidate(relationLedgerProvider(params['relation_id'] as String));
  return tx;
});
