import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/sync_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SYNC PROVIDERS — Riverpod integration for the offline action queue.
//
// These providers bridge the SyncService singleton with the widget tree:
//
//   • syncServiceProvider — the service instance (init'd in main.dart)
//   • queueStatusProvider — reactive stream of QueueStatus for UI banners
//   • offlineConfirmReceiptProvider — queues a partial receipt confirmation
//   • offlineDeclarePaymentProvider — queues a payment declaration
//   • offlineVerifyDeliveryProvider — queues a PIN delivery verification
//
// Usage in UI:
//   // Show offline badge
//   final status = ref.watch(queueStatusProvider);
//
//   // Queue an action instead of calling the repository directly
//   await ref.read(offlineDeclarePaymentProvider({...}).future);
// ═══════════════════════════════════════════════════════════════════════════════

/// The SyncService singleton — already initialized in main.dart.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

/// Reactive queue status stream for UI banners / badges.
/// Deduplicated so identical consecutive statuses don't trigger rebuilds.
final queueStatusProvider = StreamProvider<QueueStatus>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.statusStream
      .distinct((a, b) =>
          a.isOnline == b.isOnline &&
          a.isSyncing == b.isSyncing &&
          a.pendingCount == b.pendingCount &&
          a.failedCount == b.failedCount);
});

/// Current (synchronous) queue status snapshot.
final queueStatusSnapshotProvider = Provider<QueueStatus>((ref) {
  return ref.watch(syncServiceProvider).currentStatus;
});

// ─────────────────────────────────────────────────────────────────────────────
// OFFLINE-SAFE ACTION PROVIDERS
//
// These replace direct repository calls in the UI. They queue the action
// locally and attempt immediate sync. If network is down the action persists.
// ─────────────────────────────────────────────────────────────────────────────

/// Queue a partial receipt confirmation.
///
/// Payload shape:
/// ```dart
/// {
///   'order_id': String,
///   'items': List<Map<String, dynamic>>,  // adjusted items
///   'adjusted_total': double,
/// }
/// ```
final offlineConfirmReceiptProvider =
    FutureProvider.family.autoDispose<String, Map<String, dynamic>>(
  (ref, payload) async {
    final service = ref.read(syncServiceProvider);
    return service.addAction(ActionType.confirmReceipt, payload);
  },
);

/// Queue a payment declaration.
///
/// Payload shape:
/// ```dart
/// {
///   'relation_id': String,
///   'amount': double,
///   'payment_method': String,
///   'evidence_url': String?,
///   'reference_code': String?,
///   'notes': String?,
/// }
/// ```
final offlineDeclarePaymentProvider =
    FutureProvider.family.autoDispose<String, Map<String, dynamic>>(
  (ref, payload) async {
    final service = ref.read(syncServiceProvider);
    return service.addAction(ActionType.declarePayment, payload);
  },
);

/// Queue a delivery PIN verification.
///
/// ⚠️ The caller MUST pre-validate the PIN (via a read) before queuing.
/// The payload should carry all data needed to execute without a re-read:
///
/// ```dart
/// {
///   'job_id': String,
///   'order_id': String,
///   'job_type': String,       // 'standard' | 'cod'
///   'cod_amount': num?,
///   'relation_id': String?,   // from orders.relation_id
/// }
/// ```
final offlineVerifyDeliveryProvider =
    FutureProvider.family.autoDispose<String, Map<String, dynamic>>(
  (ref, payload) async {
    final service = ref.read(syncServiceProvider);
    return service.addAction(ActionType.verifyDelivery, payload);
  },
);

/// Retry all failed actions. Triggered by a "Retry" button in the UI.
final retryFailedActionsProvider = FutureProvider.autoDispose<void>(
  (ref) async {
    final service = ref.read(syncServiceProvider);
    await service.retryFailed();
  },
);

/// Manually trigger queue processing. Useful for pull-to-refresh.
final processQueueProvider = FutureProvider.autoDispose<void>(
  (ref) async {
    final service = ref.read(syncServiceProvider);
    await service.processQueue();
  },
);
