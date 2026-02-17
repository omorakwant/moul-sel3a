L'Carnet B2B: Progress Tracker
✅ Phase 0: Planning & Architecture (Completed)

    Business Logic Defined: Rolling debt calculation, Tiered pricing JSONB structure, and PIN-code handshake.

    Design Specs: Master UI/UX prompt created with fixed mobile viewport constraints (390x844).

    Localization Map: l10n_map.json created with French and Moroccan Darija keys.

    Tech Stack Confirmed: Flutter, Supabase (PostgreSQL), WhatsApp Deep-linking.

    Master Spec: PROJECT_CONTEXT.md finalized with database schema and RLS rules.

🏗️ Phase 1: Foundation (Current Goal)

    [ ] Database Migration: Generate SQL for tables (Profiles, Products, Orders, Ledger).

    [ ] Trigger Logic: Implement the PostgreSQL function to auto-update current_balance.

    [ ] Authentication: Build Phone Auth and Role Selection (Supplier/Retailer/Driver).

    [ ] Profile Setup: Implement static location fields (Location Name/City).

📦 Phase 2: Supplier Features (Next)

    [ ] Product Factory (Add/Edit with Price Tiers).

    [ ] Bulk Price Adjustment Logic (+/- DH or %).

    [ ] Verification Desk (Payment Proof Review).

🛒 Phase 3: Retailer & Driver Flow (Upcoming)

    [ ] Catalog with Dynamic Pricing.

    [ ] Checkout & WhatsApp Summary.

    [ ] Driver Job Board & PIN Verification.

    [ ] Payment Declaration (Receipt Upload).