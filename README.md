# L'Carnet B2B — Development Tracker

> **مول السلعة** — Morocco B2B Phone Accessory Marketplace
> Built with Flutter + Supabase · Bilingual FR/Darija

---

## 📋 Project Summary

**L'Carnet B2B** (لكارني B2B) is a high-utility B2B marketplace for the Moroccan phone accessory ecosystem (Derb Ghallef, Garage Allal style). It digitizes the traditional "Carnet" (rolling debt notebook) used between wholesalers (المالين السلعة) and retailers (مول الحانوت), with an InDrive-style delivery bidding system for independent drivers (كورتيا).

### Core Principles
- **Utility over Decoration** — every feature mirrors the real-world workflow of a Moroccan Moul Hanout
- **Offline-First** — works in the basement of a Souk (supabase_flutter PKCE + local caching)
- **Bilingual** — French for professional structure + Darija for direct action/status
- **Rolling Debt, Not Settlement** — transactions are rarely settled to zero; it's a continuous cycle

### Tech Stack
| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| State Management | flutter_riverpod ^2.5.0 |
| Routing | go_router ^14.0.0 |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| Auth | Phone OTP (PKCE) |
| Local Storage | hive_flutter |
| Communication | WhatsApp deep links (url_launcher) |

### Codebase Stats (as of commit `phase2`)
| Metric | Count |
|--------|-------|
| Dart source files | 67 |
| Lines of Dart | ~18,500 |
| SQL migration lines | ~792 |
| L10n strings | ~200+ (FR + Darija) |
| Total commits | 14 |
| Database tables | 7 |
| Supabase triggers | 3 |
| RLS policies | ~20 |

---

## 🏗️ Architecture Overview

```
app/lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + theme + l10n
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   └── supabase_constants.dart    # Table names, bucket, keys
│   ├── l10n/
│   │   └── app_localizations.dart     # Bilingual FR/Darija (~200+ strings)
│   ├── routing/
│   │   └── app_router.dart            # GoRouter — all role-based routes
│   ├── theme/
│   │   ├── app_colors.dart            # Design tokens from UI&UX.pen
│   │   └── app_theme.dart             # ThemeData configuration
│   └── utils/
│       ├── bulk_price_logic.dart       # Bulk price adjustment engine
│       └── formatters.dart            # Price, date, WhatsApp, tiered pricing
├── data/
│   ├── models/                        # Equatable data models
│   │   ├── profile.dart               # User profile (supplier/retailer/driver)
│   │   ├── product.dart               # Product with JSONB price_tiers
│   │   ├── order.dart                 # Digital Bon + OrderItem
│   │   ├── delivery_job.dart          # Delivery job with PIN
│   │   ├── delivery_bid.dart          # Driver bid
│   │   ├── ledger_transaction.dart    # Financial ledger entry
│   │   ├── supplier_retailer_relation.dart  # The "Carnet" link
│   │   ├── cart_item.dart             # Cart item model
│   │   └── models.dart                # Barrel export
│   ├── repositories/                  # Supabase CRUD operations
│   │   ├── profile_repository.dart
│   │   ├── product_repository.dart
│   │   ├── order_repository.dart
│   │   ├── delivery_repository.dart   # Jobs + bids + PIN verification
│   │   ├── ledger_repository.dart
│   │   ├── relation_repository.dart
│   │   └── repositories.dart          # Barrel export
│   └── services/
│       ├── supabase_service.dart       # Supabase client provider
│       └── phone_auth_service.dart     # Phone OTP authentication
└── features/
    ├── auth/                           # Authentication flow
    │   ├── providers/auth_providers.dart
    │   └── screens/ (5 screens)
    ├── retailer/                       # Retailer (Buyer) experience
    │   ├── providers/ (4 providers)
    │   ├── screens/ (6 screens)
    │   └── widgets/ (2 widgets)
    ├── driver/                         # Driver (Livreur) experience
    │   ├── providers/driver_providers.dart
    │   └── screens/ (3 screens)
    ├── supplier/                       # Supplier (Admin) experience
    │   ├── providers/supplier_inventory_providers.dart
    │   └── screens/ (4 screens)
    └── shared/shared.dart              # Shared widgets barrel
```

### Database Schema (7 Tables)

