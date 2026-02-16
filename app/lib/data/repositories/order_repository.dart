import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';

/// Repository for Order ("Digital Bon") operations.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(supabaseClientProvider));
});

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository(this._client);

  /// Fetch orders for the logged-in retailer.
  Future<List<Order>> getRetailerOrders({String? status}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _client
        .from(SupabaseConstants.ordersTable)
        .select('''
          *,
          supplier:supplier_id(shop_name),
          retailer:retailer_id(shop_name)
        ''')
        .eq('retailer_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Order.fromJson(e)).toList();
  }

  /// Fetch orders for the logged-in supplier.
  Future<List<Order>> getSupplierOrders({String? status}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    var query = _client
        .from(SupabaseConstants.ordersTable)
        .select('''
          *,
          supplier:supplier_id(shop_name),
          retailer:retailer_id(shop_name)
        ''')
        .eq('supplier_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Order.fromJson(e)).toList();
  }

  /// Get a single order by ID.
  Future<Order?> getById(String id) async {
    final response = await _client
        .from(SupabaseConstants.ordersTable)
        .select('''
          *,
          supplier:supplier_id(shop_name),
          retailer:retailer_id(shop_name)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Order.fromJson(response);
  }

  /// Create a new order (Retailer places order).
  Future<Order> create(Order order) async {
    final response = await _client
        .from(SupabaseConstants.ordersTable)
        .insert(order.toJson())
        .select()
        .single();

    return Order.fromJson(response);
  }

  /// Update order status (Supplier confirms, ships, etc.).
  Future<void> updateStatus(String orderId, String newStatus) async {
    await _client
        .from(SupabaseConstants.ordersTable)
        .update({'status': newStatus})
        .eq('id', orderId);
  }

  /// Partial receipt: Retailer adjusts quantities and sets adjusted_total.
  /// This is the critical "Partial Receipt" feature from PROJECT_CONTEXT.md.
  Future<void> confirmPartialReceipt(
    String orderId, {
    required List<Map<String, dynamic>> adjustedItems,
    required double adjustedTotal,
  }) async {
    await _client
        .from(SupabaseConstants.ordersTable)
        .update({
          'items': adjustedItems,
          'adjusted_total': adjustedTotal,
          'status': 'delivered',
        })
        .eq('id', orderId);
  }

  /// Assign a driver to an order (Supplier action).
  Future<void> assignDriver(String orderId, String driverName) async {
    await _client
        .from(SupabaseConstants.ordersTable)
        .update({
          'driver_name': driverName,
          'delivery_type': 'in_house',
        })
        .eq('id', orderId);
  }
}
