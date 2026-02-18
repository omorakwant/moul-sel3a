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

5. UI/UX Guidelines

A. Mobile First (Retailer & Driver)

    Viewport: Optimized for 390x844 (iPhone 15 standard).

    Navigation: Bottom Bar (Home, Cart, Profile) for Retailers.

    Input: Number pads must be large. Avoid complex text inputs where possible.

    Colors:

        Primary: Indigo (#4F46E5)

        Success: Emerald (#10B981)

        Debt/Danger: Rose Red (#E11D48)

        Warning: Amber (#F59E0B)

B. Web Dashboard (Supplier Admin — 1440×900 viewport)

    Layout Pattern: All supplier web screens use a shared sidebar + main content area:

    Sidebar (260px, fixed left):
        Background: #1C1917 (web-sidebar-bg)
        Brand section: م logo (orange circle) + "Moul Sel3a" + "Grossiste"
        Navigation items: Dashboard, Inventaire, Clients (Carnet), Vérifications, Logistique
        Active state: #292524 bg, orange icon (#C2410C), white text
        Inactive state: #D6D3D1 text, transparent bg
        Vérifications badge: orange pill with pending count
        Bottom: User avatar (initials), name, role, settings icon

    TopBar (64px, full width of main area):
        Background: #FFFFFF, bottom border #E7E5E4
        Left: Screen title (Manrope 20pt 800) + count badge
        Right: Context-specific actions (search, filters, navigation)

    Screen F — Command Center (Inventory Table):
        Filter tabs row: Tout (active), Écrans, Accessoires, Chargeurs, Câbles, Protection
        Table header: #F5F5F4, 40px height, column widths: checkbox(40), product(260), brand(120), stock(80), price T1(110), price T2(110), status(fill)
        Data rows: 52px, white bg, hover state, selected state: #EEF2FF bg + indigo checkbox
        Low stock: red stock count + amber "Stock faible" badge
        Floating bulk action bar: indigo #1E1B4B, 500×52, positioned bottom-center of content area

    Screen F.1 — Bulk Update Modal:
        Overlay: rgba(0,0,0,0.5)
        Modal card: 560px, cornerRadius 16, white bg
        Radio selection for adjustment mode (Fixed/Percentage)
        Preview table showing ALL selected items with old→new prices (new in green)

    Screen G — Verification Desk (Split View):
        Queue navigation in TopBar: Précédent/Suivant + counter ("3/8")
        Left pane (fill_container): light gray bg (#F5F5F4), receipt header + zoom controls, centered receipt card (white, shadow, 320×580)
        Right pane (480px fixed): white bg, scrollable. Sections: client card, declared amount (32pt), reference match (green checkmark), balance impact card (#F0FDF4), action buttons (green Valider + red Rejeter)

    Typography:
        Headings: Manrope (700-800 weight)
        Body/Labels: Inter (400-600 weight)
        Numbers/Prices: Manrope (800 weight)

    Corner Radius: 8px for cards/inputs, 12px for larger panels, 16px for modals

6. Localization (L10n)

All UI elements must use the l10n_map.json keys.

    Structure: key: { "fr": "French Text", "ar_MA": "Darija Text" }

    Numbers: Always use Western Arabic numerals (0-9) and "DH" for currency.

7. Developer Milestones (For Copilot)

    Phase 1: DB & Auth ✅: Supabase tables, RLS policies, Phone Auth, Triggers.

    Phase 2: Supplier Features ✅: Inventory management, Tiered Pricing, Bulk Edit, Dashboard, Delivery.

    Phase 3: Retailer Mobile ✅: Catalog, Cart with dynamic pricing, Order Handshake, Payment Declaration.

    Phase 4: Logistics ✅: Driver bidding system, PIN verification, Active Trip tracking.

    Phase 5: UI/UX Design ✅: Mobile screens (A-E at 390×844) + Web dashboard screens (F, F.1, G at 1440×900).

    Phase 6: Web Dashboard Implementation 🏗️:
        - Implement SupplierWebShell with responsive sidebar navigation.
        - Migrate SupplierInventoryScreen to data table layout (Screen F).
        - Migrate SupplierVerificationScreen to split-view layout (Screen G).
        - Update BulkPriceAdjustmentModal to dialog with radio mode + full preview (Screen F.1).
        - Add responsive breakpoints: >1024px = web sidebar layout, ≤1024px = mobile layout.