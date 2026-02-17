import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';
import 'base_repository.dart';

/// Repository for Product catalog operations.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(supabaseClientProvider));
});

class ProductRepository with SupabaseErrorHandler {
  final SupabaseClient _client;

  ProductRepository(this._client);

  /// Fetch products for a specific supplier.
  /// Supports compatibility filter (phone model search).
  Future<List<Product>> getSupplierProducts(
    String supplierId, {
    String? compatibilityFilter,
    bool newArrivalsOnly = false,
  }) => guard(() async {
    var query = _client
        .from(SupabaseConstants.productsTable)
        .select()
        .eq('supplier_id', supplierId)
        .eq('is_active', true);

    if (newArrivalsOnly) {
      query = query.eq('is_new', true);
    }

    // Compatibility filter: uses PostgreSQL @> (array contains) operator
    if (compatibilityFilter != null && compatibilityFilter.isNotEmpty) {
      query = query.contains('compatibility_list', [compatibilityFilter]);
    }

    final response = await query.order('is_new', ascending: false);

    return (response as List).map((e) => Product.fromJson(e)).toList();
  });

  /// Search products by name or compatibility across a supplier's catalog.
  Future<List<Product>> searchProducts(
    String supplierId,
    String searchTerm,
  ) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.productsTable)
        .select()
        .eq('supplier_id', supplierId)
        .eq('is_active', true)
        .or('name.ilike.%$searchTerm%,compatibility_list.cs.{$searchTerm}')
        .order('is_new', ascending: false);

    return (response as List).map((e) => Product.fromJson(e)).toList();
  });

  /// Get a single product by ID.
  Future<Product?> getById(String id) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.productsTable)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Product.fromJson(response);
  });

  /// Create a new product (Supplier only).
  Future<Product> create(Product product) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.productsTable)
        .insert(product.toJson())
        .select()
        .single();

    return Product.fromJson(response);
  });

  /// Update a product (Supplier only).
  Future<void> update(Product product) => guard(() async {
    await _client
        .from(SupabaseConstants.productsTable)
        .update(product.toJson())
        .eq('id', product.id);
  });

  /// Bulk update prices for multiple products.
  /// Used by the Supplier Bulk Price Adjustment feature.
  Future<void> bulkUpdatePrices(Map<String, Map<String, double>> updates) => guard(() async {
    // updates: { productId: { "1": 15.0, "10": 12.0, "50": 10.0 } }
    for (final entry in updates.entries) {
      await _client
          .from(SupabaseConstants.productsTable)
          .update({'price_tiers': entry.value})
          .eq('id', entry.key);
    }
  });

  /// Get all distinct brands for a supplier (for filter chips).
  Future<List<String>> getDistinctBrands(String supplierId) => guard(() async {
    final response = await _client
        .from(SupabaseConstants.productsTable)
        .select('brand')
        .eq('supplier_id', supplierId)
        .eq('is_active', true)
        .not('brand', 'is', null);

    final brands = (response as List)
        .map((e) => e['brand'] as String?)
        .where((b) => b != null && b.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    return brands..sort();
  });
}
