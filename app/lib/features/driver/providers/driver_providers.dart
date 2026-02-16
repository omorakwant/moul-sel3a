import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/delivery_job.dart';
import '../../../data/models/delivery_bid.dart';
import '../../../data/repositories/delivery_repository.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DRIVER MARKETPLACE — Open jobs feed
// ══════════════════════════════════════════════════════════════════════════════

/// Fetches all open delivery jobs for the driver marketplace.
final openJobsFeedProvider =
    FutureProvider.autoDispose<List<DeliveryJob>>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getOpenJobs();
});

/// Fetches jobs assigned to the current driver (active trips).
final myActiveJobsProvider =
    FutureProvider.autoDispose<List<DeliveryJob>>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  final jobs = await repo.getDriverJobs();
  // Only show assigned + in_transit (active jobs)
  return jobs
      .where((j) => j.status == 'assigned' || j.status == 'in_transit')
      .toList();
});

/// Fetches a single delivery job by ID.
final deliveryJobByIdProvider =
    FutureProvider.autoDispose.family<DeliveryJob?, String>((ref, jobId) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getJobById(jobId);
});

// ══════════════════════════════════════════════════════════════════════════════
// BIDDING
// ══════════════════════════════════════════════════════════════════════════════

/// Check if current driver already bid on this job.
final myBidForJobProvider =
    FutureProvider.autoDispose.family<DeliveryBid?, String>((ref, jobId) async {
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

  TripActionNotifier(this._repo) : super(const AsyncValue.data(null));

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

  /// Verify PIN and complete delivery.
  /// Returns true if PIN is correct, false otherwise.
  Future<bool> verifyPinAndComplete({
    required String jobId,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repo.verifyPinAndComplete(
        jobId: jobId,
        pin: pin,
      );
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final tripActionNotifierProvider =
    StateNotifierProvider.autoDispose<TripActionNotifier, AsyncValue<void>>(
  (ref) => TripActionNotifier(ref.watch(deliveryRepositoryProvider)),
);

// ══════════════════════════════════════════════════════════════════════════════
// SUPPLIER BID MANAGEMENT
// ══════════════════════════════════════════════════════════════════════════════

/// Fetches all bids for a supplier's delivery job.
final jobBidsProvider =
    FutureProvider.autoDispose.family<List<DeliveryBid>, String>((ref, jobId) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getJobBids(jobId);
});

/// Fetches supplier's delivery jobs (for bid management dashboard).
final supplierDeliveryJobsProvider =
    FutureProvider.autoDispose<List<DeliveryJob>>((ref) async {
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
final deliveryPinProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, jobId) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveryPin(jobId);
});
