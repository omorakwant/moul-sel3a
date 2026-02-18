L'Carnet B2B: Progress Tracker
✅ Phase 0: Planning & Architecture (Completed)

    Business Logic Defined: Rolling debt calculation, Tiered pricing JSONB structure, and PIN-code handshake.

    Design Specs: Master UI/UX prompt created with fixed mobile viewport constraints (390x844).

    Localization Map: l10n_map.json created with French and Moroccan Darija keys.

    Tech Stack Confirmed: Flutter, Supabase (PostgreSQL), WhatsApp Deep-linking.

    Master Spec: PROJECT_CONTEXT.md finalized with database schema and RLS rules.

✅ Phase 1: Foundation (Completed)

    [x] Database Migration: SQL for tables (Profiles, Products, Orders, Ledger) — see supabase/migrations/.

    [x] Trigger Logic: PostgreSQL fn_update_rolling_balance trigger implemented.

    [x] Authentication: Phone Auth + Role Selection (Supplier/Retailer/Driver) — see features/auth/.

    [x] Profile Setup: Static location fields (Location Name/City).

    [x] Routing: GoRouter with auth guards — see core/routing/app_router.dart.

✅ Phase 2: Supplier Features (Completed)

    [x] Product Factory (Add/Edit with Price Tiers) — supplier_add_edit_product_screen.dart.

    [x] Bulk Price Adjustment Logic (+/- DH or %) — bulk_price_adjustment_modal.dart + supplier_inventory_providers.dart.

    [x] Verification Desk (Payment Proof Review) — supplier_verification_screen.dart.

    [x] Supplier Dashboard (Overview + Orders + Clients tabs) — supplier_dashboard_screen.dart.

    [x] Delivery Dispatch & Bid Manager — supplier_delivery_screen.dart + supplier_bid_manager_screen.dart.

✅ Phase 3: Retailer & Driver Flow (Completed)

    [x] Catalog with Dynamic Pricing — retailer_catalog_screen.dart.

    [x] Checkout & WhatsApp Summary — retailer_cart_screen.dart.

    [x] Driver Job Board & PIN Verification — driver_marketplace_screen.dart + driver_active_trip_screen.dart.

    [x] Payment Declaration (Receipt Upload) — payment_declaration_screen.dart.

    [x] Partial Receipt & Handshake — retailer_partial_receipt_screen.dart + retailer_handshake_screen.dart.

✅ Phase 4: UI/UX Design — Mobile Screens (Completed)

    [x] Screen A: Retailer Dashboard (Multi-Supplier View) — 390x844.

    [x] Screen B: Supplier Catalog (Product Grid) — 390x844.

    [x] Screen C: Order Summary & Handshake — 390x844.

    [x] Screen D: Driver Marketplace — 390x844.

    [x] Screen E: Payment Declaration (Receipt Upload) — 390x844.

✅ Phase 5: UI/UX Design — Web Dashboard Screens (Completed)

    [x] Screen F: The Command Center (Inventory & Orders) — 1440x900 web viewport.
        - Sidebar (260px, dark) + data table with filter tabs + floating bulk action bar.
        - Multi-select with indigo checkmarks, low stock warnings (amber badge).
        - UI&UX.pen node: dZFuG (main), LlV2T (bulk bar).

    [x] Screen F.1: Bulk Update Modal (overlay) — 1440x900.
        - Radio mode selection (Fixed/Percentage), input field, preview table (old→new prices in green).
        - UI&UX.pen node: Aer9e.

    [x] Screen G: The Verification Desk (Payment Matching) — 1440x900 web viewport.
        - 50/50 split view: receipt image pane (left) + validation panel (right, 480px).
        - Queue navigation (Précédent/Suivant), client card, balance impact preview (green).
        - Approve (green) / Reject (red) buttons with Darija labels.
        - UI&UX.pen node: Lgg5P.

✅ Phase 6: Web Dashboard Implementation (Completed)

    [x] Implement responsive sidebar layout for supplier web screens — supplier_web_shell.dart (SupplierWebShell + isWebLayout()).

    [x] Migrate supplier_inventory_screen.dart to match Screen F (data table + sidebar + bulk bar).

    [x] Migrate supplier_verification_screen.dart to match Screen G (split-view + queue navigation).

    [x] Update bulk_price_adjustment_modal.dart to match Screen F.1 (radio mode, full preview table).

    [x] Add web-specific breakpoints and adaptive layouts — kWebBreakpoint = 1024.

✅ Phase 7: Offline-First Sync Queue (Completed)

    [x] SyncService — Hive-based action queue with connectivity_plus auto-retry.
        - File: data/services/sync_service.dart
        - Singleton, initialized in main.dart after Hive.initFlutter().
        - Supports 3 action types: confirmReceipt, declarePayment, verifyDelivery.
        - FIFO processing, max 5 retries before dead-letter, retry/dismiss API.

    [x] Riverpod Providers — core/providers/sync_providers.dart
        - syncServiceProvider, queueStatusProvider (stream), offlineConfirmReceiptProvider,
          offlineDeclarePaymentProvider, offlineVerifyDeliveryProvider.

    [x] OfflineStatusBanner widget — features/shared/widgets/offline_status_banner.dart
        - 4 states: offline (red), syncing (amber), failed (red + retry), hidden.
        - Bilingual (French + Darija).

    [x] Screen Integrations:
        - payment_declaration_screen.dart → offlineDeclarePaymentProvider (replaces declarePaymentProvider).
        - retailer_partial_receipt_screen.dart → offlineConfirmReceiptProvider (replaces confirmReceiptProvider).
        - driver_providers.dart → TripActionNotifier split: verifyPinOnly (online) + SyncService queue (offline-safe).

    [x] DeliveryRepository.verifyPinOnly() — read-only PIN check returning queue payload.

    [x] Dependency: connectivity_plus ^6.1.0 added to pubspec.yaml.

✅ Phase 8: Polish & Hardening (Completed)

    [x] Supplier Order Detail Screen — supplier_order_detail_screen.dart.
        - Full order detail view with status banner, items list, client card, delivery info.
        - Action buttons: Confirm/Reject (pending), Mark Ready (confirmed), status info (others).
        - WhatsApp integration, partial receipt indicator.

    [x] Supplier Order Detail Providers — supplier_order_detail_providers.dart.
        - supplierOrderDetailProvider (auto-refreshing via realtime).
        - SupplierOrderActionNotifier with loading/success/error states.

    [x] GoRoute: /supplier/order/:orderId → SupplierOrderDetailScreen.

    [x] Dashboard → Detail navigation: _OrderCard taps navigate to detail screen.

    [x] Missing Formatters added:
        - compactPrice() — compact price for dashboard cards (12.5k DH, 1.2M DH).
        - timeOnly() — HH:mm format for timestamps.
        - dateShort() — DD/MM without year.

    [x] RLS Hardening Migration — 20260218000000_mvp_rls_hardening.sql.
        - FORCE ROW LEVEL SECURITY on all 7 tables.
        - Role-check guards on sensitive INSERT/UPDATE policies.
        - Performance indexes for RLS subqueries.

    [x] Release Prep: flutter_launcher_icons + flutter_native_splash added to pubspec.yaml.

    [x] Barrel exports updated for new files.