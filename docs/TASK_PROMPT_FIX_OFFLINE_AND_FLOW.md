# Task Prompt: Fix Unusable No-Internet UX, Non-Working Buttons, and Webpage Flow

**Use this prompt with a coding assistant to systematically review and fix the project.**

---

## 1. Context

This is a **Flutter (Dart) B2B web + mobile app** (“L’Carnet B2B”) with:

- **State:** Riverpod  
- **Routing:** go_router ^14  
- **Backend:** Supabase (PKCE auth)  
- **Offline:** Hive + `SyncService` (action queue), `connectivity_plus` for network status  
- **UI:** `OfflineStatusBanner` shows “Hors connexion” / “ما كاينش إنترنت” when offline; sync/pending/failed states

**Known pain points:**

1. **“No internet” experience is unusable** — e.g. banner always shows offline on web, or connectivity is wrong so the app feels broken.  
2. **Some buttons don’t work** — e.g. taps do nothing, navigation fails, or forms don’t submit.  
3. **Webpage flow is broken** — e.g. wrong redirects, dead ends, or confusing navigation (splash → login → role → dashboard and role-specific flows).

---

## 2. Objectives

- **Fix “no internet” behavior** so it is accurate and usable (especially on **Flutter web**).  
- **Fix all non-working buttons** (navigation, submit, retry, etc.).  
- **Fix routing and flow** so splash → auth → role → dashboards and all role flows work correctly.

Do not change product behavior (e.g. offline queue logic, Supabase schema, or business rules) unless required to fix the above.

---

## 3. Requirements (Must Have)

### 3.1 Connectivity / “No Internet” (Offline UX)

- **Correct online/offline detection**
  - **Web:** Always verify reachability via a real HTTP HEAD or GET to a known backend endpoint (on web the endpoint must be CORS-allowed). `connectivity_plus`, `navigator.onLine`, and the Network Information API are unreliable on `kIsWeb`—do not rely on them alone. Prefer a library such as `internet_connection_checker_plus` or a custom CORS-friendly reachability probe as the default approach when running on web.
  - **Mobile:** Keep using `connectivity_plus` for native; ensure `onConnectivityChanged` and initial `checkConnectivity()` are used correctly (see `SyncService`).
- **Single source of truth:** `SyncService._isOnline` (and thus `QueueStatus.isOnline`) must reflect the chosen logic for each platform.
- **OfflineStatusBanner**
  - Only show “Hors connexion” when the app has actually determined the device is offline (or unreachable), not when the connectivity API is wrong (e.g. web).
  - Keep existing states: Offline (red), Syncing (amber), Failed (red + Retry), Online+empty (hidden).
- **No breaking changes:** Queue processing, retry, and Hive persistence must continue to work; only fix *how* online/offline is determined and displayed.

### 3.2 Buttons and Actions

- **Navigation buttons:** Every `onTap` / `onPressed` that should navigate (e.g. to catalog, cart, order detail, payment, profile, dashboards) must call the correct `context.push`, `context.pushNamed`, or `context.go` / `context.goNamed` with the right path/name and parameters. No no-op or wrong route.
- **Submit buttons:** Every primary action (login, OTP, role selection, place order, confirm receipt, declare payment, driver bid, PIN verify, dispute, add/edit product, etc.) must:
  - Trigger the intended async action (provider/repository/SyncService).
  - Show loading state where applicable (disable button + indicator).
  - On success: show feedback (e.g. SnackBar) and navigate or pop where specified in design.
  - On error: show user-friendly error (SnackBar or inline) and re-enable the button; do not leave the user stuck.
- **Retry / “Réessayer”:** The offline banner’s “Réessayer” must call the retry logic (e.g. `retryFailedActionsProvider`) and update the UI when failed actions are retried.
- **Accessibility:** Buttons must remain focusable/tappable (no zero-size hit area, no overlapping invisible widget blocking taps).

### 3.3 Routing and Page Flow

- **Splash → Auth → Role → Dashboard**
  - Splash: after init, redirect to `login` (unauthenticated), `role-selection` (needs onboarding), or role dashboard (authenticated).
  - Login: after successful auth, go to `role-selection` or role dashboard as per current logic.
  - OTP: after success, same as login.
  - Role selection: after profile completion, go to the correct dashboard (retailer / driver / supplier).
