import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/ledger_transaction.dart';
import '../../../data/repositories/ledger_repository.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SUPPLIER VERIFICATION PROVIDERS
//
// Manages the Verification Desk: approve/reject pending payment declarations.
//
// PROJECT_CONTEXT.md:
//   "Pending ledger_transactions — evidence photo + approve/reject"
//   Approve → status: verified → fn_update_rolling_balance trigger fires
//   Reject → status: rejected → balance unchanged
// ═════════════════════════════════════════════════════════════════════════════

/// Fetches all pending ledger_transactions for this supplier to verify.
/// On web uses mock data.
final pendingVerificationsProvider =
    FutureProvider.autoDispose<List<LedgerTransaction>>((ref) async {
  if (kIsWeb) return mockPendingVerifications;
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.getPendingForSupplier();
});

/// Verify (approve) a transaction → triggers balance update.
/// On web (prototype) no-op: just invalidate so UI refreshes.
final verifyTransactionProvider =
    FutureProvider.family.autoDispose<void, String>((ref, txId) async {
  if (kIsWeb) {
    ref.invalidate(pendingVerificationsProvider);
    return;
  }
  final repo = ref.watch(ledgerRepositoryProvider);
  await repo.verifyTransaction(txId);
  ref.invalidate(pendingVerificationsProvider);
});

/// Reject a transaction → balance unchanged.
/// On web (prototype) no-op: just invalidate so UI refreshes.
final rejectTransactionProvider = FutureProvider.family
    .autoDispose<void, ({String txId, String? notes})>((ref, params) async {
  if (kIsWeb) {
    ref.invalidate(pendingVerificationsProvider);
    return;
  }
  final repo = ref.watch(ledgerRepositoryProvider);
  await repo.rejectTransaction(params.txId, notes: params.notes);
  ref.invalidate(pendingVerificationsProvider);
});
