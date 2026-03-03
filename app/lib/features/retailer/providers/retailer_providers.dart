import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/supplier_retailer_relation.dart';
import '../../../data/repositories/relation_repository.dart';
import '../../auth/providers/auth_providers.dart';

/// Fetches a single relation by ID. On web (prototype) returns from mock list.
final relationByIdProvider =
    FutureProvider.autoDispose.family<SupplierRetailerRelation?, String>(
        (ref, relationId) async {
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

/// Fetches all supplier relations for the logged-in retailer.
/// Each relation = one "Carnet" (rolling debt account with a supplier).
/// On web (prototype), returns mock relations for the mock retailer.
final retailerRelationsProvider =
    FutureProvider<List<SupplierRetailerRelation>>((ref) async {
  if (kIsWeb) {
    final mockUser = ref.read(mockCurrentUserProvider);
    return mockRelations
        .where((r) => r.retailerId == mockUser.id)
        .toList();
  }
  final repo = ref.watch(relationRepositoryProvider);
  return repo.getRetailerRelations();
});

/// Total debt across all suppliers (for the header summary card).
final retailerTotalDebtProvider = Provider<double>((ref) {
  final relationsAsync = ref.watch(retailerRelationsProvider);
  return relationsAsync.when(
    data: (relations) =>
        relations.fold(0.0, (sum, r) => sum + r.currentBalance),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Number of active supplier accounts.
final retailerSupplierCountProvider = Provider<int>((ref) {
  final relationsAsync = ref.watch(retailerRelationsProvider);
  return relationsAsync.when(
    data: (relations) => relations.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
