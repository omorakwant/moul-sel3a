# L'Carnet B2B — Project Status & Feature Documentation

> **Single source of truth for what is implemented and what remains to be done.**  
> B2B marketplace for the Moroccan phone accessory ecosystem (Derb Ghallef / Garage Allal style).

---

## 1. Project Overview

| Item | Description |
|------|-------------|
| **Name** | L'Carnet B2B (لكارني B2B) |
| **Vision** | Digitize the "Carnet" (rolling debt) and handshake delivery for wholesalers and retailers. |
| **Scope** | **Frontend-only prototype** for investor demos. No real backend in production; deployed web app uses **mock data**. |
| **Live demo** | https://lcarnetb2b.vercel.app (Retailer flow with mock data, mobile-style layout on desktop). |
| **Repo** | Flutter app in `app/`; root holds `vercel.json`, `build.sh`, docs. |

### Core mechanics (from PROJECT_CONTEXT.md)

- **The Ledger (Carnet):** Continuous cycle of credit and partial payments. Balance = confirmed orders − confirmed payments.
- **Handshake delivery:** Trusted drivers (Kourtia); 4-digit PIN to confirm delivery; optional COD collection.
- **Bilingual UI:** French for structure (e.g. "Solde Actuel"), Moroccan Darija in Arabic script for actions (e.g. "وصلاتني السلعة").
- **Currency:** All amounts in **X.XX DH**.

---

## 2. Tech Stack

| Layer | Choice |
|-------|--------|
| **Framework** | Flutter |
| **State** | Riverpod (providers, StateNotifier, FutureProvider, etc.) |
| **Routing** | GoRouter (auth guard, role-based redirects) |
| **Backend (app code)** | Supabase client (profiles, relations, products, orders, ledger, delivery_jobs, delivery_bids). **Not used on web prototype** — web uses mock data only. |
| **Offline queue** | SyncService + Hive box `sync_action_queue` (confirm receipt, declare payment, verify delivery). Used when not on web. |
| **Localization** | Custom `AppLocalizations` (FR / Darija), no .arb files |
| **Deployment** | Flutter Web → Vercel (`build.sh` clones Flutter, builds `app/build/web`) |

---

## 3. Features already done

### 3.1 Authentication & onboarding

| Feature | Status | Notes |
|---------|--------|-------|
| Splash screen | ✅ Done | Logo, app title, loading; routes by auth state. |
| Phone login (OTP) | ✅ Done | Supabase Phone Auth (PKCE); phone input, send OTP, OTP verify screen. |
| Role selection | ✅ Done | Supplier / Retailer / Driver; sets profile role. |
| Pending verification | ✅ Done | Screen when retailer waits for supplier to approve relation. |
| Auth guard & redirect | ✅ Done | Unauthenticated → login; needs onboarding → role selection; authenticated → role dashboard. |
| **Web prototype bypass** | ✅ Done | On web (`kIsWeb`): no login, user = mock retailer "Hanout Moulay", always go to Retailer dashboard. |
| Test mode toggle | ✅ Done | `testModeEnabledProvider` for local testing with fake retailer (non-web). |
| Language toggle (FR / AR) | ✅ Done | Login and profile; `localeProvider` + `selectedLocaleProvider`. |

### 3.2 Retailer flow (mobile)

| Feature | Status | Notes |
|---------|--------|-------|
| **Dashboard (home)** | ✅ Done | Total balance card, list of supplier cards (name, balance, credit limit), Pay / Buy actions, "Nouvelle Commande" FAB, tab bar. |
| **Catalog** | ✅ Done | Grid of products; tiered pricing; compatibility filter (model dropdown); brand filter; search; "Nouveau" tag; add to cart. |
| **Voice search (catalog)** | ✅ Done | Long-press on search bar triggers speech_to_text (Darija/French); recognized words auto-fill search field. Microphone icon/tooltip. |
| **Cart** | ✅ Done | Cart items, quantity +/- , tiered price per line, total, "Valider la Commande" (submit order). |
| **Orders list** | ✅ Done | "Mes commandes" — list of orders with status, total, date. |
| **Order detail** | ✅ Done | Items, totals, status, driver name; actions: Partial receipt, WhatsApp, etc. |
| **Partial receipt** | ✅ Done | Adjust received quantity per line; adjusted total; "J'ai reçu la marchandise" confirm; offline-safe via SyncService when not web. |
| **Handshake (retailer)** | ✅ Done | Screen showing order summary, PIN entry for driver handshake. |
| **Payment declaration** | ✅ Done | Select payment method (Wafacash, CashPlus, etc.); photo of receipt; amount + reference code; submit (pending ledger entry); offline-safe when not web. |
| **Profile** | ✅ Done | Shop name, city, location, language; logout. |
| **Web prototype data** | ✅ Done | On web: dashboard, catalog, orders, ledger, relations, and order detail use **mock data** (mock_data.dart). No Supabase. |

### 3.3 Supplier flow (web/tablet)

