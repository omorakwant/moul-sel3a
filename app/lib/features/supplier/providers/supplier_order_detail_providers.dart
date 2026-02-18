import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/services/realtime_service.dart';
import 'supplier_dashboard_providers.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SUPPLIER ORDER DETAIL PROVIDERS
//
// Data + actions for the Supplier Order Detail screen:
//   - Single order by ID (auto-refreshing)
//   - Status transition notifier (confirm → ready_for_pickup → shipped)
// ═════════════════════════════════════════════════════════════════════════════

/// Single order by ID for the supplier detail view.
/// Auto-refreshes via orders realtime channel.
final supplierOrderDetailProvider =
    FutureProvider.family.autoDispose<Order?, String>((ref, orderId) async {
  ref.watch(ordersRealtimeProvider);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getById(orderId);
});

/// State for order action operations (confirm, reject, ready, etc.).
enum OrderActionState { idle, loading, success, error }

class OrderActionResult {
  final OrderActionState state;
  final String? errorMessage;

  const OrderActionResult({
    this.state = OrderActionState.idle,
    this.errorMessage,
  });

  OrderActionResult copyWith({OrderActionState? state, String? errorMessage}) {
    return OrderActionResult(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier for supplier order actions with loading / success / error states.
///
/// Wraps the dashboard action providers (confirmOrder, rejectOrder,
/// markReadyForPickup) with proper state management for the detail screen.
class SupplierOrderActionNotifier extends StateNotifier<OrderActionResult> {
  final Ref _ref;

  SupplierOrderActionNotifier(this._ref)
      : super(const OrderActionResult());

  /// Confirm a pending order.
  Future<void> confirmOrder(String orderId) async {
    state = const OrderActionResult(state: OrderActionState.loading);
    try {
      await _ref.read(confirmOrderProvider(orderId).future);
      _ref.invalidate(supplierOrderDetailProvider(orderId));
      state = const OrderActionResult(state: OrderActionState.success);
    } catch (e) {
      state = OrderActionResult(
        state: OrderActionState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reject a pending order.
  Future<void> rejectOrder(String orderId) async {
    state = const OrderActionResult(state: OrderActionState.loading);
    try {
      await _ref.read(rejectOrderProvider(orderId).future);
      _ref.invalidate(supplierOrderDetailProvider(orderId));
      state = const OrderActionResult(state: OrderActionState.success);
    } catch (e) {
      state = OrderActionResult(
        state: OrderActionState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Mark order as ready for pickup (auto-creates delivery job).
  Future<void> markReadyForPickup(String orderId) async {
    state = const OrderActionResult(state: OrderActionState.loading);
    try {
      await _ref.read(markReadyForPickupProvider(orderId).future);
      _ref.invalidate(supplierOrderDetailProvider(orderId));
      state = const OrderActionResult(state: OrderActionState.success);
    } catch (e) {
      state = OrderActionResult(
        state: OrderActionState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset to idle state (after showing snackbar, etc.).
  void reset() {
    state = const OrderActionResult();
  }
}

/// Provider for the order action notifier.
final supplierOrderActionProvider =
    StateNotifierProvider.autoDispose<SupplierOrderActionNotifier, OrderActionResult>(
  (ref) => SupplierOrderActionNotifier(ref),
);
