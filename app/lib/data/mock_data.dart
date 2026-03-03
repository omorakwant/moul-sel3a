import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/models.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// MOCK DATA — Frontend-only prototype (L'Carnet B2B).
/// All data is hardcoded; no Supabase/backend. See .cursorrules & prototype.md.
/// ══════════════════════════════════════════════════════════════════════════════

// ── IDs (stable for references) ──
const String _supplierId = 'mock-supplier-001';
const String _retailer1Id = 'mock-retailer-001';
const String _retailer2Id = 'mock-retailer-002';
const String _driverId = 'mock-driver-001';
const String _relation1Id = 'mock-relation-001';
const String _relation2Id = 'mock-relation-002';

final _created = DateTime(2024, 6, 1);
final _updated = DateTime(2025, 2, 15);

// ── Mock Profiles: 1 Supplier, 2 Retailers, 1 Driver ──
final List<Profile> mockProfiles = [
  Profile(
    id: _supplierId,
    shopName: 'Accessoires Pro Casablanca',
    role: 'supplier',
    phone: '+212 5 22 00 00 00',
    city: 'Casablanca',
    locationName: 'Derb Omar, Entrepôt n°12',
    preferredLanguage: 'fr',
    createdAt: _created,
    updatedAt: _updated,
  ),
  Profile(
    id: _retailer1Id,
    shopName: 'Hanout Moulay',
    role: 'retailer',
    phone: '+212 6 61 00 00 01',
    city: 'Rabat',
    locationName: 'Souk Al Had',
    preferredLanguage: 'fr',
    createdAt: _created,
    updatedAt: _updated,
  ),
  Profile(
    id: _retailer2Id,
    shopName: 'Téléphonie Fès',
    role: 'retailer',
    phone: '+212 6 61 00 00 02',
    city: 'Fès',
    locationName: 'Médina',
    preferredLanguage: 'ar',
    createdAt: _created,
    updatedAt: _updated,
  ),
  Profile(
    id: _driverId,
    shopName: 'Kourtia Hassan',
    role: 'driver',
    phone: '+212 6 98 00 00 01',
    city: 'Casablanca',
    locationName: 'Livraisons Casablanca–Rabat',
    preferredLanguage: 'fr',
    createdAt: _created,
    updatedAt: _updated,
  ),
];

/// Supplier-retailer relations with [current_balance] and [credit_limit].
/// Balance is per relation (retailer owes supplier).
final List<SupplierRetailerRelation> mockRelations = [
  SupplierRetailerRelation(
    id: _relation1Id,
    supplierId: _supplierId,
    retailerId: _retailer1Id,
    creditLimit: 15000.0,
    currentBalance: 4250.75,
    status: 'active',
    createdAt: _created,
    updatedAt: _updated,
    supplierName: 'Accessoires Pro Casablanca',
    retailerName: 'Hanout Moulay',
    supplierPhone: '+212 5 22 00 00 00',
  ),
  SupplierRetailerRelation(
    id: _relation2Id,
    supplierId: _supplierId,
    retailerId: _retailer2Id,
    creditLimit: 8000.0,
    currentBalance: 1200.0,
    status: 'active',
    createdAt: _created,
    updatedAt: _updated,
    supplierName: 'Accessoires Pro Casablanca',
    retailerName: 'Téléphonie Fès',
    supplierPhone: '+212 5 22 00 00 00',
  ),
];