```
supabase/migrations/
├── 20260216200000_initial_schema.sql   # Core schema (678 lines)
└── 20260217100000_logistics_flow.sql   # Logistics additions (114 lines)
```

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `profiles` | User accounts (auto-created on signup) | shop_name, role, city, location_name, preferred_language |
| `supplier_retailer_relations` | The "Carnet" — rolling debt per pair | credit_limit, current_balance, status |
| `products` | Supplier catalog | price_tiers (JSONB), compatibility_list (TEXT[]), is_new |
| `orders` | Digital Bon (الطلبية) | items (JSONB), adjusted_total, driver_name, delivery_type |
| `delivery_jobs` | Delivery requests (InDrive model) | pickup/dropoff cities & location_names, delivery_pin, cod_amount |
| `delivery_bids` | Driver price proposals | bid_amount, estimated_time, status |
| `ledger_transactions` | Financial source of truth | transaction_type, amount, payment_method, evidence_url |

**Critical Triggers:**
1. `fn_update_rolling_balance` — Updates `current_balance` in relations ONLY when ledger status → `verified`
2. `fn_set_updated_at` — Auto-timestamps on all tables
3. `fn_generate_delivery_pin` — Auto-generates 4-digit PIN when driver is assigned

---

## 📅 Commit History & Timeline

All development occurred on **February 16, 2026**.

| # | Commit | Description |
|---|--------|-------------|
| 1 | `ad3b73e` | **Initial scaffold** — Flutter project, Supabase config, design tokens, SQL schema (7 tables + triggers + RLS), data models, repositories, services |
| 2 | `98de323` | **Retailer dashboard** — multi-supplier view, balance cards, supplier picker |
| 3 | `ffa400c` | **Product catalog** — brand filters, tiered pricing display, compatibility search |
| 4 | `b43d9d0` | **Compliance fix #1** — mic voice search, WhatsApp FAB, Add to Cart button |
| 5 | `eaf3138` | **Orders** — order detail, partial receipt with +/- steppers, handshake confirmation |
| 6 | `78a4328` | **Compliance fix #2** — WhatsApp voice note, disclaimer wording, l10n badge, DH format |
| 7 | `d878cc2` | **Auth** — phone OTP login, role selection, bilingual onboarding, pending verification gate |
| 8 | `12440b7` | **i18n persistence** — role + preferred_language saved in profiles table |
| 9 | `4ce618d` | **Supplier inventory** — product add/edit form, tiered pricing editor, bulk price adjustment |
| 10 | `6c66cd7` | **Retailer cart** — cart providers, order creation, WhatsApp share |
| 11 | `5e5d39f` | **Credit guard** — sticky bottom bar with real-time cart total + credit limit warning |
| 12 | `482a4a1` | **WhatsApp template** — Moroccan B2B format (Salaam, bullet items, Total Estimé) |
| 13 | `62c3f8f` | **Logistics flow** — driver marketplace, bidding, PIN handshake, ledger auto-update |
| 14 | — | **Phase 2+3** — Supplier dashboard, retailer orders list, payment declaration, verification desk, order→ledger wiring, delivery job auto-creation, +70 l10n strings, 3 bug fixes |

---

## ✅ Implemented Features

### 🔐 Authentication & Onboarding
| Feature | Status | Files |
|---------|--------|-------|
| Phone OTP login (+212 Morocco) | ✅ Done | `login_screen.dart`, `phone_auth_service.dart` |
| OTP verification screen | ✅ Done | `otp_verify_screen.dart` |
| Role selection (Supplier/Retailer/Driver) | ✅ Done | `role_selection_screen.dart` |
| Bilingual role descriptions | ✅ Done | `app_localizations.dart` |
| Language persistence (fr/ar in profile) | ✅ Done | `profile_repository.dart` |
| Pending verification gate | ✅ Done | `pending_verification_screen.dart` |
| Splash screen + auth routing | ✅ Done | `splash_screen.dart`, `auth_providers.dart` |

### 🏪 Retailer Experience
| Feature | Status | Files |
|---------|--------|-------|
| Multi-supplier dashboard | ✅ Done | `retailer_home_screen.dart` |
| Supplier cards (balance, credit limit) | ✅ Done | `supplier_card.dart` |
| Add supplier (WhatsApp deep link) | ✅ Done | `retailer_home_screen.dart` |
| Product catalog with brand tabs | ✅ Done | `retailer_catalog_screen.dart` |
| Compatibility-first search | ✅ Done | `catalog_providers.dart` |
| Tiered pricing display & resolution | ✅ Done | `product_card.dart`, `formatters.dart` |
| "Nouveau" (جديد) tag | ✅ Done | `product_card.dart` |
| Add to cart with quantity stepper | ✅ Done | `product_card.dart` |
| Cart screen with order creation | ✅ Done | `retailer_cart_screen.dart` |
| Sticky credit guard bar | ✅ Done | `retailer_catalog_screen.dart` |
| Over-credit-limit warning | ✅ Done | `catalog_providers.dart` |
| WhatsApp order sharing | ✅ Done | `retailer_cart_screen.dart`, `formatters.dart` |
| Order detail view | ✅ Done | `retailer_order_detail_screen.dart` |
| Partial receipt (+/- steppers) | ✅ Done | `retailer_partial_receipt_screen.dart` |
| Handshake confirmation | ✅ Done | `retailer_handshake_screen.dart` |
| Order history with status filters | ✅ Done | `retailer_orders_screen.dart` |
| Payment declaration (receipt photo) | ✅ Done | `payment_declaration_screen.dart`, `payment_providers.dart` |

