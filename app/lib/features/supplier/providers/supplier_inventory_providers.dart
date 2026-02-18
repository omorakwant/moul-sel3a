import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/storage_service.dart';

// ═════════════════════════════════════════════════════════════════════════════
// SUPPLIER INVENTORY PROVIDERS
//
// Manages the supplier's product catalog CRUD, image upload, and bulk pricing.
// ═════════════════════════════════════════════════════════════════════════════

/// Current supplier's full product list (active + inactive).
final supplierProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await client
      .from(SupabaseConstants.productsTable)
      .select()
      .eq('supplier_id', userId)
      .order('updated_at', ascending: false);

  return (response as List).map((e) => Product.fromJson(e)).toList();
});

/// Distinct brand list for the current supplier (for the brand dropdown).
final supplierBrandsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];
  return repo.getDistinctBrands(userId);
});

/// Common phone models for the compatibility multi-select.
/// Hardcoded for MVP — matches the Derb Ghallef reality.
const kPhoneModels = <String>[
  'iPhone 16 Pro Max',
  'iPhone 16 Pro',
  'iPhone 16',
  'iPhone 15 Pro Max',
  'iPhone 15 Pro',
  'iPhone 15',
  'iPhone 14',
  'iPhone 13',
  'iPhone 12',
  'iPhone 11',
  'Samsung S24 Ultra',
  'Samsung S24',
  'Samsung S23',
  'Samsung A54',
  'Samsung A34',
  'Samsung A24',
  'Samsung A15',
  'Samsung A05',
  'Redmi Note 13',
  'Redmi Note 12',
  'Redmi 13C',
  'OPPO A78',
  'OPPO A58',
  'Tecno Spark 20',
  'Tecno Camon 20',
  'Infinix Hot 40',
  'Huawei Nova 12',
  'Realme C55',
];

/// Common brands for the brand selector.
const kBrands = <String>[
  'Apple',
  'Samsung',
  'Xiaomi',
  'OPPO',
  'Tecno',
  'Infinix',
  'Huawei',
  'Realme',
  'Anker',
  'Baseus',
  'Hoco',
  'Remax',
  'Autre',
];

/// Upload a product image to Supabase Storage.
///
/// Path: {userId}/products/{timestamp}_{filename}
/// Returns the public URL.
final uploadProductImageProvider =
    FutureProvider.family.autoDispose<String, File>((ref, file) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.uploadProductImage(file);
});

/// Create a new product.
final createProductProvider =
    FutureProvider.family.autoDispose<Product, Map<String, dynamic>>(
        (ref, data) async {
  final repo = ref.watch(productRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) throw Exception('Not authenticated');

  final product = Product(
    id: '', // DB generates UUID
    supplierId: userId,
    name: data['name'] as String,
    description: data['description'] as String?,
    brand: data['brand'] as String?,
    imageUrl: data['image_url'] as String?,
    compatibilityList: List<String>.from(data['compatibility_list'] ?? []),
    priceTiers: Map<String, dynamic>.from(data['price_tiers'] ?? {}),
    isNew: data['is_new'] as bool? ?? true,
    isActive: true,
    stockQuantity: data['stock_quantity'] as int? ?? 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final created = await repo.create(product);
  ref.invalidate(supplierProductsProvider);
  return created;
});

/// Update an existing product.
final updateProductProvider =
    FutureProvider.family.autoDispose<void, Product>((ref, product) async {
  final repo = ref.watch(productRepositoryProvider);
  await repo.update(product);
  ref.invalidate(supplierProductsProvider);
});

/// Bulk update price tiers for multiple products.
///
/// PROJECT_CONTEXT.md — "Intelligent Bulk Price Adjustment":
///   - Fixed offset: +/- DH on all tiers
///   - Percentage shift: +/-% on all tiers
///   - Applies to all tiers of selected products
final bulkPriceUpdateProvider = FutureProvider.family
    .autoDispose<void, BulkPriceUpdate>((ref, update) async {
  final repo = ref.watch(productRepositoryProvider);

  final newPriceTiers = <String, Map<String, double>>{};

  for (final product in update.products) {
    final updatedTiers = <String, double>{};

    for (final entry in product.priceTiers.entries) {
      final oldPrice = (entry.value as num).toDouble();
      double newPrice;

      switch (update.mode) {
        case BulkAdjustMode.fixedOffset:
          newPrice = oldPrice + update.value;
          break;
        case BulkAdjustMode.percentage:
          newPrice = oldPrice * (1 + update.value / 100);
          break;
      }

      // Floor to 2 decimals, never go below 0
      newPrice = double.parse(newPrice.clamp(0.0, double.infinity)
          .toStringAsFixed(2));
      updatedTiers[entry.key] = newPrice;
    }

    newPriceTiers[product.id] = updatedTiers;
  }

  await repo.bulkUpdatePrices(newPriceTiers);
  ref.invalidate(supplierProductsProvider);
});

/// Toggle product active status (soft delete).
final toggleProductActiveProvider =
    FutureProvider.family.autoDispose<void, Product>((ref, product) async {
  final client = ref.watch(supabaseClientProvider);
  await client
      .from(SupabaseConstants.productsTable)
      .update({'is_active': !product.isActive})
      .eq('id', product.id);
  ref.invalidate(supplierProductsProvider);
});

/// Toggle "Nouveau / جديد" tag.
final toggleNewArrivalProvider =
    FutureProvider.family.autoDispose<void, Product>((ref, product) async {
  final client = ref.watch(supabaseClientProvider);
  await client
      .from(SupabaseConstants.productsTable)
      .update({'is_new': !product.isNew})
      .eq('id', product.id);
  ref.invalidate(supplierProductsProvider);
});

// ═════════════════════════════════════════════════════════════════════════════
// BULK ADJUSTMENT TYPES
// ═════════════════════════════════════════════════════════════════════════════

enum BulkAdjustMode {
  /// Add/subtract a fixed DH amount to every tier
  fixedOffset,

  /// Multiply every tier by (1 + value/100)
  percentage,
}

class BulkPriceUpdate {
  final List<Product> products;
  final BulkAdjustMode mode;

  /// For fixedOffset: the DH amount (+10 or -5).
  /// For percentage: the percent (+5 or -10).
  final double value;

  const BulkPriceUpdate({
    required this.products,
    required this.mode,
    required this.value,
  });

  /// Preview the price change for a single product's tiers.
  Map<String, double> previewTiers(Product product) {
    final result = <String, double>{};
    for (final entry in product.priceTiers.entries) {
      final oldPrice = (entry.value as num).toDouble();
      double newPrice;

      switch (mode) {
        case BulkAdjustMode.fixedOffset:
          newPrice = oldPrice + value;
          break;
        case BulkAdjustMode.percentage:
          newPrice = oldPrice * (1 + value / 100);
          break;
      }

      result[entry.key] =
          double.parse(newPrice.clamp(0.0, double.infinity).toStringAsFixed(2));
    }
    return result;
  }
}