// ── Mock Products: 5+ phone accessories, tiered pricing, compatibility ──
final List<Product> mockProducts = [
  Product(
    id: 'mock-product-001',
    supplierId: _supplierId,
    name: 'Coque Silicone iPhone 13/14',
    description: 'Coque silicone souple, plusieurs coloris',
    brand: 'Generic',
    compatibilityList: ['iPhone 13', 'iPhone 14', 'iPhone 13 Pro', 'iPhone 14 Plus'],
    priceTiers: {'1': 15.0, '10': 12.0, '50': 10.0},
    isNew: true,
    isActive: true,
    stockQuantity: 200,
    createdAt: _created,
    updatedAt: _updated,
  ),
  Product(
    id: 'mock-product-002',
    supplierId: _supplierId,
    name: 'Verre Trempé Samsung A54',
    description: 'Protection écran verre trempé 9H',
    brand: 'GlassPro',
    compatibilityList: ['Samsung A54', 'Samsung A34'],
    priceTiers: {'1': 25.0, '10': 20.0, '50': 16.0},
    isNew: false,
    isActive: true,
    stockQuantity: 150,
    createdAt: _created,
    updatedAt: _updated,
  ),
  Product(
    id: 'mock-product-003',
    supplierId: _supplierId,
    name: 'Chargeur Rapide USB-C 20W',
    description: 'Chargeur rapide compatible iPhone et Android',
    brand: 'PowerMax',
    compatibilityList: ['iPhone 12', 'iPhone 13', 'iPhone 14', 'Samsung A54', 'Xiaomi Redmi Note 12'],
    priceTiers: {'1': 45.0, '10': 38.0, '50': 32.0},
    isNew: true,
    isActive: true,
    stockQuantity: 80,
    createdAt: _created,
    updatedAt: _updated,
  ),
  Product(
    id: 'mock-product-004',
    supplierId: _supplierId,
    name: 'Câble Data USB-C vers Lightning',
    description: 'Câble 1m, charge et data',
    brand: 'CablePlus',
    compatibilityList: ['iPhone 8', 'iPhone X', 'iPhone 11', 'iPhone 12', 'iPhone 13', 'iPhone 14'],
    priceTiers: {'1': 22.0, '10': 18.0, '50': 14.0},
    isNew: false,
    isActive: true,
    stockQuantity: 300,
    createdAt: _created,
    updatedAt: _updated,
  ),
  Product(
    id: 'mock-product-005',
    supplierId: _supplierId,
    name: 'Support Voiture Magnétique',
    description: 'Ventouse + support magnétique universel',
    brand: 'CarMount',
    compatibilityList: ['iPhone 13', 'iPhone 14', 'Samsung A54', 'Xiaomi Redmi Note 12', 'Huawei P50'],
    priceTiers: {'1': 35.0, '10': 28.0, '50': 22.0},
    isNew: false,
    isActive: true,
    stockQuantity: 120,
    createdAt: _created,
    updatedAt: _updated,
  ),
  Product(
    id: 'mock-product-006',
    supplierId: _supplierId,
    name: 'Écouteurs Bluetooth TWS',
    description: 'Écouteurs sans fil, autonomie 24h',
    brand: 'SoundBox',
    compatibilityList: ['iPhone 13', 'iPhone 14', 'Samsung A54', 'Xiaomi Redmi Note 12'],
    priceTiers: {'1': 85.0, '10': 72.0, '50': 60.0},
    isNew: true,
    isActive: true,
    stockQuantity: 60,
    createdAt: _created,
    updatedAt: _updated,
  ),
];

// ── Mock Ledger: 3 transactions (debt and payments history) ──
final List<LedgerTransaction> mockLedger = [
  LedgerTransaction(
    id: 'mock-ledger-001',
    relationId: _relation1Id,
    orderId: 'mock-order-001',
    transactionType: 'order_increase',
    amount: 1850.0,
    status: 'verified',
    verifiedAt: DateTime(2025, 2, 1, 10, 0),
    verifiedBy: _supplierId,
    createdAt: DateTime(2025, 2, 1, 9, 30),
    updatedAt: DateTime(2025, 2, 1, 10, 0),
  ),
  LedgerTransaction(
    id: 'mock-ledger-002',
    relationId: _relation1Id,
    orderId: null,
    transactionType: 'payment_decrease',
    amount: 500.0,
    paymentMethod: 'wafacash',
    referenceCode: 'WF-20250205-789',
    status: 'verified',
    verifiedAt: DateTime(2025, 2, 5, 14, 0),
    verifiedBy: _supplierId,
    createdAt: DateTime(2025, 2, 5, 12, 0),
    updatedAt: DateTime(2025, 2, 5, 14, 0),
  ),
  LedgerTransaction(
    id: 'mock-ledger-003',
    relationId: _relation1Id,
    orderId: 'mock-order-002',
    transactionType: 'order_increase',
    amount: 2900.75,
    status: 'verified',
    verifiedAt: DateTime(2025, 2, 10, 11, 0),
    verifiedBy: _supplierId,
    createdAt: DateTime(2025, 2, 10, 10, 45),
    updatedAt: DateTime(2025, 2, 10, 11, 0),
  ),
];