### 📦 Supplier Experience
| Feature | Status | Files |
|---------|--------|-------|
| Product inventory list | ✅ Done | `supplier_inventory_screen.dart` |
| Add/edit product form | ✅ Done | `supplier_add_edit_product_screen.dart` |
| Tiered pricing editor | ✅ Done | `supplier_add_edit_product_screen.dart` |
| Compatibility model picker | ✅ Done | `supplier_add_edit_product_screen.dart` |
| Bulk price adjustment | ✅ Done | `bulk_price_adjustment_modal.dart`, `bulk_price_logic.dart` |
| Preview changes before apply | ✅ Done | `bulk_price_adjustment_modal.dart` |
| Bid manager (view/accept bids) | ✅ Done | `supplier_bid_manager_screen.dart` |
| Supplier dashboard (3-tab admin) | ✅ Done | `supplier_dashboard_screen.dart`, `supplier_dashboard_providers.dart` |
| Order confirm/reject/ready_for_pickup | ✅ Done | `supplier_dashboard_providers.dart` |
| Verification desk (approve/reject) | ✅ Done | `supplier_verification_screen.dart`, `supplier_verification_providers.dart` |
| Order→Ledger auto-wiring | ✅ Done | `supplier_dashboard_providers.dart` |
| Delivery job auto-creation | ✅ Done | `supplier_dashboard_providers.dart` |

### 🚚 Driver / Logistics Experience
| Feature | Status | Files |
|---------|--------|-------|
| Driver marketplace (open jobs feed) | ✅ Done | `driver_marketplace_screen.dart` |
| Text-based route cards (no maps) | ✅ Done | `driver_marketplace_screen.dart` |
| Active trips banner | ✅ Done | `driver_marketplace_screen.dart` |
| Bid submission form | ✅ Done | `driver_bid_screen.dart` |
| Duplicate bid detection | ✅ Done | `driver_providers.dart` |
| Active trip screen (status flow) | ✅ Done | `driver_active_trip_screen.dart` |
| Start Trip → In Transit | ✅ Done | `driver_active_trip_screen.dart` |
| "I've Arrived" button | ✅ Done | `driver_active_trip_screen.dart` |
| 4-digit PIN handshake | ✅ Done | `driver_active_trip_screen.dart` |
| PIN auto-generation trigger | ✅ Done | `20260217100000_logistics_flow.sql` |
| COD ledger auto-update | ✅ Done | `delivery_repository.dart` |
| Supplier bid acceptance | ✅ Done | `supplier_bid_manager_screen.dart` |
| Location name fields (profiles + jobs) | ✅ Done | `profile.dart`, `delivery_job.dart` |

### 🌐 Localization
| Feature | Status | Files |
|---------|--------|-------|
| French strings | ✅ Done | `app_localizations.dart` |
| Moroccan Darija strings | ✅ Done | `app_localizations.dart` |
| L10n JSON reference map | ✅ Done | `l10n_map.json` |
| ~200+ bilingual strings | ✅ Done | — |

### 💾 Database & Backend
| Feature | Status | Files |
|---------|--------|-------|
| 7 tables with full schema | ✅ Done | `20260216200000_initial_schema.sql` |
| Rolling balance trigger | ✅ Done | `fn_update_rolling_balance` |
| Reversal support (verified → rejected) | ✅ Done | `fn_update_rolling_balance` |
| RLS policies (role-scoped) | ✅ Done | ~20 policies |
| PIN generation trigger | ✅ Done | `fn_generate_delivery_pin` |
| Auto `updated_at` trigger | ✅ Done | `fn_set_updated_at` |
| Auth hook (auto profile creation) | ✅ Done | `handle_new_user` |
| Storage bucket (lcarnet-assets) | ✅ Done | Initial migration |

