import 'package:flutter_test/flutter_test.dart';
import 'package:lcarnet_b2b/data/models/profile.dart';
import 'package:lcarnet_b2b/data/models/product.dart';
import 'package:lcarnet_b2b/data/models/order.dart';
import 'package:lcarnet_b2b/data/models/ledger_transaction.dart';
import 'package:lcarnet_b2b/data/models/delivery_job.dart';
import 'package:lcarnet_b2b/data/models/delivery_bid.dart';
import 'package:lcarnet_b2b/data/models/cart_item.dart';
import 'package:lcarnet_b2b/data/models/supplier_retailer_relation.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════

  group('Profile', () {
    final profileJson = {
      'id': 'user-123',
      'shop_name': 'Boutique Youssef',
      'role': 'retailer',
      'phone': '0612345678',
      'city': 'Casablanca',
      'location_name': 'Derb Omar',
      'avatar_url': 'https://example.com/avatar.jpg',
      'preferred_language': 'fr',
      'created_at': '2026-01-15T10:00:00Z',
      'updated_at': '2026-02-18T12:30:00Z',
    };

    test('fromJson parses all fields', () {
      final p = Profile.fromJson(profileJson);
      expect(p.id, 'user-123');
      expect(p.shopName, 'Boutique Youssef');
      expect(p.role, 'retailer');
      expect(p.phone, '0612345678');
      expect(p.city, 'Casablanca');
      expect(p.locationName, 'Derb Omar');
      expect(p.avatarUrl, 'https://example.com/avatar.jpg');
      expect(p.preferredLanguage, 'fr');
    });

    test('fromJson defaults preferredLanguage to fr', () {
      final json = Map<String, dynamic>.from(profileJson);
      json.remove('preferred_language');
      final p = Profile.fromJson(json);
      expect(p.preferredLanguage, 'fr');
    });

    test('isSupplier/isRetailer/isDriver role checks', () {
      final retailer = Profile.fromJson(profileJson);
      expect(retailer.isRetailer, isTrue);
      expect(retailer.isSupplier, isFalse);
      expect(retailer.isDriver, isFalse);

      final supplierJson = Map<String, dynamic>.from(profileJson);
      supplierJson['role'] = 'supplier';
      final supplier = Profile.fromJson(supplierJson);
      expect(supplier.isSupplier, isTrue);

      final driverJson = Map<String, dynamic>.from(profileJson);
      driverJson['role'] = 'driver';
      final driver = Profile.fromJson(driverJson);
      expect(driver.isDriver, isTrue);
    });

    test('toJson produces valid map', () {
      final p = Profile.fromJson(profileJson);
      final json = p.toJson();
      expect(json['shop_name'], 'Boutique Youssef');
      expect(json['role'], 'retailer');
      expect(json['phone'], '0612345678');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCT
  // ═══════════════════════════════════════════════════════════════════════════

  group('Product', () {
    final productJson = {
      'id': 'prod-1',
      'supplier_id': 'sup-1',
      'name': 'Cable Type C',
      'description': 'High quality USB-C cable',
      'brand': 'TechBrand',
      'image_url': 'https://example.com/cable.jpg',
      'compatibility_list': ['iPhone 15', 'Samsung A54'],
      'price_tiers': {'1': 15.0, '10': 12.0, '50': 10.0},
      'is_new': true,
      'stock_quantity': 250,
      'is_active': true,
      'created_at': '2026-01-10T08:00:00Z',
      'updated_at': '2026-02-15T14:00:00Z',
    };

    test('fromJson parses all fields', () {
      final p = Product.fromJson(productJson);
      expect(p.id, 'prod-1');
      expect(p.name, 'Cable Type C');
      expect(p.brand, 'TechBrand');
      expect(p.compatibilityList, ['iPhone 15', 'Samsung A54']);
      expect(p.isNew, isTrue);
      expect(p.stockQuantity, 250);
    });

    test('priceForQuantity uses tiered pricing', () {
      final p = Product.fromJson(productJson);
      expect(p.priceForQuantity(1), 15.0);
      expect(p.priceForQuantity(5), 15.0);
      expect(p.priceForQuantity(10), 12.0);
      expect(p.priceForQuantity(50), 10.0);
      expect(p.priceForQuantity(100), 10.0);
    });

    test('inStock returns true when stock > 0', () {
      final p = Product.fromJson(productJson);
      expect(p.inStock, isTrue);
    });

    test('inStock returns false when stock is 0', () {
      final json = Map<String, dynamic>.from(productJson);
      json['stock_quantity'] = 0;
      final p = Product.fromJson(json);
      expect(p.inStock, isFalse);
    });

    test('sortedTiers returns tiers sorted by key ascending', () {
      final p = Product.fromJson(productJson);
      final sorted = p.sortedTiers;
      expect(sorted.length, 3);
      expect(sorted.first.key, 1);
      expect(sorted.last.key, 50);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDER & ORDER ITEM
  // ═══════════════════════════════════════════════════════════════════════════

  group('OrderItem', () {
    test('fromJson parses with adjusted_qty', () {
      final json = {
        'product_id': 'p1',
        'name': 'Cable',
        'qty': 10,
        'unit_price': 15.0,
        'line_total': 150.0,
        'adjusted_qty': 8,
      };
      final item = OrderItem.fromJson(json);
      expect(item.productId, 'p1');
      expect(item.name, 'Cable');
      expect(item.quantity, 10);
      expect(item.unitPrice, 15.0);
      expect(item.lineTotal, 150.0);
      expect(item.adjustedQuantity, 8);
    });

    test('effectiveQuantity returns adjustedQuantity when set', () {
      const item = OrderItem(
        productId: 'p1',
        name: 'Cable',
        quantity: 10,
        unitPrice: 15.0,
        lineTotal: 150.0,
        adjustedQuantity: 8,
      );
      expect(item.effectiveQuantity, 8);
    });

    test('effectiveQuantity falls back to quantity when adjustedQuantity is null', () {
      const item = OrderItem(
        productId: 'p1',
        name: 'Cable',
        quantity: 10,
        unitPrice: 15.0,
        lineTotal: 150.0,
      );
      expect(item.effectiveQuantity, 10);
    });
  });

  group('Order', () {
    final orderJson = {
      'id': 'order-1',
      'supplier_id': 'sup-1',
      'retailer_id': 'ret-1',
      'relation_id': 'rel-1',
      'items': [
        {
          'product_id': 'p1',
          'name': 'Cable',
          'qty': 10,
          'unit_price': 15.0,
          'line_total': 150.0,
        },
        {
          'product_id': 'p2',
          'name': 'Screen',
          'qty': 5,
          'unit_price': 120.0,
          'line_total': 600.0,
        },
      ],
      'original_total': 750.0,
      'adjusted_total': null,
      'driver_name': null,
      'status': 'pending',
      'delivery_type': null,
      'notes': 'Urgent',
      'created_at': '2026-02-18T10:00:00Z',
      'updated_at': '2026-02-18T10:00:00Z',
      'supplier': {'shop_name': 'Fournisseur Ahmed'},
      'retailer': {'shop_name': 'Boutique Youssef'},
    };

    test('fromJson parses all fields including items', () {
      final o = Order.fromJson(orderJson);
      expect(o.id, 'order-1');
      expect(o.supplierId, 'sup-1');
      expect(o.retailerId, 'ret-1');
      expect(o.items.length, 2);
      expect(o.originalTotal, 750.0);
      expect(o.status, 'pending');
      expect(o.notes, 'Urgent');
    });

    test('fromJson extracts joined supplier/retailer names', () {
      final o = Order.fromJson(orderJson);
      expect(o.supplierName, 'Fournisseur Ahmed');
      expect(o.retailerName, 'Boutique Youssef');
    });

    test('finalTotal returns adjusted_total when set', () {
      final json = Map<String, dynamic>.from(orderJson);
      json['adjusted_total'] = 600.0;
      final o = Order.fromJson(json);
      expect(o.finalTotal, 600.0);
    });

    test('finalTotal falls back to original_total when adjusted is null', () {
      final o = Order.fromJson(orderJson);
      expect(o.finalTotal, 750.0);
    });

    test('isPartiallyReceived detects adjusted total', () {
      final json = Map<String, dynamic>.from(orderJson);
      json['adjusted_total'] = 600.0; // different from original 750.0
      final o = Order.fromJson(json);
      expect(o.isPartiallyReceived, isTrue);
    });

    test('isPartiallyReceived false when no received_qty set', () {
      final o = Order.fromJson(orderJson);
      expect(o.isPartiallyReceived, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LEDGER TRANSACTION
  // ═══════════════════════════════════════════════════════════════════════════

  group('LedgerTransaction', () {
    final txJson = {
      'id': 'tx-1',
      'relation_id': 'rel-1',
      'order_id': 'order-1',
      'transaction_type': 'order_increase',
      'amount': 750.0,
      'payment_method': null,
      'evidence_url': null,
      'reference_code': null,
      'notes': null,
      'status': 'verified',
      'verified_at': '2026-02-18T11:00:00Z',
      'verified_by': 'sup-1',
      'created_at': '2026-02-18T10:00:00Z',
      'updated_at': '2026-02-18T11:00:00Z',
    };

    test('fromJson parses order_increase', () {
      final tx = LedgerTransaction.fromJson(txJson);
      expect(tx.id, 'tx-1');
      expect(tx.transactionType, 'order_increase');
      expect(tx.amount, 750.0);
      expect(tx.isVerified, isTrue);
    });

    test('isOrderIncrease/isPaymentDecrease flags', () {
      final tx = LedgerTransaction.fromJson(txJson);
      expect(tx.isOrderIncrease, isTrue);
      expect(tx.isPaymentDecrease, isFalse);
    });

    test('signedAmount positive for order_increase', () {
      final tx = LedgerTransaction.fromJson(txJson);
      expect(tx.signedAmount, 750.0);
    });

    test('signedAmount negative for payment_decrease', () {
      final json = Map<String, dynamic>.from(txJson);
      json['transaction_type'] = 'payment_decrease';
      final tx = LedgerTransaction.fromJson(json);
      expect(tx.signedAmount, -750.0);
    });

    test('isPending/isVerified/isRejected status checks', () {
      final verified = LedgerTransaction.fromJson(txJson);
      expect(verified.isVerified, isTrue);
      expect(verified.isPending, isFalse);
      expect(verified.isRejected, isFalse);

      final pendingJson = Map<String, dynamic>.from(txJson);
      pendingJson['status'] = 'pending';
      final pending = LedgerTransaction.fromJson(pendingJson);
      expect(pending.isPending, isTrue);
    });

    test('paymentMethodLabel maps known methods', () {
      final methods = {
        'wafacash': 'Wafacash',
        'cashplus': 'CashPlus',
        'bank_transfer': 'Virement',
        'driver_cash': 'Cash Livreur',
        'check': 'Chèque',
      };
      for (final entry in methods.entries) {
        final json = Map<String, dynamic>.from(txJson);
        json['payment_method'] = entry.key;
        final tx = LedgerTransaction.fromJson(json);
        expect(tx.paymentMethodLabel, entry.value);
      }
    });

    test('fromJson extracts retailerName from nested relation join', () {
      final json = Map<String, dynamic>.from(txJson);
      json['relation'] = {
        'retailer': {'shop_name': 'Boutique Youssef'},
      };
      final tx = LedgerTransaction.fromJson(json);
      expect(tx.retailerName, 'Boutique Youssef');
    });

    test('toPaymentDeclarationJson always sets pending status', () {
      final tx = LedgerTransaction(
        id: 'tx-new',
        relationId: 'rel-1',
        transactionType: 'payment_decrease',
        amount: 500.0,
        paymentMethod: 'wafacash',
        evidenceUrl: 'https://example.com/receipt.jpg',
        referenceCode: 'REF123',
        status: 'verified', // even if set to verified...
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final json = tx.toPaymentDeclarationJson();
      expect(json['status'], 'pending'); // ...must always be pending
      expect(json['amount'], 500.0);
      expect(json['payment_method'], 'wafacash');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DELIVERY JOB
  // ═══════════════════════════════════════════════════════════════════════════

  group('DeliveryJob', () {
    final jobJson = {
      'id': 'job-1',
      'order_id': 'order-1',
      'supplier_id': 'sup-1',
      'assigned_driver_id': null,
      'pickup_city': 'Casablanca',
      'pickup_address': 'Rue 42',
      'pickup_location_name': 'Derb Omar',
      'dropoff_city': 'Rabat',
      'dropoff_address': null,
      'dropoff_location_name': 'Hay Riad',
      'estimated_weight_kg': 5.5,
      'job_type': 'cod',
      'cod_amount': 750.0,
      'delivery_pin': '1234',
      'status': 'open',
      'created_at': '2026-02-18T10:00:00Z',
      'updated_at': '2026-02-18T10:00:00Z',
    };

    test('fromJson parses all fields', () {
      final job = DeliveryJob.fromJson(jobJson);
      expect(job.id, 'job-1');
      expect(job.orderId, 'order-1');
      expect(job.pickupCity, 'Casablanca');
      expect(job.dropoffCity, 'Rabat');
      expect(job.codAmount, 750.0);
      expect(job.deliveryPin, '1234');
    });

    test('isCOD returns true for cod job type', () {
      final job = DeliveryJob.fromJson(jobJson);
      expect(job.isCOD, isTrue);
    });

    test('isCOD returns false for delivery_only', () {
      final json = Map<String, dynamic>.from(jobJson);
      json['job_type'] = 'delivery_only';
      final job = DeliveryJob.fromJson(json);
      expect(job.isCOD, isFalse);
    });

    test('isOpen returns true when status is open', () {
      final job = DeliveryJob.fromJson(jobJson);
      expect(job.isOpen, isTrue);
    });

    test('routeDisplay shows pickup → dropoff', () {
      final job = DeliveryJob.fromJson(jobJson);
      expect(job.routeDisplay, 'Casablanca → Rabat');
    });

    test('pickupLabel uses location_name when available', () {
      final job = DeliveryJob.fromJson(jobJson);
      expect(job.pickupLabel, 'Derb Omar · Casablanca');
    });

    test('dropoffLabel uses location_name when available', () {
      final job = DeliveryJob.fromJson(jobJson);
      expect(job.dropoffLabel, 'Hay Riad · Rabat');
    });

    test('pickupLabel falls back to address then city', () {
      final json = Map<String, dynamic>.from(jobJson);
      json['pickup_location_name'] = null;
      final job = DeliveryJob.fromJson(json);
      expect(job.pickupLabel, 'Rue 42 · Casablanca');
    });

    test('fromJson extracts supplier name from join', () {
      final json = Map<String, dynamic>.from(jobJson);
      json['supplier'] = {'shop_name': 'Fournisseur Ahmed'};
      final job = DeliveryJob.fromJson(json);
      expect(job.supplierName, 'Fournisseur Ahmed');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DELIVERY BID
  // ═══════════════════════════════════════════════════════════════════════════

  group('DeliveryBid', () {
    final bidJson = {
      'id': 'bid-1',
      'job_id': 'job-1',
      'driver_id': 'driver-1',
      'bid_amount': 150.0,
      'estimated_time': '2 heures',
      'message': 'Available now',
      'status': 'pending',
      'created_at': '2026-02-18T10:30:00Z',
      'driver': {
        'shop_name': 'Transport Karim',
        'phone': '0611111111',
        'city': 'Casablanca',
      },
    };

    test('fromJson parses all fields including driver join', () {
      final bid = DeliveryBid.fromJson(bidJson);
      expect(bid.id, 'bid-1');
      expect(bid.bidAmount, 150.0);
      expect(bid.estimatedTime, '2 heures');
      expect(bid.message, 'Available now');
      expect(bid.driverName, 'Transport Karim');
      expect(bid.driverPhone, '0611111111');
      expect(bid.driverCity, 'Casablanca');
    });

    test('isPending/isAccepted status checks', () {
      final bid = DeliveryBid.fromJson(bidJson);
      expect(bid.isPending, isTrue);
      expect(bid.isAccepted, isFalse);

      final acceptedJson = Map<String, dynamic>.from(bidJson);
      acceptedJson['status'] = 'accepted';
      final accepted = DeliveryBid.fromJson(acceptedJson);
      expect(accepted.isAccepted, isTrue);
      expect(accepted.isPending, isFalse);
    });

    test('toJson excludes driver join fields', () {
      final bid = DeliveryBid.fromJson(bidJson);
      final json = bid.toJson();
      expect(json.containsKey('driver'), isFalse);
      expect(json['bid_amount'], 150.0);
      expect(json['job_id'], 'job-1');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // CART ITEM
  // ═══════════════════════════════════════════════════════════════════════════

  group('CartItem', () {
    test('unitPrice resolves tiered pricing', () {
      final item = CartItem(
        productId: 'p1',
        productName: 'Cable',
        priceTiers: {'1': 15.0, '10': 12.0, '50': 10.0},
        quantity: 25,
      );
      expect(item.unitPrice, 12.0); // qty 25 → tier "10"
    });

    test('unitPrice returns highest tier for large quantities', () {
      final item = CartItem(
        productId: 'p1',
        productName: 'Cable',
        priceTiers: {'1': 15.0, '10': 12.0, '50': 10.0},
        quantity: 100,
      );
      expect(item.unitPrice, 10.0); // qty 100 → tier "50"
    });

    test('lineTotal = unitPrice × quantity', () {
      final item = CartItem(
        productId: 'p1',
        productName: 'Cable',
        priceTiers: {'1': 15.0, '10': 12.0},
        quantity: 10,
      );
      expect(item.lineTotal, 120.0); // 12.0 × 10
    });

    test('unitPrice returns 0 for empty tiers', () {
      final item = CartItem(
        productId: 'p1',
        productName: 'Cable',
        priceTiers: {},
        quantity: 5,
      );
      expect(item.unitPrice, 0.0);
    });

    test('toOrderItemJson produces correct structure', () {
      final item = CartItem(
        productId: 'p1',
        productName: 'Cable',
        priceTiers: {'1': 15.0},
        quantity: 3,
      );
      final json = item.toOrderItemJson();
      expect(json['product_id'], 'p1');
      expect(json['name'], 'Cable');
      expect(json['qty'], 3);
      expect(json['unit_price'], 15.0);
      expect(json['line_total'], 45.0);
    });

    test('quantity can be mutated', () {
      final item = CartItem(
        productId: 'p1',
        productName: 'Cable',
        priceTiers: {'1': 15.0, '10': 12.0},
        quantity: 5,
      );
      expect(item.unitPrice, 15.0);
      item.quantity = 10;
      expect(item.unitPrice, 12.0); // price drops at qty 10
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPPLIER RETAILER RELATION
  // ═══════════════════════════════════════════════════════════════════════════

  group('SupplierRetailerRelation', () {
    final relationJson = {
      'id': 'rel-1',
      'supplier_id': 'sup-1',
      'retailer_id': 'ret-1',
      'credit_limit': 50000.0,
      'current_balance': 15000.0,
      'status': 'active',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-02-18T00:00:00Z',
      'supplier': {'shop_name': 'Fournisseur Ahmed', 'phone': '0622222222'},
      'retailer': {'shop_name': 'Boutique Youssef'},
    };

    test('fromJson parses all fields', () {
      final r = SupplierRetailerRelation.fromJson(relationJson);
      expect(r.id, 'rel-1');
      expect(r.creditLimit, 50000.0);
      expect(r.currentBalance, 15000.0);
      expect(r.status, 'active');
    });

    test('fromJson extracts joined names', () {
      final r = SupplierRetailerRelation.fromJson(relationJson);
      expect(r.supplierName, 'Fournisseur Ahmed');
      expect(r.retailerName, 'Boutique Youssef');
      expect(r.supplierPhone, '0622222222');
    });

    test('creditUsagePercent calculates correctly', () {
      final r = SupplierRetailerRelation.fromJson(relationJson);
      expect(r.creditUsagePercent, 0.3); // 15000 / 50000
    });

    test('creditUsagePercent clamps at 1.0', () {
      final json = Map<String, dynamic>.from(relationJson);
      json['current_balance'] = 75000.0; // over limit
      final r = SupplierRetailerRelation.fromJson(json);
      expect(r.creditUsagePercent, 1.0);
    });

    test('creditUsagePercent returns 0 when limit is 0', () {
      final json = Map<String, dynamic>.from(relationJson);
      json['credit_limit'] = 0;
      final r = SupplierRetailerRelation.fromJson(json);
      expect(r.creditUsagePercent, 0.0);
    });

    test('isOverLimit detects balance exceeding limit', () {
      final json = Map<String, dynamic>.from(relationJson);
      json['current_balance'] = 55000.0;
      final r = SupplierRetailerRelation.fromJson(json);
      expect(r.isOverLimit, isTrue);
    });

    test('isOverLimit false when under limit', () {
      final r = SupplierRetailerRelation.fromJson(relationJson);
      expect(r.isOverLimit, isFalse);
    });

    test('isActive checks status', () {
      final r = SupplierRetailerRelation.fromJson(relationJson);
      expect(r.isActive, isTrue);

      final suspJson = Map<String, dynamic>.from(relationJson);
      suspJson['status'] = 'suspended';
      final suspended = SupplierRetailerRelation.fromJson(suspJson);
      expect(suspended.isActive, isFalse);
    });

    test('toJson excludes current_balance (trigger-only field)', () {
      final r = SupplierRetailerRelation.fromJson(relationJson);
      final json = r.toJson();
      expect(json.containsKey('current_balance'), isFalse);
      expect(json['credit_limit'], 50000.0);
      expect(json['status'], 'active');
    });
  });
}
