import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import 'supabase_service.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// REALTIME SERVICE — Supabase Realtime Postgres Changes
///
/// Provides invalidation signals for each table so FutureProviders auto-refresh
/// when data changes on the server (other clients, or edge-function writes).
///
/// Pattern:
///   1. A `_tableChangeProvider` streams Postgres INSERT/UPDATE/DELETE events.
///   2. The existing FutureProvider `watch`es the change provider.
///   3. Any change → FutureProvider re-fetches from the DB automatically.
///
/// This is simpler and more robust than rebuilding models from the realtime
/// payload, because the payload may lack JOINs (e.g., supplier.shop_name).
/// ══════════════════════════════════════════════════════════════════════════════

/// A lightweight change event emitted when a Postgres table row changes.
class TableChangeEvent {
  final String table;
  final String eventType; // INSERT, UPDATE, DELETE
  final Map<String, dynamic> newRecord;
  final Map<String, dynamic> oldRecord;
  final DateTime receivedAt;

  const TableChangeEvent({
    required this.table,
    required this.eventType,
    required this.newRecord,
    required this.oldRecord,
    required this.receivedAt,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDERS TABLE — realtime change stream
// ─────────────────────────────────────────────────────────────────────────────

/// Streams every INSERT / UPDATE / DELETE on `orders`.
///
/// Providers that need live order updates simply `ref.watch` this.
/// When a new event arrives the dependent FutureProvider is invalidated
/// and automatically re-fetches.
final ordersRealtimeProvider = StreamProvider.autoDispose<TableChangeEvent>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final controller = StreamController<TableChangeEvent>();

  final channel = client
      .channel('orders-changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: SupabaseConstants.ordersTable,
        callback: (payload) {
          controller.add(TableChangeEvent(
            table: SupabaseConstants.ordersTable,
            eventType: payload.eventType.name,
            newRecord: payload.newRecord,
            oldRecord: payload.oldRecord,
            receivedAt: DateTime.now(),
          ));
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});

// ─────────────────────────────────────────────────────────────────────────────
// DELIVERY JOBS TABLE — realtime change stream
// ─────────────────────────────────────────────────────────────────────────────

final deliveryJobsRealtimeProvider =
    StreamProvider.autoDispose<TableChangeEvent>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final controller = StreamController<TableChangeEvent>();

  final channel = client
      .channel('delivery-jobs-changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: SupabaseConstants.deliveryJobsTable,
        callback: (payload) {
          controller.add(TableChangeEvent(
            table: SupabaseConstants.deliveryJobsTable,
            eventType: payload.eventType.name,
            newRecord: payload.newRecord,
            oldRecord: payload.oldRecord,
            receivedAt: DateTime.now(),
          ));
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});

// ─────────────────────────────────────────────────────────────────────────────
// DELIVERY BIDS TABLE — realtime change stream
// ─────────────────────────────────────────────────────────────────────────────

final deliveryBidsRealtimeProvider =
    StreamProvider.autoDispose<TableChangeEvent>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final controller = StreamController<TableChangeEvent>();

  final channel = client
      .channel('delivery-bids-changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: SupabaseConstants.deliveryBidsTable,
        callback: (payload) {
          controller.add(TableChangeEvent(
            table: SupabaseConstants.deliveryBidsTable,
            eventType: payload.eventType.name,
            newRecord: payload.newRecord,
            oldRecord: payload.oldRecord,
            receivedAt: DateTime.now(),
          ));
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});

// ─────────────────────────────────────────────────────────────────────────────
// LEDGER TRANSACTIONS TABLE — realtime change stream
// ─────────────────────────────────────────────────────────────────────────────

final ledgerRealtimeProvider =
    StreamProvider.autoDispose<TableChangeEvent>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final controller = StreamController<TableChangeEvent>();

  final channel = client
      .channel('ledger-changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: SupabaseConstants.ledgerTable,
        callback: (payload) {
          controller.add(TableChangeEvent(
            table: SupabaseConstants.ledgerTable,
            eventType: payload.eventType.name,
            newRecord: payload.newRecord,
            oldRecord: payload.oldRecord,
            receivedAt: DateTime.now(),
          ));
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});