---

## 🚧 Yet to Be Built

### Priority 1 — Remaining Placeholder Routes
| Feature | Route | Priority | Description |
|---------|-------|----------|-------------|
| ~~Retailer Orders List~~ | ~~`/retailer/orders`~~ | ✅ Done | ~~List of all orders with status filters~~ |
| ~~Payment Declaration~~ | ~~`/retailer/payment/:relationId`~~ | ✅ Done | ~~Wafacash/CashPlus receipt photo + form~~ |
| Retailer Profile | `/retailer/profile` | 🟡 Medium | Edit shop name, city, location_name, avatar, language preference |
| ~~Supplier Dashboard~~ | ~~`/supplier/dashboard`~~ | ✅ Done | ~~Overview: pending orders, revenue, retailer list~~ |
| ~~Supplier Verification Desk~~ | ~~`/supplier/verification`~~ | ✅ Done | ~~Approve/reject payment evidence~~ |
| Supplier Dispute Resolution | `/supplier/dispute/:transactionId` | 🟡 Medium | Dispute flow for rejected payments |
| Driver Handshake View | `/driver/handshake/:orderId` | 🟢 Low | Redundant — PIN is already handled in active trip screen |

### Priority 2 — Critical Business Logic
| Feature | Priority | Description |
|---------|----------|-------------|
| ~~Supplier order management~~ | ✅ Done | ~~Confirm/reject orders, mark ready_for_pickup~~ |
| ~~Delivery job creation~~ | ✅ Done | ~~Auto-create delivery_job on ready_for_pickup~~ |
| ~~Order→Ledger wiring~~ | ✅ Done | ~~Auto-create order_increase on order confirmation~~ |
| ~~Payment receipt photo upload~~ | ✅ Done | ~~ImagePicker + Supabase Storage upload~~ |
| Push notifications | 🟡 Medium | Order placed, bid received, payment declared, delivery completed |
| Retailer order tracking | 🟡 Medium | Real-time status updates on order detail screen |

### Priority 3 — Enhancements
| Feature | Priority | Description |
|---------|----------|-------------|
| Offline-first caching (Hive) | 🟡 Medium | Cache products, orders, profile locally for souk basement usage |
| Speech-to-text search | 🟢 Low | Mic icon in catalog search for Darija/French product names |
| PDF/Image receipt generation | 🟡 Medium | Timestamped delivery confirmation sent via WhatsApp |
| Order timeline/activity feed | 🟢 Low | "New Bon received", "Payment confirmed" feed on dashboard |
| Product image upload | 🟡 Medium | Camera/gallery → Supabase Storage for product photos |
| Trusted driver assignment | 🟡 Medium | Supplier manually assigns from a list of known drivers |
| Driver earnings dashboard | 🟢 Low | Total earnings, completed deliveries, average bid |
| Supplier analytics | 🟢 Low | Revenue trends, top products, retailer activity |
| Logout functionality | 🟡 Medium | Sign-out button + session management |
| WhatsApp deep link stubs | 🟡 Medium | Replace TODO stubs with actual launchUrl() calls |

### Priority 4 — Production Readiness
| Feature | Priority | Description |
|---------|----------|-------------|
| Supabase project setup | 🔴 High | Replace placeholder URL/key in `supabase_constants.dart` |
| Error handling & retry | 🟡 Medium | Network error UX, retry mechanisms, offline queue |
| Unit & widget tests | 🟡 Medium | Test models, repositories, key widgets |
| App icon & splash branding | 🟢 Low | L'Carnet B2B logo, branded splash screen |
| Play Store / App Store prep | 🟢 Low | Screenshots, descriptions (FR/AR), privacy policy |

---

## 🎨 Design System

Extracted from `UI&UX.pen` via Pencil design tool.

### Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `accentOrange` | `#C2410C` | Primary brand, CTAs, active states |
| `successGreen` | `#10B981` | Confirmed, delivered, positive |
| `alertRed` | `#EF4444` | Errors, over-limit warnings |
| `bgPrimary` | `#FAF9F7` | Main background |
| `bgSurface` | `#E7E5E4` | Cards, elevated surfaces |
| `bgMuted` | `#D6D3D1` | Borders, dividers |
| `bgDark` | `#2D2D2D` | Dark mode elements |
| `textPrimary` | `#2D2D2D` | Headings, body text |
| `textSecondary` | `#78716C` | Subtitles, metadata |
| `textTertiary` | `#A8A29E` | Hints, disabled text |
| `onAccent` | `#FAF9F7` | Text on orange/dark backgrounds |