/// Pending ledger transactions for Supplier verification desk (web prototype).
final List<LedgerTransaction> mockPendingVerifications = [
  LedgerTransaction(
    id: 'mock-ledger-pending-001',
    relationId: _relation1Id,
    orderId: null,
    transactionType: 'payment_decrease',
    amount: 750.0,
    paymentMethod: 'wafacash',
    referenceCode: 'WF-20250301-456',
    status: 'pending',
    verifiedAt: null,
    verifiedBy: null,
    createdAt: DateTime(2025, 3, 1, 14, 30),
    updatedAt: DateTime(2025, 3, 1, 14, 30),
  ),
  LedgerTransaction(
    id: 'mock-ledger-pending-002',
    relationId: _relation2Id,
    orderId: null,
    transactionType: 'payment_decrease',
    amount: 300.0,
    paymentMethod: 'cashplus',
    referenceCode: 'CP-20250302-789',
    status: 'pending',
    verifiedAt: null,
    verifiedBy: null,
    createdAt: DateTime(2025, 3, 2, 10, 0),
    updatedAt: DateTime(2025, 3, 2, 10, 0),
  ),
];

// ── Mock Delivery Jobs (Supplier deliveries + Driver marketplace) ──
const String _mockJobOpenId = 'mock-job-open-001';
const String _mockJobAssignedId = 'mock-job-assigned-002';
const String _mockOrder1Id = 'mock-order-001';
const String _mockOrder2Id = 'mock-order-002';

final List<DeliveryJob> mockDeliveryJobs = [
  DeliveryJob(
    id: _mockJobOpenId,
    orderId: _mockOrder2Id,
    supplierId: _supplierId,
    assignedDriverId: null,
    pickupCity: 'Casablanca',
    pickupLocationName: 'Derb Omar, Entrepôt n°12',
    dropoffCity: 'Rabat',
    dropoffLocationName: 'Souk Al Had',
    jobType: 'delivery_only',
    status: 'open',
    deliveryPin: null,
    createdAt: DateTime(2025, 2, 12, 9, 0),
    updatedAt: DateTime(2025, 2, 12, 9, 0),
    supplierName: 'Accessoires Pro Casablanca',
    bidCount: 2,
  ),
  DeliveryJob(
    id: _mockJobAssignedId,
    orderId: _mockOrder1Id,
    supplierId: _supplierId,
    assignedDriverId: _driverId,
    pickupCity: 'Casablanca',
    pickupLocationName: 'Derb Omar, Entrepôt n°12',
    dropoffCity: 'Rabat',
    dropoffLocationName: 'Hanout Moulay',
    jobType: 'delivery_only',
    status: 'in_transit',
    deliveryPin: '4829',
    createdAt: DateTime(2025, 2, 10, 8, 0),
    updatedAt: DateTime(2025, 2, 10, 11, 0),
    supplierName: 'Accessoires Pro Casablanca',
    driverName: 'Kourtia Hassan',
    bidCount: 1,
  ),
];

