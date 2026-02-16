import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/product.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// CART PROVIDERS — Shopping cart state for the Retailer ordering flow.
///
/// Architecture:
///   - Cart is scoped per supplier via supplierId key in CartItem.
///   - CartNotifier manages a Map<String, CartItem> keyed by productId.
///   - Tiered pricing is resolved live: changing quantity recalculates unitPrice.
///   - On confirm, items are mapped to OrderItem JSONB and inserted as a new
///     Order with status='pending'.
///
/// Flow:
///   1. Retailer browses catalog → taps "Add to Cart" on ProductCard
///   2. CartNotifier.addItem() adds or increments the item
///   3. Retailer taps "Nouvelle Commande" FAB or cart icon → CartScreen
///   4. CartScreen shows summary → "Confirm" → creates Order → clears cart
/// ══════════════════════════════════════════════════════════════════════════════

/// A single item in the shopping cart.
class CartItem extends Equatable {
  final String productId;
  final String supplierId;
  final String productName;
  final int quantity;
  final double unitPrice; // resolved tiered price for current quantity
  final Product product; // full product for tier recalculation

  const CartItem({
    required this.productId,
    required this.supplierId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.product,
  });

  /// Line total = quantity × unit price (already tier-resolved).
  double get lineTotal => quantity * unitPrice;

  CartItem copyWith({
    int? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      productId: productId,
      supplierId: supplierId,
      productName: productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      product: product,
    );
  }

  @override
  List<Object?> get props => [productId, supplierId, quantity, unitPrice];
}

/// State notifier for the shopping cart.
///
/// Cart items are stored in a Map<productId, CartItem>.
/// All items in a cart share the same supplierId (one supplier per order).
class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  CartNotifier() : super({});

  /// Add a product to the cart (or increment its quantity).
  /// Resolves tiered price for the new quantity.
  void addItem(Product product, String supplierId, {int quantity = 1}) {
    final existing = state[product.id];
    final newQty = (existing?.quantity ?? 0) + quantity;
    final tieredPrice = product.priceForQuantity(newQty);

    state = {
      ...state,
      product.id: CartItem(
        productId: product.id,
        supplierId: supplierId,
        productName: product.name,
        quantity: newQty,
        unitPrice: tieredPrice,
        product: product,
      ),
    };

    // Recalculate all items in case tiered prices changed
    _recalculatePrices();
  }

  /// Set the exact quantity for a product.
  void setQuantity(String productId, int quantity) {
    final item = state[productId];
    if (item == null) return;

    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final tieredPrice = item.product.priceForQuantity(quantity);
    state = {
      ...state,
      productId: item.copyWith(quantity: quantity, unitPrice: tieredPrice),
    };
  }

  /// Increment quantity by 1.
  void increment(String productId) {
    final item = state[productId];
    if (item == null) return;
    setQuantity(productId, item.quantity + 1);
  }

  /// Decrement quantity by 1 (removes item if qty reaches 0).
  void decrement(String productId) {
    final item = state[productId];
    if (item == null) return;
    setQuantity(productId, item.quantity - 1);
  }

  /// Remove a product from the cart.
  void removeItem(String productId) {
    state = Map.from(state)..remove(productId);
  }

  /// Clear the entire cart.
  void clear() {
    state = {};
  }

  /// Recalculate tiered prices for all items.
  void _recalculatePrices() {
    final updated = <String, CartItem>{};
    for (final entry in state.entries) {
      final item = entry.value;
      final tieredPrice = item.product.priceForQuantity(item.quantity);
      updated[entry.key] = item.copyWith(unitPrice: tieredPrice);
    }
    state = updated;
  }
}

/// The cart state provider.
final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartItem>>(
  (ref) => CartNotifier(),
);

/// Cart items as a list (for display).
final cartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(cartProvider).values.toList();
});

/// Total number of items in the cart.
final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.values.fold(0, (sum, item) => sum + item.quantity);
});

/// Total price of all items in the cart (with tiered pricing).
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.values.fold(0.0, (sum, item) => sum + item.lineTotal);
});

/// The supplier ID for the current cart (all items must be from same supplier).
final cartSupplierIdProvider = Provider<String?>((ref) {
  final items = ref.watch(cartProvider);
  if (items.isEmpty) return null;
  return items.values.first.supplierId;
});

/// Notes for the order (optional retailer message).
final cartNotesProvider = StateProvider<String>((ref) => '');
