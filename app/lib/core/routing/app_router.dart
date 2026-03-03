import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/product.dart';
import '../../features/shared/widgets/app_title_offline_toggle.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/pending_verification_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/driver/screens/driver_active_trip_screen.dart';
import '../../features/driver/screens/driver_bid_screen.dart';
import '../../features/driver/screens/driver_handshake_redirect_screen.dart';
import '../../features/driver/screens/driver_marketplace_screen.dart';
import '../../features/retailer/screens/retailer_cart_screen.dart';
import '../../features/retailer/screens/retailer_catalog_screen.dart';
import '../../features/retailer/screens/retailer_handshake_screen.dart';
import '../../features/retailer/screens/retailer_home_screen.dart';
import '../../features/retailer/screens/retailer_order_detail_screen.dart';
import '../../features/retailer/screens/retailer_orders_screen.dart';
import '../../features/retailer/screens/retailer_partial_receipt_screen.dart';
import '../../features/retailer/screens/retailer_profile_screen.dart';
import '../../features/retailer/screens/payment_declaration_screen.dart';
import '../../features/supplier/screens/supplier_add_edit_product_screen.dart';
import '../../features/supplier/screens/supplier_bid_manager_screen.dart';
import '../../features/supplier/screens/supplier_dashboard_screen.dart';
import '../../features/supplier/screens/supplier_delivery_screen.dart';
import '../../features/supplier/screens/supplier_dispute_screen.dart';
import '../../features/supplier/screens/supplier_inventory_screen.dart';
import '../../features/supplier/screens/supplier_profile_screen.dart';
import '../../features/supplier/screens/supplier_order_detail_screen.dart';
import '../../features/supplier/screens/supplier_verification_screen.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PUBLIC ROUTES — do not require authentication.
/// ════════════════════════════════════════════════════════════════════════════
const _publicPaths = <String>{
  '/splash',
  '/login',
};

/// Paths that start with these prefixes are always accessible once we have
/// a session (even before onboarding is complete).
bool _isAuthFlowPath(String path) =>
    path.startsWith('/otp-verify') ||
    path.startsWith('/role-selection') ||
    path.startsWith('/pending-verification');

/// Application router using GoRouter.
/// Routes are organized by user role (Retailer, Driver, Supplier).
///
/// **Auth guard**: Every navigation is checked. If the user has no session
/// they are sent to `/login`; if their profile is incomplete they land on
/// `/role-selection`. Authenticated users are allowed through, and trying
/// to visit `/login` while logged-in redirects to the role dashboard.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // ── Global auth redirect ──────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.uri.path;

      // Always allow public routes
      if (_publicPaths.contains(path)) return null;

      final authStatus = ref.read(authGuardProvider);

      switch (authStatus) {
        case AuthStatus.loading:
          // Still loading — let splash handle it
          return path == '/splash' ? null : '/splash';

        case AuthStatus.unauthenticated:
          // Not logged in — only auth-flow pages and public pages allowed
          if (_isAuthFlowPath(path)) return null;
          return '/login';

        case AuthStatus.needsOnboarding:
          // Session exists but profile is incomplete
          if (_isAuthFlowPath(path)) return null;
          return '/role-selection';

        case AuthStatus.authenticated:
          // Logged-in user visiting /login → send to their dashboard
          if (path == '/login') {
            final role = ref.read(currentRoleProvider) ?? 'retailer';
            return switch (role) {
              'supplier' => '/supplier/dashboard',
              'driver' => '/driver/marketplace',
              _ => '/retailer/dashboard',
            };
          }
          return null; // allow
      }
    },

    // ── Error / 404 page ──────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 — Page introuvable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString(),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    ),

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
        builder: (context, state, child) => _RetailerShell(child: child),
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
              final qp = state.uri.queryParameters;
              return RetailerCatalogScreen(
                supplierId: supplierId,
                supplierName: qp['name'],
                relationId: qp['relationId'],
                supplierPhone: qp['phone'],
              );
            },
          ),
          GoRoute(
            path: '/retailer/orders',
            name: 'retailer-orders',
            builder: (context, state) =>
                const RetailerOrdersScreen(),
          ),
          GoRoute(
            path: '/retailer/cart/:supplierId',
            name: 'retailer-cart',
            builder: (context, state) {
              final supplierId = state.pathParameters['supplierId']!;
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return RetailerCartScreen(
                supplierId: supplierId,
                relationId: extra['relationId'] as String? ?? '',
                supplierName: extra['supplierName'] as String?,
                supplierPhone: extra['supplierPhone'] as String?,
              );
            },
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
            builder: (context, state) {
              final relationId = state.pathParameters['relationId']!;
              return PaymentDeclarationScreen(relationId: relationId);
            },
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
                const RetailerProfileScreen(),
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
                const DriverMarketplaceScreen(),
          ),
          GoRoute(
            path: '/driver/bid/:jobId',
            name: 'driver-bid',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return DriverBidScreen(jobId: jobId);
            },
          ),
          GoRoute(
            path: '/driver/active-trip/:jobId',
            name: 'driver-active-trip',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return DriverActiveTripScreen(jobId: jobId);
            },
          ),
          GoRoute(
            path: '/driver/handshake/:orderId',
            name: 'driver-handshake',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return DriverHandshakeRedirectScreen(orderId: orderId);
            },
          ),
        ],
      ),

      // ── Supplier Web/Tablet Routes ──
      GoRoute(
        path: '/supplier/dashboard',
        name: 'supplier-dashboard',
        builder: (context, state) =>
            const SupplierDashboardScreen(),
      ),
      GoRoute(
        path: '/supplier/order/:orderId',
        name: 'supplier-order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return SupplierOrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/supplier/verification',
        name: 'supplier-verification',
        builder: (context, state) =>
            const SupplierVerificationScreen(),
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
        builder: (context, state) {
          final transactionId = state.pathParameters['transactionId']!;
          return SupplierDisputeScreen(transactionId: transactionId);
        },
      ),
      GoRoute(
        path: '/supplier/bids/:jobId',
        name: 'supplier-bid-manager',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return SupplierBidManagerScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/supplier/deliveries',
        name: 'supplier-deliveries',
        builder: (context, state) =>
            const SupplierDeliveryScreen(),
      ),
      GoRoute(
        path: '/supplier/profile',
        name: 'supplier-profile',
        builder: (context, state) =>
            const SupplierProfileScreen(),
      ),
    ],
  );
});

/// Wraps retailer routes with an AppBar so "L'Carnet B2B" is visible and triple-tappable for demo.
/// [automaticallyImplyLeading: false] so back is handled by each screen's in-content back button
/// and works correctly with GoRouter (avoids shell AppBar stealing the pop).
class _RetailerShell extends ConsumerWidget {
  const _RetailerShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitleWithOfflineToggle(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: child,
    );
  }
}
