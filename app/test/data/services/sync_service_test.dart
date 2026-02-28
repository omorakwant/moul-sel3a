import 'package:flutter_test/flutter_test.dart';
import 'package:lcarnet_b2b/data/services/sync_service.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // QUEUED ACTION — serialization round-trip
  // ═══════════════════════════════════════════════════════════════════════════

  group('QueuedAction', () {
    test('toMap/fromMap round-trip preserves all fields', () {
      final action = QueuedAction(
        id: 'act-123',
        type: ActionType.confirmReceipt,
        payload: {
          'order_id': 'order-1',
          'items': [
            {'product_id': 'p1', 'received_qty': 8},
          ],
          'adjusted_total': 120.0,
        },
        createdAt: DateTime.utc(2026, 2, 18, 10, 0),
        status: ActionStatus.pending,
        retryCount: 0,
      );

      final map = action.toMap();
      final restored = QueuedAction.fromMap(map);

      expect(restored.id, 'act-123');
      expect(restored.type, ActionType.confirmReceipt);
      expect(restored.payload['order_id'], 'order-1');
      expect(restored.createdAt.year, 2026);
      expect(restored.status, ActionStatus.pending);
      expect(restored.retryCount, 0);
    });

    test('toMap serializes ActionType as integer index', () {
      final action = QueuedAction(
        id: 'act-1',
        type: ActionType.declarePayment,
        payload: {},
        createdAt: DateTime.now(),
      );
      final map = action.toMap();
      expect(map['type'], ActionType.declarePayment.index);
    });

    test('fromMap handles missing status (defaults to pending)', () {
      final map = {
        'id': 'act-1',
        'type': 0, // confirmReceipt
        'payload': <String, dynamic>{},
        'created_at': '2026-02-18T10:00:00Z',
        // no 'status' key
        // no 'retry_count' key
      };
      final action = QueuedAction.fromMap(map);
      expect(action.status, ActionStatus.pending);
      expect(action.retryCount, 0);
    });

    test('copyWith updates status and retryCount', () {
      final original = QueuedAction(
        id: 'act-1',
        type: ActionType.verifyDelivery,
        payload: {'job_id': 'j1'},
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        status: ActionStatus.processing,
        retryCount: 1,
        lastError: 'Network timeout',
      );

      expect(updated.id, original.id); // unchanged
      expect(updated.type, original.type); // unchanged
      expect(updated.status, ActionStatus.processing);
      expect(updated.retryCount, 1);
      expect(updated.lastError, 'Network timeout');
    });

    test('copyWith preserves fields when not specified', () {
      final original = QueuedAction(
        id: 'act-1',
        type: ActionType.confirmReceipt,
        payload: {'key': 'value'},
        createdAt: DateTime.utc(2026, 1, 1),
        status: ActionStatus.failed,
        retryCount: 3,
        lastError: 'Some error',
      );

      final updated = original.copyWith(retryCount: 4);

      expect(updated.status, ActionStatus.failed); // preserved
      expect(updated.retryCount, 4); // updated
      expect(updated.lastError, 'Some error'); // preserved
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTION TYPE enumeration
  // ═══════════════════════════════════════════════════════════════════════════

  group('ActionType', () {
    test('has 3 supported values', () {
      expect(ActionType.values.length, 3);
      expect(ActionType.values, contains(ActionType.confirmReceipt));
      expect(ActionType.values, contains(ActionType.declarePayment));
      expect(ActionType.values, contains(ActionType.verifyDelivery));
    });

    test('indices are stable for Hive serialization', () {
      // These indices are stored in Hive — changing them breaks deserialization
      expect(ActionType.confirmReceipt.index, 0);
      expect(ActionType.declarePayment.index, 1);
      expect(ActionType.verifyDelivery.index, 2);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // QUEUE STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  group('QueueStatus', () {
    test('hasWork returns true when pending > 0', () {
      const status = QueueStatus(pendingCount: 3, failedCount: 0);
      expect(status.hasWork, isTrue);
    });

    test('hasWork returns true when failed > 0', () {
      const status = QueueStatus(pendingCount: 0, failedCount: 1);
      expect(status.hasWork, isTrue);
    });

    test('hasWork returns false when both are 0', () {
      const status = QueueStatus(pendingCount: 0, failedCount: 0);
      expect(status.hasWork, isFalse);
    });

    test('defaults to online with no work', () {
      const status = QueueStatus();
      expect(status.isOnline, isTrue);
      expect(status.isSyncing, isFalse);
      expect(status.pendingCount, 0);
      expect(status.failedCount, 0);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // MAX RETRIES CONSTANT
  // ═══════════════════════════════════════════════════════════════════════════

  group('Constants', () {
    test('kMaxRetries is 5', () {
      expect(kMaxRetries, 5);
    });
  });
}