| Feature | Status | Notes |
|---------|--------|-------|
| **Dashboard** | ✅ Done | Overview, new orders, quick access (inventory, verification, deliveries), stats. |
| **Inventory** | ✅ Done | Product list; filters; add product; edit product; bulk price adjustment modal (fixed offset / percentage, preview table). |
| **Add/Edit product** | ✅ Done | Name, description, brand, image, compatibility list, price tiers (JSONB), "Nouveau", stock. |
| **Bulk price adjustment** | ✅ Done | Select multiple products; modal: fixed DH or %; preview old → new; apply. |
| **Order detail** | ✅ Done | Order info, status, driver; confirm / reject order; assign driver; move to "ready for pickup" / "shipped". |
| **Verification desk** | ✅ Done | Pending payment declarations; receipt view; approve / reject payment; balance impact preview. |
| **Dispute screen** | ✅ Done | Reject payment with reason. |
| **Bid manager** | ✅ Done | Per delivery job: list of driver bids; accept bid (generates PIN). |
| **Deliveries** | ✅ Done | List of delivery jobs; status. |
| **Profile** | ✅ Done | Supplier profile. |
| **Web shell** | ✅ Done | Sidebar layout (dark), nav (Dashboard, Inventaire, Vérifications, etc.). |
| **Web prototype data** | ❌ Not wired | Supplier flow still uses Supabase. Demo is Retailer-only on web. |

### 3.4 Driver flow (mobile)

| Feature | Status | Notes |
|---------|--------|-------|
| **Marketplace** | ✅ Done | List of open delivery jobs (pickup, dropoff, COD flag). |
| **Bid screen** | ✅ Done | Place bid (amount, message); submit. |
| **Active trip** | ✅ Done | Job details; start trip; "I arrived"; enter 4-digit PIN to confirm delivery; COD collection flow. |
| **Handshake redirect** | ✅ Done | Post-PIN redirect/confirmation. |
| **Web prototype data** | ❌ Not wired | Driver flow still uses Supabase. |

### 3.5 Shared / infrastructure

| Feature | Status | Notes |
|---------|--------|-------|
| **Bilingual strings** | ✅ Done | `AppLocalizations`: dashboard, catalog, actions, logistics, status, verification, payment, etc. (FR + Darija). |
| **Currency & date** | ✅ Done | `Formatters`: X.XX DH; DD/MM/YYYY. |
| **Tiered pricing logic** | ✅ Done | `Formatters.resolveTieredPrice(priceTiers, qty)`; cart uses it. |
| **Offline status banner** | ✅ Done | "Hors connexion", "Synchronisation en cours", failed + "Réessayer". |
| **Simulated offline (demo)** | ✅ Done | Triple-tap on app title ("L'Carnet B2B") toggles `simulatedOfflineProvider`; banner shows without turning off network. |
| **Desktop-as-mobile wrapper** | ✅ Done | Viewport &gt; 600px: centered 450px container, shadow, outer background #1C1917. |
| **Debug banner** | ✅ Done | `debugShowCheckedModeBanner: false`. |
| **SyncService (offline queue)** | ✅ Done | Hive-backed queue; confirm receipt, declare payment, verify delivery; retry; dead-letter after 5 retries. Used when not on web. |
| **GoRouter** | ✅ Done | Splash, login, OTP, role selection, pending verification; retailer/driver/supplier routes; 404. |
| **Theme** | ✅ Done | AppTheme (Manrope, Inter, accent orange, cards, buttons). |

### 3.6 Mock data (prototype)

| Item | Status | Location / content |
|------|--------|--------------------|
| **Mock profiles** | ✅ Done | 1 supplier, 2 retailers (Hanout Moulay, Téléphonie Fès). `mock_data.dart`. |
| **Mock relations** | ✅ Done | 2 relations with `credit_limit`, `current_balance`. |
| **Mock products** | ✅ Done | 6 phone accessories; `compatibility_list`; `price_tiers` (e.g. 1/10/50). |
| **Mock ledger** | ✅ Done | 3 transactions (order_increase, payment_decrease) for demo history. |
| **Mock orders** | ✅ Done | 2 orders for first retailer (delivered + shipped). |
| **Mock auth** | ✅ Done | `mockCurrentUserProvider` (first retailer); used on web. |

---

## 4. Features not done / to do

### 4.1 Backend & data

| Item | Status | Notes |
|------|--------|-------|
| **Production backend** | ❌ Not done | Prototype is frontend-only; no Supabase in production for demo. Real app would need migrations, RLS, triggers. |
| **Ledger balance trigger** | ❌ Not in repo | PROJECT_CONTEXT specifies: `current_balance` updates only when ledger_transaction is `verified`. Not implemented in prototype. |
| **Supplier/Driver mock on web** | ❌ Not done | Only Retailer flow uses mock data on web. Supplier/Driver would need similar `kIsWeb` branches if demo should show them. |

### 4.2 Retailer

| Item | Status | Notes |
|------|--------|-------|
| **Receipt OCR** | ❌ Not done | Photo of receipt is stored; no OCR for auto-fill of amount/reference. |
| **WhatsApp pre-fill after payment** | ✅ Done | After payment declaration, success sheet shows "Notifier le grossiste (WhatsApp)" with pre-filled message (amount, reference, method) in FR/Darija. |

