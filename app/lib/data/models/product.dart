import 'package:equatable/equatable.dart';
import '../../core/utils/formatters.dart';

/// Product model — maps to `public.products`.
///
/// Key features from PROJECT_CONTEXT.md:
///   - Tiered Pricing: JSONB `price_tiers` {"1": 15.0, "10": 12.0, "50": 10.0}
///   - Compatibility Filter: TEXT[] of phone models
///   - "Nouveau / جديد" tag for new arrivals
class Product extends Equatable {
  final String id;
  final String supplierId;
  final String name;
  final String? description;
  final String? brand;
  final String? imageUrl;
  final List<String> compatibilityList; // e.g. ['Samsung A54', 'iPhone 13']
  final Map<String, dynamic> priceTiers; // {"1": 15.0, "10": 12.0, "50": 10.0}
  final bool isNew; // "Nouveau / جديد" tag
  final bool isActive;
  final int stockQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.supplierId,
    required this.name,
    this.description,
    this.brand,
    this.imageUrl,
    required this.compatibilityList,
    required this.priceTiers,
    required this.isNew,
    required this.isActive,
    required this.stockQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the unit price for a given quantity using tiered pricing logic.
  ///
  /// From PROJECT_CONTEXT.md:
  ///   "The app must look for the highest key that is ≤ the current cart quantity."
  double priceForQuantity(int qty) {
    return Formatters.resolveTieredPrice(priceTiers, qty);
  }

  /// The base/retail price (Tier 1, qty=1).
  double get basePrice => priceForQuantity(1);

  /// Whether this product is in stock.
  bool get inStock => stockQuantity > 0;

  /// Sorted list of tier thresholds for display.
  List<MapEntry<int, double>> get sortedTiers {
    final entries = priceTiers.entries
        .map((e) => MapEntry(int.tryParse(e.key) ?? 0, (e.value as num).toDouble()))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      imageUrl: json['image_url'] as String?,
      compatibilityList: List<String>.from(json['compatibility_list'] ?? []),
      priceTiers: Map<String, dynamic>.from(json['price_tiers'] ?? {}),
      isNew: json['is_new'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'name': name,
      'description': description,
      'brand': brand,
      'image_url': imageUrl,
      'compatibility_list': compatibilityList,
      'price_tiers': priceTiers,
      'is_new': isNew,
      'is_active': isActive,
      'stock_quantity': stockQuantity,
    };
  }

  Product copyWith({
    String? name,
    String? description,
    String? brand,
    String? imageUrl,
    List<String>? compatibilityList,
    Map<String, dynamic>? priceTiers,
    bool? isNew,
    bool? isActive,
    int? stockQuantity,
  }) {
    return Product(
      id: id,
      supplierId: supplierId,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      compatibilityList: compatibilityList ?? this.compatibilityList,
      priceTiers: priceTiers ?? this.priceTiers,
      isNew: isNew ?? this.isNew,
      isActive: isActive ?? this.isActive,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, supplierId, priceTiers];
}
