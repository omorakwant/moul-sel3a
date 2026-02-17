PROJECT CONTEXT: L'Carnet B2B (Morocco)
1. Project Overview

L'Carnet B2B is a mobile-first application designed for the Moroccan electronics wholesale market ("Derb Ghallef" model). It replaces the traditional paper notebook ("Carnet") used to track debts between Wholesalers (Grossistes) and Retailers (Détaillants).

    Primary Goal: Digitize the "Rolling Debt" (Crédit Fournisseur) and streamline ordering/delivery.

    Target Audience: Non-tech-savvy shopkeepers and drivers.

    Key Constraint: High-contrast UI for sunlight readability, big buttons for "fat fingers," and Offline-First architecture where possible.

    Languages: French (Official/Admin) + Moroccan Darija (Action Labels).

2. Core Business Logic
A. The "Rolling Debt" (Le Carnet)

The central feature is the current_balance between a Supplier and a Retailer.

    Logic: Balance = Total Orders - Total Payments.

    Positive Balance: Retailer owes money (Debt).

    Negative Balance: Supplier owes money (Credit/Overpayment).

    Trigger: A PostgreSQL Trigger must automatically update current_balance in the supplier_retailer_relations table whenever a ledger_transaction is inserted or updated with status verified.

B. Tiered Pricing (Prix par Quantité)

Products have dynamic pricing based on quantity logic stored in a JSONB column.

    Data Structure: price_tiers = [{"min": 1, "max": 10, "price": 100}, {"min": 11, "max": 50, "price": 90}]

    Logic:

        If qty is 5, Unit Price = 100 DH.

        If qty is 20, Unit Price = 90 DH.

    Bulk Update: Suppliers can apply a +X DH or +Y% adjustment to all products in a brand (e.g., "Samsung Screens") via the Web Dashboard.

C. The "Handshake" Delivery

We do not use GPS for verification. We use a PIN Code system.

    Driver accepts a bid -> Receives a 4-digit PIN.

    Driver arrives at Retailer -> Shows PIN.

    Retailer enters PIN in their app -> Verifies "Physical Presence."

    Action: Status changes to delivered.

D. Payment Verification (Wafacash/CashPlus)

Retailers declare payments by uploading a photo of the receipt.

    Status Flow: pending (Uploaded) -> verified (Supplier confirms on Web) -> rejected (Bad photo/Fake).

    Ledger Impact: Only verified payments reduce the debt.

3. Tech Stack & Architecture

    Frontend: Flutter (Mobile + Web).

    Backend: Supabase (PostgreSQL, Auth, Storage, Edge Functions).

    State Management: Riverpod or Bloc (Clean Architecture).

    Maps: None. Text-based location fields (e.g., "Derb Omar, Rue 6, N° 12").

    Communications: Deep-linking to WhatsApp for order summaries.

4. Database Schema (Supabase/PostgreSQL)
profiles

    id (UUID, PK)

    role (enum: 'supplier', 'retailer', 'driver')

    business_name (Text)

    phone (Text, Unique)

    location_name (Text, e.g., "Hanout Alami")

    city (Text)

products

    id (UUID, PK)

    supplier_id (FK -> profiles.id)

    name (Text)

    brand (Text)

    category (Text)

    base_price (Numeric)

    price_tiers (JSONB)

    stock_quantity (Integer)

    is_active (Boolean)

supplier_retailer_relations

    id (UUID, PK)

    supplier_id (FK)

    retailer_id (FK)

    current_balance (Numeric, Default: 0)

    credit_limit (Numeric, Default: 5000)

    is_blocked (Boolean)

orders

    id (UUID, PK)

    retailer_id (FK)

    supplier_id (FK)

    driver_id (FK, Nullable)

    status (enum: 'pending', 'accepted', 'transit', 'delivered', 'canceled')

    total_amount (Numeric)

    items (JSONB Snapshot of price/qty at time of order)

    delivery_pin (Text, 4-digits)

ledger_transactions

    id (UUID, PK)

    relation_id (FK -> supplier_retailer_relations)

    type (enum: 'order', 'payment', 'return')

    amount (Numeric)

    proof_image_url (Text, Nullable)

    status (enum: 'pending', 'verified', 'rejected')

    created_at (Timestamp)

5. UI/UX Guidelines (Mobile First)

    Viewport: Optimized for 390x844 (iPhone 15 standard).

    Navigation: Bottom Bar (Home, Cart, Profile) for Retailers.

    Input: Number pads must be large. Avoid complex text inputs where possible.

    Colors:

        Primary: Indigo (#4F46E5)

        Success: Emerald (#10B981)

        Debt/Danger: Rose Red (#E11D48)

        Warning: Amber (#F59E0B)

6. Localization (L10n)

All UI elements must use the l10n_map.json keys.

    Structure: key: { "fr": "French Text", "ar_MA": "Darija Text" }

    Numbers: Always use Western Arabic numerals (0-9) and "DH" for currency.

7. Developer Milestones (For Copilot)

    Phase 1: DB & Auth: Set up Supabase tables, RLS policies, and Phone Auth.

    Phase 2: Supplier Web: Inventory management, Tiered Pricing logic, Bulk Edit.

    Phase 3: Retailer Mobile: Catalog, Cart with dynamic pricing, Order Handshake.

    Phase 4: Logistics: Driver bidding system, PIN verification.

    Phase 5: Payments: Wafacash receipt upload and "Ledger Verification" desk.