### Typography
| Use | Font | Weight |
|-----|------|--------|
| Headings | Manrope | 700–800 |
| Body text | Inter | 400–600 |

### Formatting Rules
| Rule | Format |
|------|--------|
| Currency | `X.XX DH` |
| Dates | DD/MM/YYYY |
| Phone | +212 prefix |
| Language | FR default, Darija opt-in |

---

## 🔄 Data Flow Diagrams

### Order → Delivery → Ledger Flow
```
Retailer places order
    ↓
Order created (status: pending)
    ↓
Supplier confirms → status: confirmed
    ↓
Supplier marks ready_for_pickup
    ↓
Delivery job created (status: open)
    ↓
Drivers see job in marketplace → place bids
    ↓
Supplier accepts bid → driver assigned → PIN auto-generated
    ↓
Driver starts trip → status: in_transit
    ↓
Driver arrives → enters 4-digit PIN from retailer
    ↓
PIN verified → job: completed, order: delivered
    ↓
If COD → ledger entry auto-created (payment_decrease, verified)
    ↓
fn_update_rolling_balance trigger → current_balance updated
```

### Payment Declaration Flow (TO BE BUILT)
```
Retailer taps "Déclarer un Paiement"
    ↓
Select payment method (Wafacash/CashPlus/Bank/Cash)
    ↓
Photo receipt + reference code + amount
    ↓
ledger_transaction created (status: pending)
    ↓
Supplier notified → views evidence photo
    ↓
Approve → status: verified → balance decreases
Reject → status: rejected → balance unchanged
```

---

## 📁 File Reference

### SQL Migrations
| File | Lines | Purpose |
|------|-------|---------|
| `20260216200000_initial_schema.sql` | 678 | Core schema: 7 tables, triggers, RLS, indexes |
| `20260217100000_logistics_flow.sql` | 114 | Add location_name, delivery_pin, location labels, RLS |

### Key Data Models
| Model | File | DB Table |
|-------|------|----------|
| `Profile` | `profile.dart` | `profiles` |
| `Product` | `product.dart` | `products` |
| `Order` / `OrderItem` | `order.dart` | `orders` |
| `DeliveryJob` | `delivery_job.dart` | `delivery_jobs` |
| `DeliveryBid` | `delivery_bid.dart` | `delivery_bids` |
| `LedgerTransaction` | `ledger_transaction.dart` | `ledger_transactions` |
| `SupplierRetailerRelation` | `supplier_retailer_relation.dart` | `supplier_retailer_relations` |
| `CartItem` | `cart_item.dart` | (local only) |

### Repositories
| Repository | File | Operations |
|------------|------|------------|
| `ProfileRepository` | `profile_repository.dart` | getCurrentProfile, getById, update |
| `ProductRepository` | `product_repository.dart` | getSupplierProducts, create, update, bulkUpdatePrices |
| `OrderRepository` | `order_repository.dart` | getRetailerOrders, getSupplierOrders, create, updateStatus, confirmPartialReceipt |
| `DeliveryRepository` | `delivery_repository.dart` | getOpenJobs, getDriverJobs, createJob, placeBid, acceptBid, verifyPinAndComplete |
| `LedgerRepository` | `ledger_repository.dart` | getRelationTransactions, create |
| `RelationRepository` | `relation_repository.dart` | getRetailerRelations, getSupplierRelations |

---

## 🏃 How to Continue Development

### Immediate Next Steps (Recommended Order)
1. **Supplier Dashboard** — the admin control center (pending orders, retailer management)
2. **Payment Declaration Screen** — Wafacash receipt photo + ledger entry
3. **Supplier Verification Desk** — approve/reject payment evidence
4. **Retailer Orders List** — filtered order history
5. **Delivery Job Auto-Creation** — trigger on order status → ready_for_pickup
6. **Push Notifications** — Supabase Edge Functions + FCM

### Development Pattern (Established)
```
1. Create/update SQL migration (if schema changes)
2. Update data models (fromJson, toJson, copyWith)
3. Add repository methods
4. Create Riverpod providers
5. Build screen widgets
6. Wire GoRouter routes (replace placeholders)
7. Add l10n strings (FR + Darija)
8. Commit with descriptive message
```

### Running the Project
```bash
# Navigate to Flutter app
cd app

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Supabase (requires local CLI — brew install supabase/tap/supabase)
cd ../supabase
supabase start
supabase db push
```

---

*Last updated: February 16, 2026 · Commit `62c3f8f`*
