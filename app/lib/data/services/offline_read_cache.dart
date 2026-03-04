import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';
import '../models/order.dart';

/// Offline read cache for catalog (products) and orders.
/// Used when connectivity is lost so the retailer can still browse cached data.
/// Not used on web (web uses mock data in memory).
const String _boxName = 'offline_read_cache';

class OfflineReadCache {
  static Box<dynamic>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    if (kIsWeb) return; // No Hive cache on web
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static Box<dynamic>? get box => _box;

  // ── Catalog (products by supplier) ────────────────────────────────────────

  static Future<void> saveCatalog(String supplierId, List<Product> products) async {
    if (_box == null || kIsWeb) return;
    final list = products.map((p) => _productToMap(p)).toList();
    await _box!.put('catalog_$supplierId', list);
  }

  static List<Product>? getCatalog(String supplierId) {
    if (_box == null || kIsWeb) return null;
    final list = _box!.get('catalog_$supplierId') as List<dynamic>?;
    if (list == null) return null;
    try {
      return list
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _productToMap(Product p) {
    return {
      'id': p.id,
      'supplier_id': p.supplierId,
      'name': p.name,
      'description': p.description,
      'brand': p.brand,
      'image_url': p.imageUrl,
      'compatibility_list': p.compatibilityList,
      'price_tiers': p.priceTiers,
      'is_new': p.isNew,
      'is_active': p.isActive,
      'stock_quantity': p.stockQuantity,
      'created_at': p.createdAt.toIso8601String(),
      'updated_at': p.updatedAt.toIso8601String(),
    };
  }

  // ── Orders (by retailer) ──────────────────────────────────────────────────

  static Future<void> saveOrders(String retailerId, List<Order> orders) async {
    if (_box == null || kIsWeb) return;
    final list = orders.map((o) => _orderToMap(o)).toList();
    await _box!.put('orders_$retailerId', list);
  }

  static List<Order>? getOrders(String retailerId) {
    if (_box == null || kIsWeb) return null;
    final list = _box!.get('orders_$retailerId') as List<dynamic>?;
    if (list == null) return null;
    try {
      return list
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _orderToMap(Order o) {
    return {
      'id': o.id,
      'supplier_id': o.supplierId,
      'retailer_id': o.retailerId,
      'relation_id': o.relationId,
      'items': o.items.map((e) => e.toJson()).toList(),
      'original_total': o.originalTotal,
      if (o.adjustedTotal != null) 'adjusted_total': o.adjustedTotal,
      if (o.driverName != null) 'driver_name': o.driverName,
      'status': o.status,
      if (o.deliveryType != null) 'delivery_type': o.deliveryType,
      if (o.notes != null) 'notes': o.notes,
      'created_at': o.createdAt.toIso8601String(),
      'updated_at': o.updatedAt.toIso8601String(),
    };
  }
}
