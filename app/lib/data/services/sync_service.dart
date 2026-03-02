import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/supabase_constants.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SYNC SERVICE — Offline-first action queue ("Queue Manager")
//
// Sits between UI and Supabase. Instead of calling repositories directly for
// critical write operations, the UI:
//   1. Updates its own state optimistically (instant feedback).
//   2. Calls `SyncService.addAction(...)` to enqueue the server call.
//   3. SyncService persists the action in Hive and attempts to sync
//      immediately. On failure (network down, server error) the action
//      stays in the queue and retries when connectivity returns.
//
// Supported offline actions (see ActionType enum):
//   • confirmReceipt   — Retailer confirms partial receipt
//   • declarePayment   — Retailer declares cash payment
//   • verifyDelivery   — Driver verifies PIN & completes delivery
//
// Architecture notes:
//   • Single Hive box `sync_action_queue` — survives app restarts.
//   • Retry: automatic on connectivity change + manual via processQueue().
//   • Dead-letter: after maxRetries (5) an action moves to 'failed' status.
//   • Thread-safe: _isSyncing flag prevents concurrent processing.
//   • Riverpod integration via syncServiceProvider + queueStatusProvider.
// ═══════════════════════════════════════════════════════════════════════════════

/// Types of actions the queue supports.
/// Each maps to a specific Supabase write operation.
enum ActionType {
  /// Retailer confirms partial receipt (updates order items + status).
  confirmReceipt,

  /// Retailer declares a payment (inserts pending ledger_transaction).
  declarePayment,

  /// Driver verifies PIN and completes delivery handshake.
  verifyDelivery,
}

/// Status of a queued action.
enum ActionStatus {
  pending,
  processing,
  failed,
}

// ─────────────────────────────────────────────────────────────────────────────
// QUEUED ACTION — the data model stored in Hive
// ─────────────────────────────────────────────────────────────────────────────

class QueuedAction {
  final String id;
  final ActionType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final ActionStatus status;
  final int retryCount;
  final String? lastError;

