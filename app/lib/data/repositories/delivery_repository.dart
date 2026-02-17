import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/delivery_job.dart';
import '../models/delivery_bid.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import 'base_repository.dart';

/// Repository for Delivery Jobs & Bids (InDrive-style marketplace).
final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.watch(supabaseClientProvider));
});

class DeliveryRepository with SupabaseErrorHandler {
  final SupabaseClient _client;

  DeliveryRepository(this._client);

  // ══════════════════════════════════════════════════════════════════════════
  // DELIVERY JOBS
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch open delivery jobs (for Driver marketplace).
  Future<List<DeliveryJob>> getOpenJobs() => guard(() async {
    final response = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name)
        ''')
        .eq('status', 'open')
        .order('created_at', ascending: false);

    return (response as List).map((e) => DeliveryJob.fromJson(e)).toList();
  });

  /// Fetch jobs assigned to the current driver.
  Future<List<DeliveryJob>> getDriverJobs() => guard(() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name)
        ''')
        .eq('assigned_driver_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => DeliveryJob.fromJson(e)).toList();
  });

  /// Fetch a single delivery job by ID.
  Future<DeliveryJob?> getJobById(String jobId) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name),
          driver:assigned_driver_id(shop_name, phone)
        ''')
        .eq('id', jobId)
        .maybeSingle();

    if (response == null) return null;
    return DeliveryJob.fromJson(response);
  });

  /// Fetch delivery jobs for a supplier.
  Future<List<DeliveryJob>> getSupplierJobs({String? status}) => guard(() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _client
        .from(SupabaseConstants.deliveryJobsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name),
          driver:assigned_driver_id(shop_name, phone)
        ''')
        .eq('supplier_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => DeliveryJob.fromJson(e)).toList();
  });

  /// Create a new delivery job (Supplier action).
  Future<DeliveryJob> createJob(DeliveryJob job) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .insert(job.toJson())
        .select()
        .single();

    return DeliveryJob.fromJson(response);
  });

  /// Update job status.
  Future<void> updateJobStatus(String jobId, String newStatus) => guard(() async {
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({'status': newStatus})
        .eq('id', jobId);
  });

  /// Assign a driver to a job (either trusted or bid winner).
  Future<void> assignDriver(String jobId, String driverId) => guard(() async {
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({
          'assigned_driver_id': driverId,
          'status': 'assigned',
        })
        .eq('id', jobId);
  });

  /// Mark job as in_transit (Driver starts the trip).
  Future<void> startTrip(String jobId) => guard(() async {
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({'status': 'in_transit'})
        .eq('id', jobId);
  });

  /// Verify the delivery PIN and complete the handshake.
  ///
  /// Flow:
  ///   1. Driver collects 4-digit PIN from retailer
  ///   2. Verify PIN matches delivery_jobs.delivery_pin
  ///   3. If match → mark job as 'completed', order as 'delivered'
  ///   4. If COD → create verified ledger entry (payment_decrease)
  ///
  /// Returns true if PIN is correct, false otherwise.
  Future<bool> verifyPinAndComplete({
    required String jobId,
    required String pin,
  }) => guard(() async {
    // 1. Fetch the job to verify PIN
    final jobResponse = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .select('*, orders!inner(relation_id)')
        .eq('id', jobId)
        .single();

    final storedPin = jobResponse['delivery_pin'] as String?;
    if (storedPin == null || storedPin != pin) {
      return false; // PIN mismatch
    }

    final orderId = jobResponse['order_id'] as String;
    final jobType = jobResponse['job_type'] as String;
    final codAmount = jobResponse['cod_amount'] as num?;

    // 2. Mark delivery job as completed
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({'status': 'completed'})
        .eq('id', jobId);

    // 3. Mark order as delivered
    await _client
        .from(SupabaseConstants.ordersTable)
        .update({'status': 'delivered'})
        .eq('id', orderId);

    // 4. If COD, create a verified payment ledger entry
    if (jobType == 'cod' && codAmount != null && codAmount > 0) {
      final relationId = (jobResponse['orders'] as Map<String, dynamic>)['relation_id'] as String;

      await _client
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

    return true;
  });

  /// Get the delivery PIN for a job (Retailer sees this to share with driver).
  Future<String?> getDeliveryPin(String jobId) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .select('delivery_pin')
        .eq('id', jobId)
        .maybeSingle();

    return response?['delivery_pin'] as String?;
  });

  // ══════════════════════════════════════════════════════════════════════
  // DELIVERY BIDS
  // ══════════════════════════════════════════════════════════════════════

  /// Place a bid on a delivery job (Driver action).
  Future<DeliveryBid> placeBid({
    required String jobId,
    required double bidAmount,
    String? estimatedTime,
    String? message,
  }) => guard(() async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .insert({
          'job_id': jobId,
          'driver_id': userId,
          'bid_amount': bidAmount,
          'estimated_time': estimatedTime,
          'message': message,
          'status': 'pending',
        })
        .select()
        .single();

    return DeliveryBid.fromJson(response);
  });

  /// Check if the current driver already bid on a job.
  Future<DeliveryBid?> getMyBidForJob(String jobId) => guard(() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .select()
        .eq('job_id', jobId)
        .eq('driver_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return DeliveryBid.fromJson(response);
  });

  /// Fetch bids for a specific job (Supplier views bids).
  Future<List<DeliveryBid>> getJobBids(String jobId) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .select('''
          *,
          driver:driver_id(shop_name, phone, city)
        ''')
        .eq('job_id', jobId)
        .order('bid_amount', ascending: true);

    return (response as List).map((e) => DeliveryBid.fromJson(e)).toList();
  });

  /// Accept a bid (Supplier action).
  /// Updates bid status and assigns driver to the job.
  Future<void> acceptBid(String bidId, String jobId, String driverId) => guard(() async {
    // Accept this bid
    await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .update({'status': 'accepted'})
        .eq('id', bidId);

    // Reject all other bids for this job
    await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .update({'status': 'rejected'})
        .eq('job_id', jobId)
        .neq('id', bidId);

    // Assign driver to job and close bidding
    // (triggers trg_generate_delivery_pin → auto-generates 4-digit PIN)
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({
          'assigned_driver_id': driverId,
          'status': 'assigned',
        })
        .eq('id', jobId);
  });

  /// Withdraw a bid (Driver action).
  Future<void> withdrawBid(String bidId) => guard(() async {
    await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .update({'status': 'withdrawn'})
        .eq('id', bidId);
  });
}
