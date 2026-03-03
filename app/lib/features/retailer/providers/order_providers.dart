import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/realtime_service.dart';
import '../../auth/providers/auth_providers.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// ORDER PROVIDERS — State management for Order Detail, Partial Receipt,
/// and Handshake Confirmation screens.
///
/// Flow:
///   1. Retailer opens order detail → orderDetailProvider(orderId)
///   2. If status is 'shipped' (arrived) → can start partial receipt
///   3. adjustedQuantitiesProvider holds per-item qty overrides
///   4. On confirm → submits to Supabase via confirmPartialReceipt
/// ══════════════════════════════════════════════════════════════════════════════

/// Currently selected order ID (set by the screen).
final selectedOrderIdProvider = StateProvider<String?>((ref) => null);

/// Fetches a single order by ID.
/// Auto-refreshes when the orders table changes via realtime.
final orderDetailProvider =
    FutureProvider.family<Order?, String>((ref, orderId) async {
  if (kIsWeb) {
    final mockUser = ref.read(mockCurrentUserProvider);
    try {
      return mockOrders.firstWhere((o) =>
          o.id == orderId && o.retailerId == mockUser.id);
    } catch (_) {
      return null;
    }
  }
  ref.watch(ordersRealtimeProvider);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getById(orderId);
});

/// Fetches all orders for the logged-in retailer.
/// Auto-refreshes when the orders table changes via realtime.
final retailerOrdersProvider =
    FutureProvider<List<Order>>((ref) async {
  if (kIsWeb) {
    final mockUser = ref.read(mockCurrentUserProvider);
    final list = mockOrders
        .where((o) => o.retailerId == mockUser.id)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
  ref.watch(ordersRealtimeProvider);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getRetailerOrders();
});

/// ══════════════════════════════════════════════════════════════════════════════
/// PARTIAL RECEIPT STATE
/// ══════════════════════════════════════════════════════════════════════════════

/// Holds per-item adjusted quantities during partial receipt.
/// Key: index in order.items, Value: adjusted quantity.
///
/// If an entry is absent, the original quantity is used.
final adjustedQuantitiesProvider =
    StateNotifierProvider<AdjustedQuantitiesNotifier, Map<int, int>>(
  (ref) => AdjustedQuantitiesNotifier(),
);

class AdjustedQuantitiesNotifier extends StateNotifier<Map<int, int>> {
  AdjustedQuantitiesNotifier() : super({});

  /// Initialize with original quantities from the order.
  void initFromOrder(Order order) {
    final map = <int, int>{};
    for (var i = 0; i < order.items.length; i++) {
      map[i] = order.items[i].quantity;
    }
    state = map;
  }

  /// Increment quantity for item at index (max = original qty).
  void increment(int index, int maxQty) {
    final current = state[index] ?? 0;
    if (current < maxQty) {
      state = {...state, index: current + 1};
    }
  }

  /// Decrement quantity for item at index (min = 0).
  void decrement(int index) {
    final current = state[index] ?? 0;
    if (current > 0) {
      state = {...state, index: current - 1};
    }
  }

  /// Set a specific quantity for an item.
  void setQuantity(int index, int qty) {
    state = {...state, index: qty};
  }

  /// Reset all adjustments.
  void reset() => state = {};
}

/// Whether quantities have been reviewed (user has interacted with steppers).
final quantitiesReviewedProvider = StateProvider<bool>((ref) => false);

/// Computed: whether any item was adjusted from its original quantity.
final hasAdjustmentsProvider = Provider<bool>((ref) {
  final orderId = ref.watch(selectedOrderIdProvider);
  if (orderId == null) return false;

  final orderAsync = ref.watch(orderDetailProvider(orderId));
  final adjustments = ref.watch(adjustedQuantitiesProvider);

  return orderAsync.whenOrNull(
        data: (order) {
          if (order == null) return false;
          for (var i = 0; i < order.items.length; i++) {
            final adjusted = adjustments[i] ?? order.items[i].quantity;
            if (adjusted != order.items[i].quantity) return true;
          }
          return false;
        },
      ) ??
      false;
});

/// Computed: the number of items that were adjusted.
final adjustmentCountProvider = Provider<int>((ref) {
  final orderId = ref.watch(selectedOrderIdProvider);
  if (orderId == null) return 0;

  final orderAsync = ref.watch(orderDetailProvider(orderId));
  final adjustments = ref.watch(adjustedQuantitiesProvider);

  return orderAsync.whenOrNull(
        data: (order) {
          if (order == null) return 0;
          var count = 0;
          for (var i = 0; i < order.items.length; i++) {
            final adjusted = adjustments[i] ?? order.items[i].quantity;
            if (adjusted != order.items[i].quantity) count++;
          }
          return count;
        },
      ) ??
      0;
});

/// Computed: adjusted total based on current quantities.
final adjustedTotalProvider = Provider<double>((ref) {
  final orderId = ref.watch(selectedOrderIdProvider);
  if (orderId == null) return 0.0;

  final orderAsync = ref.watch(orderDetailProvider(orderId));
  final adjustments = ref.watch(adjustedQuantitiesProvider);

  return orderAsync.whenOrNull(
        data: (order) {
          if (order == null) return 0.0;
          var total = 0.0;
          for (var i = 0; i < order.items.length; i++) {
            final qty = adjustments[i] ?? order.items[i].quantity;
            total += qty * order.items[i].unitPrice;
          }
          return total;
        },
      ) ??
      0.0;
});

/// Submit partial receipt confirmation to Supabase.
final confirmReceiptProvider =
    FutureProvider.family<void, String>((ref, orderId) async {
  final repo = ref.watch(orderRepositoryProvider);
  final orderAsync = ref.watch(orderDetailProvider(orderId));
  final adjustments = ref.watch(adjustedQuantitiesProvider);

  final order = orderAsync.valueOrNull;
  if (order == null) return;

  // Build adjusted items list
  final adjustedItems = <Map<String, dynamic>>[];
  var adjustedTotal = 0.0;

  for (var i = 0; i < order.items.length; i++) {
    final item = order.items[i];
    final qty = adjustments[i] ?? item.quantity;
    final lineTotal = qty * item.unitPrice;
    adjustedTotal += lineTotal;

    adjustedItems.add({
      'product_id': item.productId,
      'name': item.name,
      'qty': item.quantity,
      'adjusted_qty': qty,
      'unit_price': item.unitPrice,
      'line_total': item.lineTotal,
    });
  }

  await repo.confirmPartialReceipt(
    orderId,
    adjustedItems: adjustedItems,
    adjustedTotal: adjustedTotal,
  );
});

/// Fetches the phone number of a supplier by their profile ID.
/// Used for WhatsApp voice note deep links on order detail screens.
final supplierPhoneProvider =
    FutureProvider.family<String?, String>((ref, supplierId) async {
  final profileRepo = ref.watch(profileRepositoryProvider);
  final profile = await profileRepo.getById(supplierId);
  return profile?.phone;
});

/// Validate (confirm) an order from the retailer side.
///
/// This updates the order status to 'confirmed' — the retailer agrees
/// with the bon (items + prices) and is ready for the supplier to prepare.
final retailerValidateOrderProvider =
    FutureProvider.family.autoDispose<void, String>((ref, orderId) async {
  final repo = ref.watch(orderRepositoryProvider);
  await repo.updateStatus(orderId, 'confirmed');
  ref.invalidate(retailerOrdersProvider);
});
