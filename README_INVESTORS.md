# L'Carnet B2B — For Investors

> **One-page overview for investors.**  
> Digitizing the "Carnet" (rolling debt) and handshake delivery for Morocco's phone accessory wholesale market.

---

## 1. The Headline

**L'Carnet B2B (لكارني B2B)** is a B2B marketplace that digitizes the **rolling-debt ledger** and **trust-based delivery** used by Moroccan wholesalers and retailers (Derb Ghallef, Garage Allal style). We replace paper Carnets and handshake agreements with a single app for **Suppliers**, **Retailers**, and **Drivers**, in **French + Moroccan Darija**.

---

## 2. The Problem

- **Paper Carnets** — Wholesalers and retailers track debt in notebooks. No single source of truth; disputes and lost slips are common.
- **Informal delivery** — Trusted drivers (Kourtia) deliver on handshakes and WhatsApp. No digital proof of delivery or PIN-based confirmation.
- **Fragmented payments** — Partial payments (Wafacash, CashPlus, cash) are declared by the retailer and manually verified by the supplier; no streamlined flow.
- **Offline-first reality** — Connectivity in souks and warehouses is unreliable; critical actions (confirm receipt, declare payment) must work offline and sync when back online.

**Result:** Inefficiency, disputes, and limited scalability for a large informal B2B segment.

---

## 3. The Solution

- **Digital Ledger (Carnet)** — One balance per supplier–retailer relationship; updated only when orders are confirmed and payments are verified.
- **Handshake delivery** — 4-digit PIN at delivery; driver and retailer confirm in-app. Optional COD (cash collection) tracked in the ledger.
- **Partial receipt** — Retailers adjust received quantities at delivery (e.g. damaged items) before the final "Confirm receipt" updates their debt.
- **Bilingual, offline-capable app** — French for structure, Darija for actions; critical writes queued when offline and synced when connected.

---

## 4. Product & Live Demo

**Live prototype (no login):**  
**https://lcarnetb2b.vercel.app**

| Role | What to show |
|------|----------------|
| **Retailer** | Dashboard (balance, suppliers) → Catalog (tiered pricing, compatibility filter, voice search) → Cart → Orders → Order detail → Partial receipt → Payment declaration (photo + amount + reference, then "Notifier le grossiste" WhatsApp) → Handshake (PIN). |
| **Supplier** | Dashboard → Inventaire (products, bulk price adjustment) → Clients (Carnet) → Add retailer → Vérifications (pending payments, approve/reject) → Commandes → Livraisons → Bid manager (accept driver bid, PIN generated). |
| **Driver** | Marketplace (open jobs) → Place bid → Active trip → "Contacter le détaillant · WhatsApp" → "Je suis arrivé" → Enter 4-digit PIN → Delivery confirmed. |

**Demo tips:** Use the **role switcher** (Retailer | Supplier | Driver) in the app bar to switch flows. Triple-tap the app title to show the **offline** banner. All data is mock; the UI is production-ready for a backend plug-in.

---

## 5. Market Opportunity

- **Segment:** Moroccan phone accessory wholesale (wholesalers, retailers, independent drivers).
- **Geography:** Casablanca (Derb Omar, Derb Ghallef), Rabat, Fès, Marrakech, and similar hubs.
- **Behaviours:** Rolling debt (Carnet), tiered pricing, compatibility-based search (phone model), Wafacash/CashPlus/cash payments, WhatsApp-first communication.
- **Entry:** Supplier-led onboarding; retailers invited by suppliers; drivers discover open jobs and bid (InDrive-style).

*TAM/SAM/SOM to be refined with local market sizing.*

---

## 6. What’s Built (Traction / Prototype)

| Area | Status |
|------|--------|
| **Full UI for 3 roles** | Retailer (mobile-style), Supplier (web/tablet sidebar), Driver (mobile). |
| **Core flows** | Dashboard, catalog, cart, orders, partial receipt, payment declaration, handshake (PIN), verification desk, bid manager, deliveries, clients (Carnet), add retailer. |
| **Bilingual** | French + Darija (Arabic script) across the app. |
| **Offline-ready** | SyncService queues confirm receipt, declare payment, verify delivery; retry and dead-letter. (Web demo uses simulated offline.) |
| **Tech** | Flutter, Riverpod, GoRouter, Supabase client (backend not used on web demo). |

**Scope:** Frontend-only prototype with **mock data** for investor demos. No production backend or real payments.

---

## 7. Roadmap — What’s Next

| Priority | Item |
|----------|------|
| **1. Backend & go-live** | Deploy production Supabase; migrations and ledger trigger already in repo. |
| **2. Notifications** | In-app “new payment declared” banner done; optional FCM push to supplier. |
| **3. Done** | Receipt OCR (ML Kit on mobile), offline read cache, E2E smoke test, env config, semantics. |

---

## 8. The Ask

*To be completed with: funding amount, use of funds (e.g. backend, ops, first market), and target milestones.*

---

## 9. Team & Contact

*To be completed with: founder/team names, roles, and contact (email / Calendly).*

---

## 10. Documentation (Technical)

| Document | Purpose |
|----------|---------|
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | Full feature list: done vs not done (single source of truth). |
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Vision, roles, specs, offline strategy, DB hints. |
| [README.md](README.md) | General project README (setup, deploy, architecture). |

---

*This document is for investor conversations. For implementation details, see [PROJECT_STATUS.md](PROJECT_STATUS.md).*