  const QueuedAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.status = ActionStatus.pending,
    this.retryCount = 0,
    this.lastError,
  });

  /// Copy with updated fields (for retry tracking).
  QueuedAction copyWith({
    ActionStatus? status,
    int? retryCount,
    String? lastError,
  }) {
    return QueuedAction(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  // ── Hive serialization ──

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.index,
    'payload': payload,
    'created_at': createdAt.toIso8601String(),
    'status': status.index,
    'retry_count': retryCount,
    'last_error': lastError,
  };

  factory QueuedAction.fromMap(Map<dynamic, dynamic> map) {
    return QueuedAction(
      id: map['id'] as String,
      type: ActionType.values[map['type'] as int],
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      createdAt: DateTime.parse(map['created_at'] as String),
      status: ActionStatus.values[(map['status'] as int?) ?? 0],
      retryCount: (map['retry_count'] as int?) ?? 0,
      lastError: map['last_error'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUEUE STATUS — exposed via Riverpod for UI badges / banners
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the queue state for the UI.
class QueueStatus {
  final int pendingCount;
  final int failedCount;
  final bool isSyncing;
  final bool isOnline;

  const QueueStatus({
    this.pendingCount = 0,
    this.failedCount = 0,
    this.isSyncing = false,
    this.isOnline = true,
  });

  bool get hasWork => pendingCount > 0 || failedCount > 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// SYNC SERVICE — singleton, Riverpod-friendly
// ─────────────────────────────────────────────────────────────────────────────

/// Maximum retries before an action is marked as failed.
const int kMaxRetries = 5;

/// Hive box name for the action queue.
const String _kBoxName = 'sync_action_queue';

class SyncService {
  SyncService._();
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;

  late final SupabaseClient _supabase;
  late Box _queueBox;
  bool _isSyncing = false;
  bool _isOnline = true;
  StreamSubscription? _connectivitySub;
  Timer? _connectivityDebounce;
  static const _connectivityDebounceDuration = Duration(milliseconds: 1500);

  /// Throttle status emissions so UI doesn't rebuild on every tiny change.
  DateTime? _lastEmitTime;
  Timer? _pendingEmit;
  static const _minEmitInterval = Duration(milliseconds: 500);

  /// Stream controller for UI reactivity.
  final _statusController = StreamController<QueueStatus>.broadcast();
  Stream<QueueStatus> get statusStream => _statusController.stream;

  /// Whether the service has been initialized.
  bool _initialized = false;

  // ── PUBLIC API ──────────────────────────────────────────────────────────

  /// Initialize the service. Call once during app startup (after Hive.initFlutter).
  /// Hive is already initialized in main.dart, so we only open the box.
  Future<void> init() async {
    if (_initialized) return;

    _supabase = Supabase.instance.client;
    _queueBox = await Hive.openBox(_kBoxName);

    // Listen for network changes — debounce to avoid lag from flaky connectivity
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (results) {
        final online = results.isNotEmpty &&
            !results.every((r) => r == ConnectivityResult.none);
        _connectivityDebounce?.cancel();
        _connectivityDebounce = Timer(_connectivityDebounceDuration, () {
          if (_isOnline != online) {
            _isOnline = online;
            _emitStatus();
            if (_isOnline) processQueue();
          }
        });
      },
    );

    // Check initial connectivity
    final initial = await Connectivity().checkConnectivity();
    _isOnline = initial.isNotEmpty &&
        !initial.every((r) => r == ConnectivityResult.none);

    _initialized = true;
    _emitStatus();

    // Process any leftover actions from a previous session
    if (_isOnline) {
      processQueue();
    }
  }

  /// Enqueue an action. Called by the UI instead of calling repos directly.
  ///
  /// Returns the queued action ID (useful for tracking in tests or UI).
  Future<String> addAction(
    ActionType type,
    Map<String, dynamic> payload,
  ) async {
    final action = QueuedAction(
      id: const Uuid().v4(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _queueBox.put(action.id, action.toMap());
    _emitStatus();

    // Try to sync immediately
    unawaited(processQueue());

    return action.id;
  }

  /// Process all pending actions in FIFO order (oldest first).
  Future<void> processQueue() async {
    if (_isSyncing || _queueBox.isEmpty) return;

    // Check connectivity before starting
    if (!_isOnline) return;

    _isSyncing = true;
    _emitStatus();

    // Sort by creation time — FIFO ordering
    final actions = _queueBox
        .toMap()
        .entries
        .map((e) => QueuedAction.fromMap(e.value as Map))
        .where((a) => a.status != ActionStatus.failed)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final action in actions) {
      // Mark as processing
      final processing = action.copyWith(status: ActionStatus.processing);
      await _queueBox.put(action.id, processing.toMap());

      try {
        await _executeAction(action);

        // Success → remove from queue
        await _queueBox.delete(action.id);
        debugPrint('[SyncService] ✅ Synced ${action.type.name} (${action.id})');
      } catch (e) {
        final newRetry = action.retryCount + 1;

        if (newRetry >= kMaxRetries) {
          // Move to dead-letter (failed) status
          final failed = action.copyWith(
            status: ActionStatus.failed,
            retryCount: newRetry,
            lastError: e.toString(),
          );
          await _queueBox.put(action.id, failed.toMap());
          debugPrint(
            '[SyncService] ❌ Failed permanently ${action.type.name} '
            '(${action.id}) after $kMaxRetries retries: $e',
          );
        } else {
          // Back to pending for retry
          final retry = action.copyWith(
            status: ActionStatus.pending,
            retryCount: newRetry,
            lastError: e.toString(),
          );
          await _queueBox.put(action.id, retry.toMap());
          debugPrint(
            '[SyncService] ⏳ Retry $newRetry/$kMaxRetries for '
            '${action.type.name} (${action.id}): $e',
          );
        }

        // Stop processing remaining actions if we hit a network error
        // (no point retrying others if we're offline)
        if (!_isOnline) break;
      }
    }

    _isSyncing = false;
    _emitStatus();
  }

  /// Retry all failed actions (user-initiated from a UI button).
  Future<void> retryFailed() async {
    final failed = _queueBox
        .toMap()
        .entries
        .map((e) => QueuedAction.fromMap(e.value as Map))
        .where((a) => a.status == ActionStatus.failed)
        .toList();

    for (final action in failed) {
      final reset = action.copyWith(
        status: ActionStatus.pending,
        retryCount: 0,
        lastError: null,
      );
      await _queueBox.put(action.id, reset.toMap());
    }

    _emitStatus();
    unawaited(processQueue());
  }

  /// Clear a specific failed action (user dismisses it).
  Future<void> dismissAction(String actionId) async {
    await _queueBox.delete(actionId);
    _emitStatus();
  }

  /// Current queue status snapshot.
  QueueStatus get currentStatus {
    int pending = 0;
    int failed = 0;

    for (final raw in _queueBox.values) {
      final action = QueuedAction.fromMap(raw as Map);
      switch (action.status) {
        case ActionStatus.pending:
        case ActionStatus.processing:
          pending++;
          break;
        case ActionStatus.failed:
          failed++;
          break;
      }
    }

    return QueueStatus(
      pendingCount: pending,
      failedCount: failed,
      isSyncing: _isSyncing,
      isOnline: _isOnline,
    );
  }

  /// Clean up resources.
  void dispose() {
    _connectivityDebounce?.cancel();
    _pendingEmit?.cancel();
    _connectivitySub?.cancel();
    _statusController.close();
  }

  // ── PRIVATE ─────────────────────────────────────────────────────────────

  /// Emit current status to the stream (throttled to reduce UI lag).
  void _emitStatus() {
    if (_statusController.isClosed) return;
    final now = DateTime.now();
    final elapsed = _lastEmitTime != null
        ? now.difference(_lastEmitTime!)
        : Duration.zero;
    if (elapsed >= _minEmitInterval) {
      _lastEmitTime = now;
      _pendingEmit?.cancel();
      _statusController.add(currentStatus);
    } else {
      _pendingEmit?.cancel();
      _pendingEmit = Timer(
        _minEmitInterval - elapsed,
        () {
          _lastEmitTime = DateTime.now();
          _pendingEmit = null;
          if (!_statusController.isClosed) {
            _statusController.add(currentStatus);
          }
        },
      );
    }
  }

  /// Route an action to its corresponding Supabase operation.
  Future<void> _executeAction(QueuedAction action) async {
    switch (action.type) {
      case ActionType.confirmReceipt:
        await _syncConfirmReceipt(action.payload);
        break;
      case ActionType.declarePayment:
        await _syncDeclarePayment(action.payload);
        break;
      case ActionType.verifyDelivery:
        await _syncVerifyDelivery(action.payload);
        break;
    }
  }

  // ── SUPABASE CALLS ──────────────────────────────────────────────────────
  // These mirror the existing repository methods but are self-contained
  // so they can execute from the queue without Riverpod context.

  /// Sync: Retailer confirms partial receipt.
  /// Mirrors OrderRepository.confirmPartialReceipt().
  Future<void> _syncConfirmReceipt(Map<String, dynamic> payload) async {
    await _supabase
        .from(SupabaseConstants.ordersTable)
        .update({
          'items': payload['items'],
          'adjusted_total': payload['adjusted_total'],
          'status': 'delivered',
        })
        .eq('id', payload['order_id'] as String);
  }

  /// Sync: Retailer declares a payment.
  /// Mirrors LedgerRepository.declarePayment().
  Future<void> _syncDeclarePayment(Map<String, dynamic> payload) async {
    await _supabase
        .from(SupabaseConstants.ledgerTable)
        .insert({
          'relation_id': payload['relation_id'],
          'transaction_type': 'payment_decrease',
          'amount': payload['amount'],
          'payment_method': payload['payment_method'],
          'evidence_url': payload['evidence_url'],
          'reference_code': payload['reference_code'],
          'notes': payload['notes'],
          'status': 'pending', // ⚠️ ALWAYS pending — supplier must verify
        });
  }

  /// Sync: Driver verifies PIN and completes delivery.
  /// Mirrors DeliveryRepository.verifyPinAndComplete().
  ///
  /// ⚠️ This is the most complex action — 4 sequential DB calls.
  /// The payload carries all pre-fetched data so we don't need a
  /// read-then-write pattern in the queue (PIN was already verified
  /// at queue-time via the pre-check).
  Future<void> _syncVerifyDelivery(Map<String, dynamic> payload) async {
    final jobId = payload['job_id'] as String;
    final orderId = payload['order_id'] as String;

    // 1. Mark delivery job as completed
    await _supabase
        .from(SupabaseConstants.deliveryJobsTable)
        .update({'status': 'completed'})
        .eq('id', jobId);

    // 2. Mark order as delivered
    await _supabase
        .from(SupabaseConstants.ordersTable)
        .update({'status': 'delivered'})
        .eq('id', orderId);

    // 3. If COD, create a verified payment ledger entry
    final codAmount = payload['cod_amount'] as num?;
    final jobType = payload['job_type'] as String?;
    final relationId = payload['relation_id'] as String?;

    if (jobType == 'cod' && codAmount != null && codAmount > 0 && relationId != null) {
      await _supabase
          .from(SupabaseConstants.ledgerTable)
          .insert({
            'relation_id': relationId,
            'order_id': orderId,
            'transaction_type': 'payment_decrease',
            'amount': codAmount,
            'payment_method': 'driver_cash',
            'notes': 'COD collected by driver — PIN verified',
            'status': 'verified',
          });
    }
  }
}