### 4.3 Supplier

| Item | Status | Notes |
|------|--------|-------|
| **Create retailer relation** | ⚠️ Partial | `RelationRepository.createRelation` exists (Supplier only). No dedicated Supplier UI screen for adding/inviting retailer found; retailer side has "Add grossiste via WhatsApp" (invite link only). |
| **Push/WhatsApp on new payment** | ❌ Not done | "Supplier receives Push Notification and WhatsApp" on retailer payment declaration — not implemented. |

### 4.4 Driver

| Item | Status | Notes |
|------|--------|-------|
| **WhatsApp confirmation** | ⚠️ Partial | Deep link to WhatsApp for driver communication; exact flow not fully documented. |

### 4.5 Offline & sync

| Item | Status | Notes |
|------|--------|-------|
| **Real connectivity on web** | ⚠️ N/A | .cursorrules say avoid real `connectivity_plus` on web to avoid emulator issues; prototype uses **simulated** offline (triple-tap). |
| **Offline read cache** | ❌ Not done | SyncService queues **writes**. No Hive/SQLite cache for reading catalog/orders offline in prototype. |

### 4.6 DevOps & polish

| Item | Status | Notes |
|------|--------|-------|
| **E2E / integration tests** | ❌ Not done | Unit tests exist for formatters, errors, etc.; no full flow E2E. |
| **Environment config** | ⚠️ Partial | Supabase URL/keys in constants; no env-based config for multiple backends. |
| **Accessibility** | ⚠️ Not audited | No formal a11y audit. |

---

## 5. Prototype-specific behavior (web deploy)

When the app runs **on web** (e.g. https://lcarnetb2b.vercel.app):

1. **Auth:** No login. Current user = first mock retailer ("Hanout Moulay"). Redirect = Retailer dashboard.
2. **Data:** All retailer-facing data comes from `lib/data/mock_data.dart` (relations, products, ledger, orders). No Supabase calls for that flow.
3. **Layout:** If viewport width &gt; 600px, app is shown in a 450px-wide centered "phone" frame on dark gray (#1C1917).
4. **Offline demo:** Triple-tap the app bar title to toggle simulated offline; OfflineStatusBanner appears (amber/red).
5. **Supplier/Driver:** If user could switch role to Supplier/Driver on web, those flows would still call Supabase (and would fail without backend). Demo is intended as **Retailer only**.

---

## 6. File / structure reference

| Path | Purpose |
|------|---------|
| `app/lib/main.dart` | Entry; Hive init; Supabase init; SyncService init. |
| `app/lib/app.dart` | MaterialApp.router; desktop-as-mobile wrapper; theme; l10n. |
| `app/lib/core/routing/app_router.dart` | GoRouter; auth redirect; all routes. |
| `app/lib/core/l10n/app_localizations.dart` | All FR/Darija strings. |
| `app/lib/core/theme/` | AppTheme, AppColors. |
| `app/lib/core/providers/sync_providers.dart` | SyncService, queue status, simulatedOfflineProvider. |
| `app/lib/data/mock_data.dart` | Mock profiles, relations, products, ledger, orders; mockCurrentUserProvider. |
| `app/lib/data/models/` | Profile, Product, Order, LedgerTransaction, SupplierRetailerRelation, etc. |
| `app/lib/data/repositories/` | Supabase-backed repos (profile, relation, product, order, ledger, delivery). |
| `app/lib/data/services/sync_service.dart` | Offline action queue (Hive). |
| `app/lib/features/auth/` | Splash, login, OTP, role selection, pending verification; auth_providers. |
| `app/lib/features/retailer/` | Dashboard, catalog, cart, orders, order detail, partial receipt, payment declaration, handshake, profile; providers (with kIsWeb mock branches). |
| `app/lib/features/supplier/` | Dashboard, inventory, add/edit product, bulk price, verification, order detail, bid manager, deliveries, profile, web shell. |
| `app/lib/features/driver/` | Marketplace, bid, active trip, handshake redirect. |
| `app/lib/features/shared/` | OfflineStatusBanner, AppTitleWithOfflineToggle. |
| `vercel.json` | Build command `./build.sh`, output `app/build/web`, SPA rewrites. |
| `build.sh` | Clone Flutter, `flutter build web --release` in `app/`. |

---

## 7. How to run & deploy

- **Local (with backend):** `cd app && flutter pub get && flutter run` (choose device/web). Requires Supabase project if you use login and real data.
- **Local (web, mock only):** Same; on web, app uses mock data and skips login.
- **Deploy:** Push to `main`; Vercel runs `./build.sh` and serves `app/build/web`. See `DEPLOY_VERCEL.md` for dashboard steps.

---

*Last updated: Mar 2025 — from codebase review and PROJECT_CONTEXT.md / prototype.md / .cursorrules. Voice search (catalog) and WhatsApp notify-after-payment confirmed implemented.*