- **Role-specific flows**
  - **Retailer:** Dashboard ↔ Catalog (by supplier) ↔ Cart ↔ Order detail ↔ Partial receipt ↔ Handshake; Dashboard ↔ Payment (by relation). Orders list ↔ Order detail. Profile reachable from shell/tabs.
  - **Driver:** Marketplace ↔ Bid screen ↔ Active trip; handshake/PIN flow must land on the correct screen (active trip by **job**, not by order if they differ).
  - **Supplier:** Dashboard ↔ Orders, verification, inventory, product add/edit, deliveries, disputes, profile. All sidebar/nav targets must resolve to the correct routes.
- **404:** Existing error page with “Retour” to `/splash` is fine; ensure no valid in-app links lead to 404.
- **Redirects:** Fix any redirect that uses wrong IDs (e.g. using `orderId` where a route expects `jobId`), and ensure deep links or post-action redirects send the user to the next logical screen.

---

## 4. Edge Cases and Failure Modes

- **Web: connectivity_plus returns empty or “none” while the user has internet**  
  → Treat as online for web, or use a fallback reachability check; do not show “Hors connexion” in that case.

- **Initial load: connectivity check not yet completed**  
  → Prefer “assume online” on web to avoid flashing offline; on mobile, short loading for banner is acceptable (e.g. `queueStatusProvider` loading → hide banner until first real status).

- **User taps button while async action in progress**  
  → Buttons must be disabled during submit/loading (and re-enabled on error) to avoid double submission.

- **Navigation after async action:** `context.go`/`push` after `await` only if `mounted` is true; otherwise skip navigation to avoid calling context after dispose.

- **GoRouter pathParameters vs queryParameters:**  
  Use `pathParameters` for path segments (e.g. `supplierId`, `orderId`, `jobId`); use `queryParameters` for optional query args (e.g. `name`, `relationId`, `phone`). Ensure `pushNamed`/`goNamed` pass the correct map so URLs and routes resolve.

- **Driver handshake route:** `/driver/handshake/:orderId` currently redirects to `/driver/active-trip/$orderId`. If “active trip” is keyed by **job** id, not order id, this redirect is wrong and can break flow — fix so the driver lands on the correct active trip (by job id) or the correct handshake/PIN screen.

- **Supplier product edit:** Route `/supplier/product/:productId/edit` uses `state.extra` for `Product`; ensure every place that navigates to this route passes `extra: product` so the edit screen receives the product.

- **Retailer cart → checkout flow:** Cart screen receives `supplierId`, `relationId`, `supplierName`, `supplierPhone` (path + extra). Ensure navigation to cart passes all required data so place-order and post-order flows work.

- **Offline queue retry:** When user taps “Réessayer”, ensure `retryFailedActionsProvider` is invoked (e.g. from banner) and that the provider/stream causes the banner to update (failed count decreases or banner hides when no failed items remain).

---

## 5. Step-by-Step Implementation Logic

### Phase A: Connectivity and “No Internet” (SyncService + Banner)

1. **Audit current connectivity usage**
   - In `SyncService` (e.g. `app/lib/data/services/sync_service.dart`): see how `_isOnline` is set from `Connectivity().checkConnectivity()` and `onConnectivityChanged`.
   - Confirm that on web, `connectivity_plus` may return empty list or `ConnectivityResult.none` even when the user is online.

2. **Introduce web-safe connectivity**
   - Use `import 'package:flutter/foundation.dart'` and `kIsWeb`.
   - On web (`kIsWeb == true`):  
     - Either treat “empty” or “none” as **online** when the app has no other signal, or  
     - Add an optional reachability check (e.g. short-lived HTTP request to Supabase or a small endpoint) and treat success as online, failure as offline; debounce to avoid hammering the network.
   - On non-web: keep existing `connectivity_plus` logic.
   - Ensure `_isOnline` is updated and `_emitStatus()` is called so `QueueStatus.isOnline` and the banner stay in sync.

