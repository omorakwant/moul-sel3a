import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/supplier_retailer_relation.dart';
import '../../../data/repositories/relation_repository.dart';

/// Fetches all supplier relations for the logged-in retailer.
/// Each relation = one "Carnet" (rolling debt account with a supplier).
final retailerRelationsProvider =
    FutureProvider<List<SupplierRetailerRelation>>((ref) async {
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
