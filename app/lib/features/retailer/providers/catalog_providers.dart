import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/product.dart';
import '../../../data/models/supplier_retailer_relation.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/relation_repository.dart';
import '../../../data/services/offline_read_cache.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATE: Which supplier catalog we're viewing
// ─────────────────────────────────────────────────────────────────────────────

/// The supplier ID whose catalog is currently being viewed.
final catalogSupplierIdProvider = StateProvider<String>((ref) => '');

// ─────────────────────────────────────────────────────────────────────────────
// STATE: Brand filtering
// ─────────────────────────────────────────────────────────────────────────────

/// Currently selected brand filter (null = show all).
final selectedBrandProvider = StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// STATE: Model selector
// ─────────────────────────────────────────────────────────────────────────────

/// Currently selected phone model for compatibility filtering (null = all).
final selectedModelProvider = StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// STATE: Search
// ─────────────────────────────────────────────────────────────────────────────

/// Search query text.
final catalogSearchQueryProvider = StateProvider<String>((ref) => '');

// ─────────────────────────────────────────────────────────────────────────────
// DATA: Available brands for filter chips
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all distinct brands for the current supplier.
/// Used to render the horizontal brand filter chip row.
final catalogBrandsProvider = FutureProvider<List<String>>((ref) async {
  final supplierId = ref.watch(catalogSupplierIdProvider);
  if (supplierId.isEmpty) return [];

  if (kIsWeb) {
    final brands = mockProducts
        .map((p) => p.brand)
        .where((b) => b != null && b!.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    brands.sort();
    return brands;
  }
  final repo = ref.watch(productRepositoryProvider);
  return repo.getDistinctBrands(supplierId);
});

// ─────────────────────────────────────────────────────────────────────────────
// DATA: Filtered product list
// ─────────────────────────────────────────────────────────────────────────────

/// The main product list — filtered by brand + compatibility + search.
///
/// Priority logic:
///   1. If search query is non-empty → use searchProducts()
///   2. Else → use getSupplierProducts() with compatibility filter
///   3. Then client-side filter by selected brand
final catalogProductsProvider = FutureProvider<List<Product>>((ref) async {
  final supplierId = ref.watch(catalogSupplierIdProvider);
  if (supplierId.isEmpty) return [];

  if (kIsWeb) {
    List<Product> products = mockProducts
        .where((p) => p.supplierId == supplierId && p.isActive)
        .toList();
    final searchQuery = ref.watch(catalogSearchQueryProvider);
    final selectedBrand = ref.watch(selectedBrandProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.compatibilityList.any(
                  (c) => c.toLowerCase().contains(q)))
          .toList();
    }
    if (selectedModel != null && selectedModel.isNotEmpty) {
      products = products
          .where((p) => p.compatibilityList.any((c) =>
              c.toLowerCase().contains(selectedModel.toLowerCase())))
          .toList();
    }
    if (selectedBrand != null) {
      products = products
          .where((p) =>
              p.brand?.toLowerCase() == selectedBrand.toLowerCase())
          .toList();
    }
    return products;
  }

  final repo = ref.watch(productRepositoryProvider);
  final searchQuery = ref.watch(catalogSearchQueryProvider);
  final selectedBrand = ref.watch(selectedBrandProvider);
  final selectedModel = ref.watch(selectedModelProvider);

  List<Product> products;
  try {
    if (searchQuery.isNotEmpty) {
      products = await repo.searchProducts(supplierId, searchQuery);
    } else {
      products = await repo.getSupplierProducts(
        supplierId,
        compatibilityFilter: selectedModel,
      );
    }
    await OfflineReadCache.saveCatalog(supplierId, products);
  } catch (_) {
    final cached = OfflineReadCache.getCatalog(supplierId);
    if (cached != null && cached.isNotEmpty) {
      products = cached;
    } else {
      rethrow;
    }
  }

  if (selectedBrand != null) {
    products = products
        .where((p) =>
            p.brand?.toLowerCase() == selectedBrand.toLowerCase())
        .toList();
  }

  return products;
});

// ─────────────────────────────────────────────────────────────────────────────
// DATA: Phone models for the model dropdown
// ─────────────────────────────────────────────────────────────────────────────

/// All unique phone models across the supplier's active products.
/// Derived from compatibility_list arrays of all products.
final catalogModelsProvider = FutureProvider<List<String>>((ref) async {
  final supplierId = ref.watch(catalogSupplierIdProvider);
  if (supplierId.isEmpty) return [];

  if (kIsWeb) {
    final models = <String>{};
    for (final p in mockProducts.where((e) => e.supplierId == supplierId)) {
      models.addAll(p.compatibilityList);
    }
    final sorted = models.toList()..sort();
    return sorted;
  }
  final repo = ref.watch(productRepositoryProvider);
  final allProducts = await repo.getSupplierProducts(supplierId);
  final models = <String>{};
  for (final product in allProducts) {
    models.addAll(product.compatibilityList);
  }
  final sorted = models.toList()..sort();
  return sorted;
});

// ─────────────────────────────────────────────────────────────────────────────
// DATA: Supplier-Retailer relation for credit limit tracking
// ─────────────────────────────────────────────────────────────────────────────

/// The relation ID for the currently viewed supplier catalog.
final catalogRelationIdProvider = StateProvider<String?>((ref) => null);

/// Fetches the SupplierRetailerRelation for the current catalog supplier.
/// Provides credit_limit and current_balance for the sticky bottom bar.
final catalogRelationProvider =
    FutureProvider<SupplierRetailerRelation?>((ref) async {
  final relationId = ref.watch(catalogRelationIdProvider);
  if (relationId == null || relationId.isEmpty) return null;

  if (kIsWeb) {
    try {
      return mockRelations.firstWhere((r) => r.id == relationId);
    } catch (_) {
      return null;
    }
  }
  final repo = ref.watch(relationRepositoryProvider);
  return repo.getById(relationId);
});
