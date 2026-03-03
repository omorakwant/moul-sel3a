import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/delivery_job.dart';
import '../../../data/models/delivery_bid.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../data/services/realtime_service.dart';
import '../../../data/services/sync_service.dart';
import '../../../core/providers/sync_providers.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DRIVER MARKETPLACE — Open jobs feed
// ══════════════════════════════════════════════════════════════════════════════

/// Fetches all open delivery jobs for the driver marketplace.
/// Auto-refreshes via Supabase realtime. On web uses mock data.
final openJobsFeedProvider =
    FutureProvider.autoDispose<List<DeliveryJob>>((ref) async {
  if (kIsWeb) return mockDeliveryJobs.where((j) => j.status == 'open').toList();
  ref.watch(deliveryJobsRealtimeProvider);
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getOpenJobs();
});

/// Fetches jobs assigned to the current driver (active trips).
/// Auto-refreshes via Supabase realtime. On web uses mock data.
final myActiveJobsProvider =
    FutureProvider.autoDispose<List<DeliveryJob>>((ref) async {
  if (kIsWeb) {
    return mockDeliveryJobs
        .where((j) => j.status == 'assigned' || j.status == 'in_transit')
        .toList();
  }
  ref.watch(deliveryJobsRealtimeProvider);
  final repo = ref.watch(deliveryRepositoryProvider);
  final jobs = await repo.getDriverJobs();
  return jobs
      .where((j) => j.status == 'assigned' || j.status == 'in_transit')
      .toList();
});

/// Fetches a single delivery job by ID.
/// Auto-refreshes via Supabase realtime. On web uses mock data.
final deliveryJobByIdProvider =
    FutureProvider.autoDispose.family<DeliveryJob?, String>((ref, jobId) async {
  if (kIsWeb) {
    try {
      return mockDeliveryJobs.firstWhere((j) => j.id == jobId);
    } catch (_) {
      return null;
    }
  }
  ref.watch(deliveryJobsRealtimeProvider);
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getJobById(jobId);
});

/// Fetches a single delivery job by order ID (for handshake deep links).
/// On web uses mock data.
final deliveryJobByOrderIdProvider =
    FutureProvider.autoDispose.family<DeliveryJob?, String>((ref, orderId) async {
  if (kIsWeb) {
    try {
      return mockDeliveryJobs.firstWhere((j) => j.orderId == orderId);
    } catch (_) {
      return null;
    }
  }
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getJobByOrderId(orderId);
});

