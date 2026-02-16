import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/product.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/pending_verification_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/retailer/screens/retailer_catalog_screen.dart';
import '../../features/retailer/screens/retailer_handshake_screen.dart';
import '../../features/retailer/screens/retailer_home_screen.dart';
import '../../features/retailer/screens/retailer_order_detail_screen.dart';
import '../../features/retailer/screens/retailer_partial_receipt_screen.dart';
import '../../features/supplier/screens/supplier_add_edit_product_screen.dart';
import '../../features/supplier/screens/supplier_inventory_screen.dart';

/// Application router using GoRouter.
/// Routes are organized by user role (Retailer, Driver, Supplier).
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // ── Splash / Auth ──
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp-verify/:phone',
        name: 'otp-verify',
        builder: (context, state) {
          final phone = state.pathParameters['phone']!;
          return OtpVerifyScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/pending-verification/:supplierId',
        name: 'pending-verification',
        builder: (context, state) {
          final supplierId = state.pathParameters['supplierId']!;
          final supplierName =
              state.uri.queryParameters['supplierName'];
          return PendingVerificationScreen(
            supplierId: supplierId,
            supplierName: supplierName,
          );
        },
      ),

      // ── Retailer Routes ──
      ShellRoute(
        builder: (context, state, child) => child, // Shell with TabBar
        routes: [
          GoRoute(
            path: '/retailer/dashboard',
            name: 'retailer-dashboard',
            builder: (context, state) =>
                const RetailerHomeScreen(),
          ),
          GoRoute(
            path: '/retailer/catalog/:supplierId',
            name: 'retailer-catalog',
            builder: (context, state) {
              final supplierId = state.pathParameters['supplierId']!;
              final supplierName =
                  state.uri.queryParameters['name'];
              return RetailerCatalogScreen(
                supplierId: supplierId,
                supplierName: supplierName,
              );
            },
          ),
          GoRoute(
            path: '/retailer/orders',
            name: 'retailer-orders',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Orders'),
          ),
          GoRoute(
            path: '/retailer/order/:orderId',
            name: 'retailer-order-detail',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return RetailerOrderDetailScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: '/retailer/payment/:relationId',
            name: 'retailer-payment',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Payment Declaration'),
          ),
          GoRoute(
            path: '/retailer/receipt/:orderId',
            name: 'retailer-partial-receipt',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return RetailerPartialReceiptScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: '/retailer/handshake/:orderId',
            name: 'retailer-handshake',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              final qp = state.uri.queryParameters;
              return RetailerHandshakeScreen(
                orderId: orderId,
                adjustedTotal: double.tryParse(qp['adjustedTotal'] ?? '') ?? 0,
                originalTotal: double.tryParse(qp['originalTotal'] ?? '') ?? 0,
                itemCount: int.tryParse(qp['itemCount'] ?? '') ?? 0,
                adjustmentCount: int.tryParse(qp['adjustmentCount'] ?? '') ?? 0,
                driverName: qp['driverName'] ?? '',
                retailerName: qp['retailerName'] ?? '',
              );
            },
          ),
          GoRoute(
            path: '/retailer/profile',
            name: 'retailer-profile',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),

      // ── Driver Routes ──
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/driver/marketplace',
            name: 'driver-marketplace',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Driver Marketplace'),
          ),
          GoRoute(
            path: '/driver/bid/:jobId',
            name: 'driver-bid',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Bid Sheet'),
          ),
          GoRoute(
            path: '/driver/active-trip/:jobId',
            name: 'driver-active-trip',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Active Trip'),
          ),
          GoRoute(
            path: '/driver/handshake/:orderId',
            name: 'driver-handshake',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Delivery Handshake'),
          ),
        ],
      ),

      // ── Supplier Web/Tablet Routes ──
      GoRoute(
        path: '/supplier/dashboard',
        name: 'supplier-dashboard',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Supplier Dashboard'),
      ),
      GoRoute(
        path: '/supplier/verification',
        name: 'supplier-verification',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Verification Desk'),
      ),
      GoRoute(
        path: '/supplier/inventory',
        name: 'supplier-inventory',
        builder: (context, state) =>
            const SupplierInventoryScreen(),
      ),
      GoRoute(
        path: '/supplier/product/add',
        name: 'supplier-product-add',
        builder: (context, state) =>
            const SupplierAddEditProductScreen(),
      ),
      GoRoute(
        path: '/supplier/product/:productId/edit',
        name: 'supplier-product-edit',
        builder: (context, state) {
          final product = state.extra as Product?;
          return SupplierAddEditProductScreen(
            existingProduct: product,
          );
        },
      ),
      GoRoute(
        path: '/supplier/dispute/:transactionId',
        name: 'supplier-dispute',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Dispute Resolution'),
      ),
      GoRoute(
        path: '/supplier/bids/:jobId',
        name: 'supplier-bid-manager',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Bid Manager'),
      ),
    ],
  );
});

/// Temporary placeholder screen for route scaffolding.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
