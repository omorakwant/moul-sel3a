# L'Carnet B2B (لكارني) — Moroccan Wholesale Ledger

> **Digitizing the "Rolling Debt" (Carnet) for the Phone Accessory Market.**  
> *Built for Derb Ghallef & Garage Allal.*

![Status](https://img.shields.io/badge/Status-Prototype_Demo-orange)
![Stack](https://img.shields.io/badge/Tech-Flutter_%7C_Web-blue)
![Lang](https://img.shields.io/badge/Lang-Fr_%7C_Darija-green)

## What is this?

**L'Carnet B2B** is a B2B marketplace app for the Moroccan phone accessory ecosystem. It replaces paper notebooks (Carnets) with:

- **Rolling debt (Solde):** Tracks balance between suppliers and retailers across multiple suppliers.
- **Handshake delivery:** PIN-based confirmation with independent drivers (Kourtia).
- **Partial receipts:** Retailers adjust received quantities at delivery before debt is applied.
- **Bilingual UI:** French for structure, Moroccan Darija (Arabic script) for actions.

## Live prototype

**https://lcarnetb2b.vercel.app**

- No login on web: you land as the mock retailer **"Hanout Moulay"**.
- Use the **role switcher** (Retailer | Supplier | Driver) in the app bar to view Supplier or Driver flow with mock data. All three roles use **mock data** on web.
- On desktop the app appears in a 450px “phone” frame. Triple-tap the app title to toggle the offline demo banner.

## Documentation

| Document | Purpose |
|----------|---------|
| **[PROJECT_STATUS.md](PROJECT_STATUS.md)** | **Full feature list: what’s done and what’s not.** Use this for scope and handoffs. |
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Vision, user roles, specs, offline strategy, DB hints, bilingual map. |
| [prototype.md](prototype.md) | Prototype scope and core features to mock. |
| [.cursorrules](.cursorrules) | Prototype rules (frontend-only, mock data, tech stack). |
| [DEPLOY_VERCEL.md](DEPLOY_VERCEL.md) | How to deploy the Flutter web app to Vercel. |

## Architecture

| Layer | Choice |
|-------|--------|
| **Frontend** | Flutter (mobile-first; web deploy for demo). |
| **State** | Riverpod. |
| **Routing** | GoRouter (auth guard, role-based dashboards). |
| **Backend** | Supabase (used in code for non-web; **web demo uses mock data only**). |
| **Offline** | SyncService + Hive queue for critical writes; simulated offline on web (triple-tap). |
| **Localization** | French + Moroccan Darija via `AppLocalizations`. |

## Features (summary)

- **Auth:** Splash, phone OTP login, role selection (Supplier / Retailer / Driver). On web: skip login, mock retailer.
- **Retailer:** Dashboard (balance, suppliers), catalog (tiered pricing, compatibility filter, voice search), cart, orders, order detail, partial receipt, payment declaration (with WhatsApp notify supplier + pre-filled message), handshake, profile.
- **Supplier:** Dashboard, inventory, add/edit product, bulk price adjustment, verification desk, order detail, bid manager, deliveries, profile (web shell layout).
- **Driver:** Marketplace (open jobs), place bid, active trip, PIN handshake, COD flow.
- **Shared:** Bilingual strings, DH/date formatting, offline banner, desktop-as-mobile wrapper for demo.

See **[PROJECT_STATUS.md](PROJECT_STATUS.md)** for the complete done / not-done list (including voice search, WhatsApp notify-after-payment, and remaining gaps).

## Setup & run

```bash
cd app
flutter pub get
flutter run
```

Choose **Chrome** or **web server** to test the web prototype (mock data, no login). For native or Supabase-backed flows, configure Supabase and run on iOS/Android/web as needed.

## Deploy (Vercel)

- **Build:** `./build.sh` (root). Script clones Flutter and runs `flutter build web` in `app/`.
- **Output:** `app/build/web`.
- **Config:** See [vercel.json](vercel.json) and [DEPLOY_VERCEL.md](DEPLOY_VERCEL.md).

---

*Built for the Moroccan ecosystem.*