3. **Optional: light reachability helper**
   - If you add a real “can we reach the server” check, implement it in a way that does not block app startup (e.g. fire-and-forget or short timeout) and that SyncService can call when it needs to resolve ambiguous connectivity (e.g. on web).

4. **Banner behavior**
   - In `OfflineStatusBanner`, rely on `queueStatusProvider` only; no extra connectivity logic there.
   - Verify in UI: with real internet, web build does not show “Hors connexion” incorrectly; with network disabled (or simulated offline), banner appears and Retry works when you bring network back and tap “Réessayer”.

5. **Tests**
   - If there are unit tests for SyncService or queue status, update or add cases for “web: treat as online when connectivity says none” (and optionally “reachability failure → offline”).

### Phase B: Buttons (Navigation and Submit)

1. **List all navigation targets**
   - From router: every `GoRoute` and its `name` and `path` (with `:param`).
   - From code: every `context.push`, `context.go`, `context.pushNamed`, `context.goNamed`, `context.pushReplacementNamed`.

2. **Check each navigation call**
   - For each call, ensure path/name and pathParameters/queryParameters/extra match the route definition (e.g. `retailer-catalog` needs `supplierId` in path; optional query params for name, relationId, phone).
   - Fix any that use wrong route name, wrong param key, or missing required params (e.g. passing `orderId` where route expects `jobId`).

3. **List all primary action buttons**
   - Login, OTP verify, role selection submit, place order, confirm receipt, declare payment, driver place bid, driver verify PIN, supplier dispute submit, add/edit product save, etc.

4. **For each primary action**
   - Confirm the widget’s `onTap`/`onPressed` calls the correct async method (provider/repository/SyncService).
   - Confirm loading state: button disabled + loading indicator while async runs.
   - Confirm success: SnackBar or message + navigation/pop where required; use `if (mounted)` before any `context` usage after `await`.
   - Confirm error: error message shown, button re-enabled; no silent failure.

5. **Offline banner “Réessayer”**
   - Ensure it’s wired to retry failed actions (e.g. `ref.read(retryFailedActionsProvider)` or equivalent) and that the banner updates when the queue state changes (StreamProvider / status stream).

6. **Hit area and blocking**
   - Ensure no transparent overlay or sibling widget is capturing taps; ensure buttons have minimum size (e.g. 44x44) if needed for touch targets.

### Phase C: Routing and Page Flow

1. **Map intended flows**
   - Splash → login / role-selection / dashboard.  
   - Login / OTP → role-selection or dashboard.  
   - Role selection → retailer / driver / supplier dashboard.  
   - Retailer: dashboard ↔ catalog, cart, order detail, receipt, handshake, payment, orders, profile.  
   - Driver: marketplace ↔ bid, active trip, handshake.  
   - Supplier: dashboard ↔ orders, verification, inventory, product add/edit, deliveries, disputes, profile.

2. **Fix redirects**
   - In `app_router.dart`, fix `/driver/handshake/:orderId` redirect: if active trip is by job id, resolve job from order (e.g. via a redirect that fetches or passes the right job id) or change the flow so handshake is reached from the active trip screen without a wrong redirect.

3. **Shell and tabs**
   - Retailer uses a shell with tabs (dashboard, orders, profile). Ensure `goNamed`/`go` to `retailer-dashboard`, `retailer-orders`, `retailer-profile` work and that the shell receives the correct child route.
   - Supplier (web) may use a shell or sidebar; ensure every nav item points to the correct route name/path.

4. **Deep links and extras**
   - Cart: ensure `state.extra` or query params provide `relationId`, `supplierName`, `supplierPhone` where the cart screen expects them.
   - Supplier product edit: ensure navigation passes `extra: product` when opening edit.

5. **End-to-end flow test**
   - Manually or with a short checklist: Splash → Login → OTP → Role → Dashboard; from dashboard open catalog, cart, place order (if applicable), open order detail, partial receipt, handshake; driver: marketplace → bid → active trip; supplier: dashboard → inventory → add product, etc. Fix any dead end or wrong screen.

---

## 6. Preferred Libraries and Patterns

- **Connectivity (current):** Keep `connectivity_plus` for mobile. For web, either:
  - Use the same package but treat ambiguous/none as online on web, or
  - Add a small reachability check (e.g. `http` or `dio` HEAD/GET with short timeout) only when `kIsWeb` is true; avoid adding heavy dependencies if a simple “assume online on web” fixes the issue.
