import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/delivery_job.dart';
import '../models/delivery_bid.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';

/// Repository for Delivery Jobs & Bids (InDrive-style marketplace).
final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.watch(supabaseClientProvider));
});

class DeliveryRepository {
  final SupabaseClient _client;

  DeliveryRepository(this._client);

  // ══════════════════════════════════════════════════════════════════════════
  // DELIVERY JOBS
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch open delivery jobs (for Driver marketplace).
  Future<List<DeliveryJob>> getOpenJobs() async {
    final response = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name)
        ''')
        .eq('status', 'open')
        .order('created_at', ascending: false);

    return (response as List).map((e) => DeliveryJob.fromJson(e)).toList();
  }

  /// Fetch jobs assigned to the current driver.
  Future<List<DeliveryJob>> getDriverJobs() async {
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
  }

  /// Fetch delivery jobs for a supplier.
  Future<List<DeliveryJob>> getSupplierJobs({String? status}) async {
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
  }

  /// Create a new delivery job (Supplier action).
  Future<DeliveryJob> createJob(DeliveryJob job) async {
    final response = await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .insert(job.toJson())
        .select()
        .single();

    return DeliveryJob.fromJson(response);
  }

  /// Update job status.
  Future<void> updateJobStatus(String jobId, String newStatus) async {
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({'status': newStatus})
        .eq('id', jobId);
  }

  /// Assign a driver to a job (either trusted or bid winner).
  Future<void> assignDriver(String jobId, String driverId) async {
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({
          'assigned_driver_id': driverId,
          'status': 'assigned',
        })
        .eq('id', jobId);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELIVERY BIDS
  // ══════════════════════════════════════════════════════════════════════════

  /// Place a bid on a delivery job (Driver action).
  Future<DeliveryBid> placeBid({
    required String jobId,
    required double bidAmount,
    String? estimatedTime,
    String? message,
  }) async {
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
  }

  /// Fetch bids for a specific job (Supplier views bids).
  Future<List<DeliveryBid>> getJobBids(String jobId) async {
    final response = await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .select('''
          *,
          driver:driver_id(shop_name, phone, city)
        ''')
        .eq('job_id', jobId)
        .order('bid_amount', ascending: true);

    return (response as List).map((e) => DeliveryBid.fromJson(e)).toList();
  }

  /// Accept a bid (Supplier action).
  /// Updates bid status and assigns driver to the job.
  Future<void> acceptBid(String bidId, String jobId, String driverId) async {
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
    await _client
        .from(SupabaseConstants.deliveryJobsTable)
        .update({
          'assigned_driver_id': driverId,
          'status': 'bidding_closed',
        })
        .eq('id', jobId);
  }

  /// Withdraw a bid (Driver action).
  Future<void> withdrawBid(String bidId) async {
    await _client
        .from(SupabaseConstants.deliveryBidsTable)
        .update({'status': 'withdrawn'})
        .eq('id', bidId);
  }
}
