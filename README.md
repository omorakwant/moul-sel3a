# L'Carnet B2B (لكارني) — Moroccan Wholesale Ledger
> **Digitizing the "Rolling Debt" (Carnet) for the Phone Accessory Market.**
> *Built for Derb Ghallef & Garage Allal.*

![Status](https://img.shields.io/badge/Status-Beta_MVP-orange)
![Stack](https://img.shields.io/badge/Tech-Flutter_%7C_Supabase-blue)
![Lang](https://img.shields.io/badge/Lang-Fr_%7C_Darija-green)

## 📱 What is this?
**L'Carnet B2B** is an offline-first mobile app that replaces the paper notebooks used by wholesalers (Grossistes) and retailers (Détaillants).
* **Rolling Debt:** Tracks the continuous balance between suppliers and retailers.
* **Handshake Delivery:** Uses a 4-digit PIN to verify deliveries by independent drivers (Kourtia).
* **Partial Receipts:** Allows retailers to accept/reject items at the doorstep before debt is applied.

## 🏗️ Architecture
* **Frontend:** Flutter (Mobile First).
* **Backend:** Supabase (PostgreSQL).
* **Auth:** Phone OTP (PKCE Flow).
* **Offline Strategy:** "Optimistic Queue" pattern (Hive) for critical writes in low-connectivity areas.
* **Localization:** Hybrid French (Formal) + Moroccan Darija (Action-oriented).

## 🚀 Key Features (Implemented)
| Feature | Status | Description |
| :--- | :--- | :--- |
| **Auth** | ✅ | Phone Login + Role Selection (Supplier/Retailer/Driver). |
| **Catalog** | ✅ | Tiered Pricing (JSONB) + Compatibility Search. |
| **Orders** | ✅ | Cart Management + WhatsApp Deep-linking. |
| **Logistics** | ✅ | Driver Marketplace + Bidding System + PIN Handshake. |
| **Ledger** | ✅ | PostgreSQL Triggers for auto-updating debt balance. |
| **Supplier** | 🚧 | Dashboard & Verification Desk (In Progress). |

## 🛠️ Setup & Installation
1. **Clone:** `git clone https://github.com/YOUR_USERNAME/lcarnet_b2b.git`
2. **Install:** `flutter pub get`
3. **Database:** `supabase db push` (Ensure project is linked)
4. **Run:** `flutter run`

## 🌐 Deploy (Vercel)
**Recommended:** Set **Root Directory** to `app` in Vercel → Project Settings → General. Leave **Build Command** and **Install Command** empty so `app/vercel.json` is used — it runs `app/scripts/install-flutter-vercel.sh` (clones Flutter) then `./flutter/bin/flutter build web`. Output is `build/web`.

**Alternative (repo root):** Root Directory empty. The root `vercel.json` runs `scripts/install-flutter-vercel.sh` and builds from `app/`; output `app/build/web`.

SPA rewrites send unknown paths to `/index.html` so deep links and refresh don’t return 404.

## 📂 Project Structure
* `lib/core/` - Constants, L10n, Theme, Routing
* `lib/data/` - Repositories & Models (Supabase)
* `lib/features/` - Screens & Logic by Role (Retailer/Supplier/Driver)
* `lib/main.dart` - Entry Point

---
*Built with ❤️ for the Moroccan ecosystem.*