// ── Mock Delivery Bids (for open job, bid manager demo) ──
final List<DeliveryBid> mockDeliveryBids = [
  DeliveryBid(
    id: 'mock-bid-001',
    jobId: _mockJobOpenId,
    driverId: _driverId,
    bidAmount: 85.0,
    estimatedTime: '2 heures',
    message: 'Dispo maintenant',
    status: 'pending',
    createdAt: DateTime(2025, 2, 12, 9, 30),
    driverName: 'Kourtia Hassan',
    driverPhone: '+212 6 98 00 00 01',
    driverCity: 'Casablanca',
  ),
  DeliveryBid(
    id: 'mock-bid-002',
    jobId: _mockJobOpenId,
    driverId: 'mock-driver-002',
    bidAmount: 95.0,
    estimatedTime: '3 heures',
    message: null,
    status: 'pending',
    createdAt: DateTime(2025, 2, 12, 10, 0),
    driverName: 'Livreur Omar',
    driverPhone: '+212 6 98 00 00 02',
    driverCity: 'Casablanca',
  ),
];

// ── Mock Orders (for retailer "Mes commandes" and order detail) ──
final List<Order> mockOrders = [
  Order(
    id: _mockOrder1Id,
    supplierId: _supplierId,
    retailerId: _retailer1Id,
    relationId: _relation1Id,
    items: [
      OrderItem(
        productId: 'mock-product-001',
        name: 'Coque Silicone iPhone 13/14',
        quantity: 10,
        unitPrice: 12.0,
        lineTotal: 120.0,
      ),
      OrderItem(
        productId: 'mock-product-004',
        name: 'Câble Data USB-C vers Lightning',
        quantity: 5,
        unitPrice: 18.0,
        lineTotal: 90.0,
      ),
    ],
    originalTotal: 210.0,
    adjustedTotal: null,
    driverName: 'Mohammed',
    status: 'delivered',
    deliveryType: 'bid_driver',
    notes: null,
    createdAt: DateTime(2025, 2, 1, 9, 0),
    updatedAt: DateTime(2025, 2, 1, 10, 0),
    supplierName: 'Accessoires Pro Casablanca',
    retailerName: 'Hanout Moulay',
  ),
  Order(
    id: _mockOrder2Id,
    supplierId: _supplierId,
    retailerId: _retailer1Id,
    relationId: _relation1Id,
    items: [
      OrderItem(
        productId: 'mock-product-002',
        name: 'Verre Trempé Samsung A54',
        quantity: 20,
        unitPrice: 20.0,
        lineTotal: 400.0,
      ),
      OrderItem(
        productId: 'mock-product-003',
        name: 'Chargeur Rapide USB-C 20W',
        quantity: 15,
        unitPrice: 38.0,
        lineTotal: 570.0,
      ),
    ],
    originalTotal: 2900.75,
    adjustedTotal: null,
    driverName: 'Hassan',
    status: 'shipped',
    deliveryType: 'bid_driver',
    notes: null,
    createdAt: DateTime(2025, 2, 10, 10, 0),
    updatedAt: DateTime(2025, 2, 10, 11, 0),
    supplierName: 'Accessoires Pro Casablanca',
    retailerName: 'Hanout Moulay',
  ),
];

// ── Riverpod: simulate logged-in user (one of the Retailers) ──

/// Current user when using mock data: simulates being logged in as the first Retailer.
/// Use this in the prototype instead of Supabase-backed [currentProfileProvider].
final mockCurrentUserProvider = Provider<Profile>((ref) {
  final retailer = mockProfiles.firstWhere(
    (p) => p.role == 'retailer',
    orElse: () => mockProfiles.first,
  );
  return retailer;
});

/// Alias: auth provider that simulates being logged in as one of the Retailers (prototype).
final authProvider = mockCurrentUserProvider;

/// Relation for the mock current user (first retailer) with the mock supplier.
/// Use to display "Solde Actuel" and credit limit on the Retailer Dashboard.
final mockCurrentUserRelationProvider = Provider<SupplierRetailerRelation?>((ref) {
  final user = ref.watch(mockCurrentUserProvider);
  try {
    return mockRelations.firstWhere((r) => r.retailerId == user.id);
  } catch (_) {
    return null;
  }
});
