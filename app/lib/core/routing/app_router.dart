import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/retailer/screens/retailer_catalog_screen.dart';
import '../../features/retailer/screens/retailer_home_screen.dart';

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
        builder: (context, state) => const _PlaceholderScreen(title: 'Splash'),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
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
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Order Detail'),
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
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Partial Receipt'),
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
            const _PlaceholderScreen(title: 'Bulk Inventory Manager'),
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
