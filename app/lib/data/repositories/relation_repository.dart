import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supplier_retailer_relation.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';

/// Repository for SupplierRetailerRelation ("Le Carnet") operations.
final relationRepositoryProvider = Provider<RelationRepository>((ref) {
  return RelationRepository(ref.watch(supabaseClientProvider));
});

class RelationRepository {
  final SupabaseClient _client;

  RelationRepository(this._client);

  /// Fetch all supplier relations for the logged-in retailer.
  /// Includes supplier profile data for display (shop_name, phone).
  Future<List<SupplierRetailerRelation>> getRetailerRelations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from(SupabaseConstants.relationsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name, phone),
          retailer:retailer_id(shop_name)
        ''')
        .eq('retailer_id', userId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((e) => SupplierRetailerRelation.fromJson(e))
        .toList();
  }

  /// Fetch all retailer relations for the logged-in supplier.
  Future<List<SupplierRetailerRelation>> getSupplierRelations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from(SupabaseConstants.relationsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name),
          retailer:retailer_id(shop_name, phone)
        ''')
        .eq('supplier_id', userId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((e) => SupplierRetailerRelation.fromJson(e))
        .toList();
  }

  /// Get a single relation by ID.
  Future<SupplierRetailerRelation?> getById(String id) async {
    final response = await _client
        .from(SupabaseConstants.relationsTable)
        .select('''
          *,
          supplier:supplier_id(shop_name, phone),
          retailer:retailer_id(shop_name, phone)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return SupplierRetailerRelation.fromJson(response);
  }

  /// Create a new supplier-retailer relation (Supplier only).
  Future<SupplierRetailerRelation> create({
    required String retailerId,
    required double creditLimit,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from(SupabaseConstants.relationsTable)
        .insert({
          'supplier_id': userId,
          'retailer_id': retailerId,
          'credit_limit': creditLimit,
        })
        .select()
        .single();

    return SupplierRetailerRelation.fromJson(response);
  }

  /// Update credit limit or status (Supplier only).
  Future<void> update(String id, {double? creditLimit, String? status}) async {
    final updates = <String, dynamic>{};
    if (creditLimit != null) updates['credit_limit'] = creditLimit;
    if (status != null) updates['status'] = status;

    if (updates.isNotEmpty) {
      await _client
          .from(SupabaseConstants.relationsTable)
          .update(updates)
          .eq('id', id);
    }
  }
}
