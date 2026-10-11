# L'Carnet B2B (لكارني) — Moroccan B2B Wholesale Marketplace & Digital Ledger

> **Digitizing the "Rolling Debt" (Carnet) for Morocco's Wholesale Electronics & Phone Accessory Ecosystem.**  
> *Built for the physical reality of Derb Ghallef, Derb Omar, and Garage Allal.*

[![Cloudflare Pages](https://img.shields.io/badge/Deployed_on-Cloudflare_Pages-F38020?logo=cloudflare&logoColor=white)](https://pages.cloudflare.com/)
[![Next.js](https://img.shields.io/badge/Landing-Next.js_16_%7C_React_19-black?logo=next.js)](https://nextjs.org/)
[![Flutter](https://img.shields.io/badge/Prototype-Flutter_3.29_Web-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Backend](https://img.shields.io/badge/Backend-Supabase_PostgreSQL-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![License](https://img.shields.io/badge/Status-Functional_Prototype-orange.svg)]()

---

## Executive Summary

In Morocco’s commercial wholesale districts, millions of dirhams in inventory move daily on informal trust. Wholesalers (*Grossistes*) and neighborhood shopkeepers (*Hanouts*) track balances in physical paper notebooks called **Le Carnet (لكارني)**.

This traditional system suffers from three critical friction points:
1. **Opaque Rolling Debt:** Continuous orders and partial cash repayments lead to reconciliation disputes over who owes what.
2. **Unverified Last-Mile Deliveries:** Goods are transported by informal street couriers (*Kourtia*) without digital proof of physical handover.
3. **Quantity Discrepancies:** Delivered batches rarely match original invoices exactly (breakages, missing units), creating bad debt before the retailer can adjust the receipt.

**L'Carnet B2B** solves this by providing a high-trust digital ledger with:
- **Real-Time Rolling Debt (`Solde`):** Automatic balance recalculation upon verified deliveries and payments.
- **PIN-Based "Handshake" Protocol:** Eliminates GPS dependence; drivers receive a 4-digit PIN that the shopkeeper enters to confirm physical delivery.
- **Partial Receipt Adjustment:** Retailers adjust quantities on delivery before transactions hit the debt ledger.
- **Bilingual Interface:** French for administrative structure, Moroccan Darija (Arabic script) for quick physical actions.

---

## Unified Monorepo Architecture

The repository is architected as a **single unified web application** hosted on **Cloudflare Pages**:

```
                       https://your-domain.pages.dev
                                     │
           ┌─────────────────────────┴─────────────────────────┐
           ▼                                                   ▼
      Root Route (/)                               Subpath (/prototype/)
 ┌───────────────────────┐                       ┌───────────────────────┐
 │ Next.js 16 Marketing  │                       │   Flutter 3.29 Web    │
 │     Landing Page      │   CTA Links & Roles   │   Product Prototype   │
 │                       ├──────────────────────►│                       │
 │ • Value propositions  │  ?role=retailer/      │ • Hanout Ledger       │
 │ • Interactive pricing │        supplier/      │ • Supplier Dashboard  │
 │ • WhatsApp / Contact  │        driver         │ • Driver Marketplace  │
 └───────────────────────┘                       └───────────────────────┘
```

Both targets share identical design tokens:
- **Primary Brand Saffron:** `#FF6B00` (Safety orange with neon glow)
- **Surfaces:** `#1C1917` (Dark onyx desktop frame) and `#000000` (Deep black)
- **Unified Typography:** `Manrope` (Headings) and `Inter` (Body & Ledger Numerics)

---

## Interactive Prototype Roles

On web, the prototype loads with rich, offline-first mock data (*Derb Omar / Casablanca wholesale catalog*). You can toggle between all three commercial roles instantly:

| Role | Target Persona | Key Demonstrated Features | Direct Route |
| :--- | :--- | :--- | :--- |
| **Retailer (Hanout)** | Neighborhood shopkeeper | Live supplier debt card, catalog with tiered pricing, voice search, partial receipts, WhatsApp payment declaration | `/prototype?role=retailer` |
| **Supplier (Grossiste)** | Electronics importer / wholesale depot | Desktop sidebar web shell, inventory stock manager, bulk percentage price adjustments, retailer KYC verification desk | `/prototype?role=supplier` |
| **Driver (Kourtia)** | Independent motorcycle courier | Open delivery bids, active trip route, PIN handshake delivery verification, COD cash collection | `/prototype?role=driver` |

*Use the top role switcher chip `[Retailer | Supplier | Driver]` to switch personas at any time, or click `[← Site Web]` to return to the marketing landing page.*

---

## Technology Stack

### 1. Marketing Landing Site ([`lcarnet-b2b-landing/`](lcarnet-b2b-landing))
- **Framework:** Next.js 16.2 (App Router, Static Export)
- **UI & Animation:** React 19, Tailwind CSS v4, Framer Motion, Lucide Icons
- **Lead Generation:** Formspree contact endpoint + direct WhatsApp Business Floating Action Button
- **Typography:** `next/font/google` (`Manrope` + `Inter`)

### 2. Functional Product Prototype ([`app/`](app))
- **Framework:** Flutter 3.29+ Web (Dart 3.2+)
- **State Management:** Riverpod 2.5 + Riverpod Annotation
- **Routing:** GoRouter 14 (deep linking with `?role=` query parameter parsing)
- **Storage & Cache:** Hive + SharedPreferences (Offline-first write queues)
- **Responsiveness:** Auto-adaptive 450px mobile phone frame on desktop for Retailer/Driver; full wide-screen sidebar layout for Supplier

### 3. Backend & Cloud Infrastructure ([`supabase/`](supabase))
- **Database:** Supabase (PostgreSQL 15) with Row Level Security (RLS)
- **Auth:** Supabase PKCE Phone OTP Auth
- **Triggers:** Automated rolling debt recalculation triggers on `ledger_transactions`
- **Hosting:** Cloudflare Pages (Unlimited free global bandwidth, edge CDN in Casablanca)

---

## Local Development

### Prerequisites
- Node.js 20+ & npm
- Flutter SDK 3.29+ (optional for local mobile testing)

### 1. Run the Marketing Landing Page
```bash
cd lcarnet-b2b-landing
npm install
npm run dev
```
Open [http://localhost:3000](http://localhost:3000).

### 2. Run the Flutter App Locally
```bash
cd app
flutter pub get
flutter run -d chrome
```

### 3. Unified Local Build
To compile the complete application locally:
```bash
cd lcarnet-b2b-landing
npm install
npm run build
```
This builds and verifies the complete Next.js marketing landing and interactive prototype.

---

## Deployment to Cloudflare Pages (100% Free)

The project includes an automated GitHub Actions workflow to build and publish both layers to Cloudflare Pages in a single step.

1. **Create Cloudflare Pages Project:**
   - In Cloudflare Dashboard → **Workers & Pages** → **Create application** → **Pages** → **Direct Upload**.
   - Project name: `lcarnet-b2b`.
2. **Add GitHub Secrets:**
   - Go to your GitHub repository: **Settings** → **Secrets and variables** → **Actions**.
   - Add `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN`.
3. **Deploy via GitHub Actions:**
   - Add [`.github/workflows/deploy-cloudflare.yml`](deploy/workflows/deploy-cloudflare.yml) to your repository.
   - Every push to `main` automatically compiles Flutter Web, bundles it into Next.js, and deploys the unified site to `https://lcarnet-b2b.pages.dev`.

---

## Project Documentation Index

- **[README_INVESTORS.md](README_INVESTORS.md)** — Executive investment memo (Unit economics, market size, monetization).
- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** — Comprehensive breakdown of completed features, mock data, and architecture.
- **[DESIGN_CONTEXT.md](DESIGN_CONTEXT.md)** — UX constraints, color tokens, and Derb Ghallef physical trading context.
- **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** — Complete product specs, database trigger logic, and bilingual glossary.

---

*L'Carnet B2B — Conçu pour le commerce de terrain au Maroc.*