/// Retailer phone for a delivery job (for WhatsApp contact).
/// On web prototype: resolved from mock order + mock profile.
final retailerPhoneForJobProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, jobId) async {
  if (!kIsWeb) return null;
  try {
    final job = mockDeliveryJobs.firstWhere((j) => j.id == jobId);
    final order = mockOrders.firstWhere((o) => o.id == job.orderId);
    final profile = mockProfiles.firstWhere((p) => p.id == order.retailerId);
    return profile.phone;
  } catch (_) {
    return null;
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// BIDDING
// ══════════════════════════════════════════════════════════════════════════════

/// Check if current driver already bid on this job.
/// Auto-refreshes via Supabase realtime. On web uses mock data.
final myBidForJobProvider =
    FutureProvider.autoDispose.family<DeliveryBid?, String>((ref, jobId) async {
  if (kIsWeb) {
    try {
      return mockDeliveryBids
          .where((b) => b.jobId == jobId && b.driverId == 'mock-driver-001')
          .first;
    } catch (_) {
      return null;
    }
  }
  ref.watch(deliveryBidsRealtimeProvider);
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getMyBidForJob(jobId);
});

/// Place a bid — notifier pattern for loading/error state.
class PlaceBidNotifier extends StateNotifier<AsyncValue<DeliveryBid?>> {
  final DeliveryRepository _repo;

  PlaceBidNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<DeliveryBid?> placeBid({
    required String jobId,
    required double bidAmount,
    String? estimatedTime,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    try {
      final bid = await _repo.placeBid(
        jobId: jobId,
        bidAmount: bidAmount,
        estimatedTime: estimatedTime,
        message: message,
      );
      state = AsyncValue.data(bid);
      return bid;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final placeBidNotifierProvider =
    StateNotifierProvider.autoDispose<PlaceBidNotifier, AsyncValue<DeliveryBid?>>(
  (ref) => PlaceBidNotifier(ref.watch(deliveryRepositoryProvider)),
);

// ══════════════════════════════════════════════════════════════════════════════
// ACTIVE TRIP — PIN Handshake
// ══════════════════════════════════════════════════════════════════════════════

/// Start a trip (driver → in_transit).
class TripActionNotifier extends StateNotifier<AsyncValue<void>> {
  final DeliveryRepository _repo;
  final SyncService _syncService;

  TripActionNotifier(this._repo, this._syncService)
      : super(const AsyncValue.data(null));

  Future<bool> startTrip(String jobId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.startTrip(jobId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Verify PIN and queue delivery completion via SyncService.
  ///
  /// Flow:
  ///   1. Online: fetch job + verify PIN (read — requires network).
  ///   2. If PIN correct → queue the mutations (offline-safe).
  ///   3. SyncService handles: mark job completed, order delivered, COD ledger.
  ///
  /// Returns true if PIN matches, false otherwise.
  Future<bool> verifyPinAndComplete({
    required String jobId,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Step 1: Online PIN verification (read-only)
      final jobData = await _repo.verifyPinOnly(jobId: jobId, pin: pin);
      if (jobData == null) {
        // PIN mismatch
        state = const AsyncValue.data(null);
        return false;
      }

      // Step 2: Queue the mutations via SyncService (offline-safe)
      await _syncService.addAction(ActionType.verifyDelivery, jobData);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final tripActionNotifierProvider =
    StateNotifierProvider.autoDispose<TripActionNotifier, AsyncValue<void>>(
  (ref) => TripActionNotifier(
    ref.watch(deliveryRepositoryProvider),
    ref.watch(syncServiceProvider),
  ),
);

// ══════════════════════════════════════════════════════════════════════════════
// SUPPLIER BID MANAGEMENT
// ══════════════════════════════════════════════════════════════════════════════

/// Fetches all bids for a supplier's delivery job.
/// Auto-refreshes via Supabase realtime. On web uses mock data.
final jobBidsProvider =
    FutureProvider.autoDispose.family<List<DeliveryBid>, String>((ref, jobId) async {
  if (kIsWeb) return mockDeliveryBids.where((b) => b.jobId == jobId).toList();
  ref.watch(deliveryBidsRealtimeProvider);
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getJobBids(jobId);
});

/// Fetches supplier's delivery jobs (for bid management dashboard).
/// On web uses mock data (same as supplier_dashboard_providers).
final supplierDeliveryJobsProvider =
    FutureProvider.autoDispose<List<DeliveryJob>>((ref) async {
  if (kIsWeb) return mockDeliveryJobs;
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getSupplierJobs();
});

/// Accept bid notifier.
class AcceptBidNotifier extends StateNotifier<AsyncValue<void>> {
  final DeliveryRepository _repo;

  AcceptBidNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> acceptBid({
    required String bidId,
    required String jobId,
    required String driverId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.acceptBid(bidId, jobId, driverId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final acceptBidNotifierProvider =
    StateNotifierProvider.autoDispose<AcceptBidNotifier, AsyncValue<void>>(
  (ref) => AcceptBidNotifier(ref.watch(deliveryRepositoryProvider)),
);

/// Delivery PIN for retailer to see (for their order's delivery job).
/// On web uses mock data.
final deliveryPinProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, jobId) async {
  if (kIsWeb) {
    try {
      return mockDeliveryJobs.firstWhere((j) => j.id == jobId).deliveryPin;
    } catch (_) {
      return null;
    }
  }
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveryPin(jobId);
});