- **Routing:** Keep **go_router**; use `context.go` for replacing the stack (e.g. after login), `context.push`/`pushNamed` for stacking (e.g. catalog, order detail). Use route **names** and `pathParameters`/`queryParameters`/`extra` consistently.
- **State:** Keep **Riverpod**; use existing providers for auth, sync, and feature state; ensure async actions are triggered with `ref.read(...Provider.notifier)` or `ref.read(...Provider.future)` as appropriate, and that widgets watch the right provider for loading/success/error.
- **Offline queue:** Do not replace SyncService or Hive; only fix connectivity input and ensure UI (banner + retry) reflects true state.
- **Errors:** Use existing `AppException` / error widgets where applicable; show user-facing messages in SnackBar or inline so the user knows what failed and can retry or navigate away.

---

## 7. Files to Touch (Checklist)

- **Connectivity / offline:**  
  `app/lib/data/services/sync_service.dart`  
  `app/lib/features/shared/widgets/offline_status_banner.dart`  
  (Optional: small reachability helper in `core/` or `data/`.)

- **Routing:**  
  `app/lib/core/routing/app_router.dart`

- **Screens with navigation or submit buttons (representative list):**  
  `app/lib/features/auth/screens/login_screen.dart`  
  `app/lib/features/auth/screens/otp_verify_screen.dart`  
  `app/lib/features/auth/screens/role_selection_screen.dart`  
  `app/lib/features/auth/screens/splash_screen.dart`  
  `app/lib/features/retailer/screens/retailer_home_screen.dart`  
  `app/lib/features/retailer/screens/retailer_catalog_screen.dart`  
  `app/lib/features/retailer/screens/retailer_cart_screen.dart`  
  `app/lib/features/retailer/screens/retailer_order_detail_screen.dart`  
  `app/lib/features/retailer/screens/retailer_partial_receipt_screen.dart`  
  `app/lib/features/retailer/screens/retailer_handshake_screen.dart`  
  `app/lib/features/retailer/screens/payment_declaration_screen.dart`  
  `app/lib/features/driver/screens/driver_marketplace_screen.dart`  
  `app/lib/features/driver/screens/driver_bid_screen.dart`  
  `app/lib/features/driver/screens/driver_active_trip_screen.dart`  
  `app/lib/features/supplier/screens/supplier_dashboard_screen.dart`  
  `app/lib/features/supplier/screens/supplier_web_shell.dart`  
  `app/lib/features/supplier/screens/supplier_inventory_screen.dart`  
  `app/lib/features/supplier/screens/supplier_add_edit_product_screen.dart`  
  `app/lib/features/supplier/screens/supplier_order_detail_screen.dart`  
  `app/lib/features/supplier/screens/supplier_dispute_screen.dart`  
  `app/lib/features/supplier/screens/supplier_delivery_screen.dart`

- **Sync/retry wiring:**  
  `app/lib/core/providers/sync_providers.dart`  
  (Only if banner retry is not already wired; otherwise just verify.)

---

## 8. Definition of Done

- [ ] On Flutter web with real internet, the app does **not** show “Hors connexion” (or Darija equivalent) when the user is online.
- [ ] When network is actually unavailable (or simulated), the offline banner appears; when network returns and user taps “Réessayer”, failed actions retry and the banner updates.
- [ ] Every navigation button (dashboards, catalog, cart, order detail, payment, receipt, handshake, orders, profile, supplier/driver flows) goes to the correct screen with correct params.
- [ ] Every primary submit button (login, OTP, role, order, receipt, payment, bid, PIN, dispute, product save) performs the action, shows loading, and on success/error shows feedback and navigates or re-enables as specified.
- [ ] Splash → Login → (OTP) → Role selection → Dashboard flow works for all roles.
- [ ] Driver handshake/active-trip redirect uses the correct identifier (job id vs order id) and does not break the flow.
- [ ] No new linter errors or regressions in existing tests; existing offline queue and Supabase behavior preserved except for the connectivity and UX fixes above.

---

*End of task prompt.*
