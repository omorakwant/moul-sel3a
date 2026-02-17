import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order.dart';
import '../../../data/models/supplier_retailer_relation.dart';
import '../../../data/models/delivery_job.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/relation_repository.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../data/repositories/ledger_repository.dart';
import '../../../data/repositories/profile_repository.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SUPPLIER DASHBOARD PROVIDERS
//
// Wires the Supplier admin control center:
//   - Pending orders to confirm/reject
//   - Retailer list with balances
//   - Active deliveries
//   - Revenue summary
// ═════════════════════════════════════════════════════════════════════════════

/// All orders for this supplier (newest first).
final supplierOrdersProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getSupplierOrders();
});

/// Pending orders waiting for supplier confirmation.
final supplierPendingOrdersProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getSupplierOrders(status: 'pending');
});

/// Confirmed orders (ready to prepare / dispatch).
final supplierConfirmedOrdersProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getSupplierOrders(status: 'confirmed');
});

/// All retailer relations for this supplier ("Le Carnet" list).
final supplierRelationsProvider =
    FutureProvider.autoDispose<List<SupplierRetailerRelation>>((ref) async {
  final repo = ref.watch(relationRepositoryProvider);
  return repo.getSupplierRelations();
});

/// Active delivery jobs for this supplier.
final supplierDeliveryJobsProvider =
    FutureProvider.autoDispose<List<DeliveryJob>>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getSupplierJobs();
});

/// Total revenue across all delivered orders.
final supplierTotalRevenueProvider = Provider.autoDispose<double>((ref) {
  final ordersAsync = ref.watch(supplierOrdersProvider);
  return ordersAsync.when(
    data: (orders) => orders
        .where((o) => o.status == 'delivered')
        .fold(0.0, (sum, o) => sum + o.finalTotal),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Total outstanding debt from all retailers.
final supplierTotalOutstandingProvider = Provider.autoDispose<double>((ref) {
  final relationsAsync = ref.watch(supplierRelationsProvider);
  return relationsAsync.when(
    data: (relations) =>
        relations.fold(0.0, (sum, r) => sum + r.currentBalance),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Count of pending orders (for badge display).
final supplierPendingOrderCountProvider = Provider.autoDispose<int>((ref) {
  final ordersAsync = ref.watch(supplierPendingOrdersProvider);
  return ordersAsync.when(
    data: (orders) => orders.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Count of active deliveries (in_transit or assigned).
final supplierActiveDeliveryCountProvider = Provider.autoDispose<int>((ref) {
  final jobsAsync = ref.watch(supplierDeliveryJobsProvider);
  return jobsAsync.when(
    data: (jobs) => jobs
        .where((j) => j.status == 'in_transit' || j.status == 'assigned')
        .length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Confirm an order (supplier approves → status: confirmed).
/// Also creates an order_increase ledger entry (pending) per PROJECT_CONTEXT.md.
final confirmOrderProvider =
    FutureProvider.family.autoDispose<void, String>((ref, orderId) async {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final ledgerRepo = ref.watch(ledgerRepositoryProvider);

  // 1. Update order status
  await orderRepo.updateStatus(orderId, 'confirmed');

  // 2. Get full order to create ledger entry
  final order = await orderRepo.getById(orderId);
  if (order != null) {
    // Create order_increase ledger entry (will be auto-verified
    // or manually verified by supplier depending on business rules)
    await ledgerRepo.createOrderIncrease(
      relationId: order.relationId,
      orderId: order.id,
      amount: order.finalTotal,
    );
  }

  ref.invalidate(supplierPendingOrdersProvider);
  ref.invalidate(supplierOrdersProvider);
  ref.invalidate(supplierConfirmedOrdersProvider);
});

/// Reject an order (supplier rejects → status: cancelled).
final rejectOrderProvider =
    FutureProvider.family.autoDispose<void, String>((ref, orderId) async {
  final repo = ref.watch(orderRepositoryProvider);
  await repo.updateStatus(orderId, 'cancelled');
  ref.invalidate(supplierPendingOrdersProvider);
  ref.invalidate(supplierOrdersProvider);
});

/// Mark an order as ready for pickup → auto-creates delivery_job.
/// PROJECT_CONTEXT.md: "When supplier marks order ready_for_pickup → auto-create delivery_job"
final markReadyForPickupProvider =
    FutureProvider.family.autoDispose<void, String>((ref, orderId) async {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final deliveryRepo = ref.watch(deliveryRepositoryProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);

  // 1. Update order status
  await orderRepo.updateStatus(orderId, 'ready_for_pickup');

  // 2. Get full order + supplier profile for delivery job creation
  final order = await orderRepo.getById(orderId);
  if (order == null) return;

  final supplierProfile = await profileRepo.getById(order.supplierId);

  // 3. Auto-create delivery job (open for bidding)
  final job = DeliveryJob(
    id: '', // DB generates UUID
    orderId: order.id,
    supplierId: order.supplierId,
    pickupCity: supplierProfile?.city ?? '',
    pickupLocationName: supplierProfile?.locationName,
    dropoffCity: '', // Will be filled when retailer profile is fetched
    jobType: 'delivery_only',
    status: 'open',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  await deliveryRepo.createJob(job);

  ref.invalidate(supplierConfirmedOrdersProvider);
  ref.invalidate(supplierOrdersProvider);
  ref.invalidate(supplierDeliveryJobsProvider);
});
