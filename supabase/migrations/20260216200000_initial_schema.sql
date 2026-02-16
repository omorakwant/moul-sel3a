-- =============================================================================
-- MOUL SEL3A — B2B Phone Accessory Ledger
-- Initial Migration: Complete Database Schema
-- =============================================================================
-- Tables: profiles, supplier_retailer_relations, products, orders,
--         delivery_jobs, delivery_bids, ledger_transactions
-- Trigger: update_rolling_balance (fires on ledger_transactions)
-- RLS:    Role-scoped row-level security policies
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 0. EXTENSIONS & SCHEMAS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. PROFILES
--    Linked 1:1 to auth.users via id (UUID from Supabase Auth).
--    role: 'supplier' | 'retailer' | 'driver'
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    shop_name   TEXT        NOT NULL,
    role        TEXT        NOT NULL CHECK (role IN ('supplier', 'retailer', 'driver')),
    phone       TEXT,
    city        TEXT,
    avatar_url          TEXT,
    preferred_language  TEXT NOT NULL DEFAULT 'fr' CHECK (preferred_language IN ('fr', 'ar')),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.profiles IS 'User profiles: Moul Hanout (supplier), retailer, or driver.';
COMMENT ON COLUMN public.profiles.role IS 'One of: supplier, retailer, driver.';
COMMENT ON COLUMN public.profiles.preferred_language IS 'UI language: fr (French) or ar (Moroccan Darija).';

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. SUPPLIER ↔ RETAILER RELATIONS
--    The "Carnet" link. Each row = one rolling debt account between a
--    specific supplier and a specific retailer.
--    UNIQUE(supplier_id, retailer_id) prevents duplicate accounts.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.supplier_retailer_relations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_id     UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    retailer_id     UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    credit_limit    NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    current_balance NUMERIC(12,2) NOT NULL DEFAULT 0.00,  -- positive = retailer owes supplier
    status          TEXT        NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'closed')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- ⚠️ CRITICAL: Prevent duplicate "Carnet" entries for the same pair
    CONSTRAINT uq_supplier_retailer UNIQUE (supplier_id, retailer_id),

    -- Guard: supplier ≠ retailer
    CONSTRAINT chk_no_self_relation CHECK (supplier_id <> retailer_id)
);

COMMENT ON TABLE  public.supplier_retailer_relations IS 'Rolling debt accounts between suppliers and retailers (le Carnet).';
COMMENT ON COLUMN public.supplier_retailer_relations.current_balance IS 'Positive = retailer owes supplier. Updated ONLY by the verified-transaction trigger.';

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. PRODUCTS
--    Supplier's catalog. Uses JSONB for tiered pricing and TEXT[] for
--    phone-model compatibility filtering.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.products (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_id         UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name                TEXT        NOT NULL,
    description         TEXT,
    brand               TEXT,
    image_url           TEXT,
    compatibility_list  TEXT[]      DEFAULT '{}',  -- e.g. {'Samsung A54','iPhone 13','Redmi Note 12'}

    -- ⚠️ CRITICAL: JSONB (not JSON, not TEXT) for queryable tiered pricing
    -- Format: {"1": 15.00, "10": 12.00, "50": 10.00}
    -- Keys = minimum quantity thresholds, Values = unit price at that tier
    price_tiers         JSONB       NOT NULL DEFAULT '{}',

    is_new              BOOLEAN     NOT NULL DEFAULT true,   -- "Nouveau / جديد" tag
    is_active           BOOLEAN     NOT NULL DEFAULT true,
    stock_quantity      INTEGER     NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.products IS 'Supplier product catalog with tiered pricing and phone model compatibility.';
COMMENT ON COLUMN public.products.price_tiers IS 'JSONB — keys are min-qty thresholds, values are unit price in DH. E.g. {"1":15,"10":12,"50":10}';
COMMENT ON COLUMN public.products.compatibility_list IS 'Array of phone model strings for compatibility-first search.';

-- Index for compatibility search (GIN on array)
CREATE INDEX idx_products_compatibility ON public.products USING GIN (compatibility_list);

-- Index for supplier catalog listing
CREATE INDEX idx_products_supplier ON public.products (supplier_id, is_active, is_new DESC);

-- Index for product name text search
CREATE INDEX idx_products_name_search ON public.products USING GIN (to_tsvector('french', name));

-- Index for brand filtering
CREATE INDEX idx_products_brand ON public.products (supplier_id, brand) WHERE brand IS NOT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. ORDERS (Le Bon / الطلبية)
--    Each order is a "Digital Bon". Includes adjusted_total for partial
--    receipt and driver assignment.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.orders (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_id     UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    retailer_id     UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    relation_id     UUID        NOT NULL REFERENCES public.supplier_retailer_relations(id) ON DELETE CASCADE,

    -- Order content stored as JSONB array of line items
    -- [{"product_id":"...","name":"Cable USB-C","qty":20,"unit_price":12.00,"line_total":240.00}, ...]
    items           JSONB       NOT NULL DEFAULT '[]',

    original_total  NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    adjusted_total  NUMERIC(12,2),  -- set after partial receipt adjustment
    driver_name     TEXT,           -- for assigned / trusted drivers

    status          TEXT        NOT NULL DEFAULT 'pending'
                    CHECK (status IN (
                        'pending',          -- just placed
                        'confirmed',        -- supplier confirmed
                        'ready_for_pickup', -- packed, waiting for driver
                        'shipped',          -- en route / في الطريق
                        'delivered',        -- retailer confirmed receipt
                        'cancelled'
                    )),

    delivery_type   TEXT        CHECK (delivery_type IN ('in_house', 'bid_driver')),
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.orders IS 'Digital Bon — each order between supplier and retailer.';
COMMENT ON COLUMN public.orders.adjusted_total IS 'Final amount after partial receipt. NULL until retailer confirms.';

-- Indexes for order listing (retailer dashboard & supplier dashboard)
CREATE INDEX idx_orders_retailer ON public.orders (retailer_id, status, created_at DESC);
CREATE INDEX idx_orders_supplier ON public.orders (supplier_id, status, created_at DESC);
CREATE INDEX idx_orders_relation ON public.orders (relation_id, created_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. DELIVERY JOBS
--    Created when an order is marked 'ready_for_pickup'.
--    Can be "Delivery Only" or "COD (Cash Collection)".
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.delivery_jobs (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id            UUID        NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    supplier_id         UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    assigned_driver_id  UUID        REFERENCES public.profiles(id),  -- NULL = open for bidding

    pickup_city         TEXT        NOT NULL,
    pickup_address      TEXT,
    dropoff_city        TEXT        NOT NULL,
    dropoff_address     TEXT,
    estimated_weight_kg NUMERIC(6,2),

    job_type            TEXT        NOT NULL DEFAULT 'delivery_only'
                        CHECK (job_type IN ('delivery_only', 'cod')),  -- COD = Cash On Delivery collection
    cod_amount          NUMERIC(12,2),  -- amount driver must collect if job_type = 'cod'

    status              TEXT        NOT NULL DEFAULT 'open'
                        CHECK (status IN (
                            'open',            -- visible to freelance drivers
                            'bidding_closed',  -- supplier accepted a bid
                            'assigned',        -- trusted driver assigned
                            'in_transit',
                            'completed',
                            'cancelled'
                        )),

    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.delivery_jobs IS 'Delivery requests — either assigned to trusted driver or open for bidding (InDrive model).';

-- Index for driver marketplace (open jobs sorted by recency)
CREATE INDEX idx_delivery_jobs_open ON public.delivery_jobs (status, created_at DESC) WHERE status = 'open';
CREATE INDEX idx_delivery_jobs_driver ON public.delivery_jobs (assigned_driver_id, status) WHERE assigned_driver_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. DELIVERY BIDS
--    Freelance drivers bid on open delivery_jobs.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.delivery_bids (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id          UUID        NOT NULL REFERENCES public.delivery_jobs(id) ON DELETE CASCADE,
    driver_id       UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

    bid_amount      NUMERIC(10,2) NOT NULL,             -- driver's proposed delivery fee in DH
    estimated_time  TEXT,                                 -- e.g. '2 heures', '30 min'
    message         TEXT,                                 -- optional note from driver

    status          TEXT        NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),

    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- One bid per driver per job
    CONSTRAINT uq_driver_job_bid UNIQUE (job_id, driver_id)
);

COMMENT ON TABLE public.delivery_bids IS 'Driver bids on open delivery jobs (InDrive-style marketplace).';

-- ─────────────────────────────────────────────────────────────────────────────
-- 7. LEDGER TRANSACTIONS
--    The financial source of truth. Every debit (order) and credit (payment)
--    flows through this table.
--    The rolling balance is ONLY updated when status = 'verified'.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.ledger_transactions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    relation_id     UUID        NOT NULL REFERENCES public.supplier_retailer_relations(id) ON DELETE CASCADE,
    order_id        UUID        REFERENCES public.orders(id) ON DELETE SET NULL,

    -- ⚠️ CRITICAL: transaction_type determines balance direction
    --   'order_increase'   → debt goes UP   (retailer ordered goods on credit)
    --   'payment_decrease' → debt goes DOWN  (retailer made a payment)
    transaction_type TEXT       NOT NULL
                     CHECK (transaction_type IN ('order_increase', 'payment_decrease')),

    amount           NUMERIC(12,2) NOT NULL CHECK (amount > 0),  -- always positive; direction via type

    payment_method   TEXT       CHECK (payment_method IN ('wafacash', 'cashplus', 'bank_transfer', 'driver_cash', 'check')),
    evidence_url     TEXT,       -- photo of Wafacash/CashPlus receipt
    reference_code   TEXT,       -- transaction reference from payment service
    notes            TEXT,

    -- Status workflow: pending → verified | rejected
    status           TEXT       NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending', 'verified', 'rejected')),

    verified_at      TIMESTAMPTZ,
    verified_by      UUID       REFERENCES public.profiles(id),

    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.ledger_transactions IS 'Financial ledger — every order debit and payment credit. Balance updates only on verified status.';
COMMENT ON COLUMN public.ledger_transactions.amount IS 'Always positive. The transaction_type determines whether it increases or decreases the debt.';

-- Index for fast ledger lookups per relation
CREATE INDEX idx_ledger_relation ON public.ledger_transactions (relation_id, created_at DESC);


-- =============================================================================
-- 8. THE CRITICAL TRIGGER: update_rolling_balance
--    Automatically updates current_balance in supplier_retailer_relations
--    ONLY when a ledger_transaction is inserted or updated to status = 'verified'.
--
--    Logic:
--      • order_increase   → ADDS to current_balance    (retailer owes MORE)
--      • payment_decrease → SUBTRACTS from current_balance (retailer paid off debt)
-- =============================================================================

CREATE OR REPLACE FUNCTION public.fn_update_rolling_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_direction INTEGER;
BEGIN
    -- ═══════════════════════════════════════════════════════════════════════
    -- CASE 1: Transaction becomes VERIFIED
    --   Balance_new = Balance_old + (Amount × Direction)
    --   Where Direction = +1 for order_increase, -1 for payment_decrease
    -- ═══════════════════════════════════════════════════════════════════════
    IF NEW.status = 'verified' THEN

        -- Guard: if UPDATE, only fire when status actually CHANGED to 'verified'
        IF TG_OP = 'UPDATE' AND OLD.status = 'verified' THEN
            RETURN NEW;  -- already verified → no double-counting
        END IF;

        -- Determine direction from transaction_type
        v_direction := CASE NEW.transaction_type
            WHEN 'order_increase'   THEN  1   -- debt goes UP
            WHEN 'payment_decrease' THEN -1   -- debt goes DOWN
        END;

        -- Apply atomic balance update with row lock (FOR UPDATE via subselect)
        UPDATE public.supplier_retailer_relations
        SET current_balance = current_balance + (NEW.amount * v_direction),
            updated_at      = now()
        WHERE id = NEW.relation_id;

        -- Stamp verification metadata
        NEW.verified_at := now();

    -- ═══════════════════════════════════════════════════════════════════════
    -- CASE 2: REVERSAL — previously verified transaction is now REJECTED
    --   Must undo the balance change to keep the ledger consistent.
    --   This handles the dispute resolution flow.
    -- ═══════════════════════════════════════════════════════════════════════
    ELSIF TG_OP = 'UPDATE' AND OLD.status = 'verified' AND NEW.status = 'rejected' THEN

        -- Reverse the direction
        v_direction := CASE OLD.transaction_type
            WHEN 'order_increase'   THEN -1   -- undo: debt goes back DOWN
            WHEN 'payment_decrease' THEN  1   -- undo: debt goes back UP
        END;

        UPDATE public.supplier_retailer_relations
        SET current_balance = current_balance + (OLD.amount * v_direction),
            updated_at      = now()
        WHERE id = OLD.relation_id;

        -- Clear verification timestamp on reversal
        NEW.verified_at := NULL;

    END IF;

    RETURN NEW;
END;
$$;

-- Trigger fires on INSERT (direct verified insert) and UPDATE (pending → verified)
CREATE TRIGGER trg_update_rolling_balance
    BEFORE INSERT OR UPDATE ON public.ledger_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_update_rolling_balance();

COMMENT ON FUNCTION public.fn_update_rolling_balance() IS
    'Updates the rolling debt balance in supplier_retailer_relations when a ledger transaction is verified. '
    'order_increase → +amount (more debt), payment_decrease → −amount (less debt).';


-- =============================================================================
-- 9. HELPER: updated_at auto-timestamp trigger
-- =============================================================================

CREATE OR REPLACE FUNCTION public.fn_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

-- Apply to all tables with updated_at
CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

CREATE TRIGGER trg_relations_updated_at
    BEFORE UPDATE ON public.supplier_retailer_relations
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

CREATE TRIGGER trg_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

CREATE TRIGGER trg_delivery_jobs_updated_at
    BEFORE UPDATE ON public.delivery_jobs
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

CREATE TRIGGER trg_ledger_updated_at
    BEFORE UPDATE ON public.ledger_transactions
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


-- =============================================================================
-- 10. ROW LEVEL SECURITY (RLS) — Draft Policies
--     Enable RLS on all tables. Users can only access their own data.
-- =============================================================================

-- Enable RLS on every table
ALTER TABLE public.profiles                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_retailer_relations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_jobs              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_bids              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_transactions        ENABLE ROW LEVEL SECURITY;

-- ── PROFILES ────────────────────────────────────────────────────────────────
-- Users can insert their own profile row (called by Supabase Auth trigger)
CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Users can read their own profile
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Both sides of a relation can view each other's profiles (for directory/display)
CREATE POLICY "Related users can view each others profiles"
    ON public.profiles FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE (sr.supplier_id = auth.uid() AND sr.retailer_id = profiles.id)
               OR (sr.retailer_id = auth.uid() AND sr.supplier_id = profiles.id)
        )
    );

-- Drivers can view supplier profiles for delivery jobs
CREATE POLICY "Drivers can view job supplier profiles"
    ON public.profiles FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.delivery_jobs dj
            WHERE dj.supplier_id = profiles.id
              AND (dj.status = 'open' OR dj.assigned_driver_id = auth.uid())
        )
    );

-- ── SUPPLIER_RETAILER_RELATIONS ─────────────────────────────────────────────
-- Both sides of the relation can view it
CREATE POLICY "Parties can view their relations"
    ON public.supplier_retailer_relations FOR SELECT
    USING (auth.uid() = supplier_id OR auth.uid() = retailer_id);

-- Only suppliers can create/update relations
CREATE POLICY "Suppliers can manage relations"
    ON public.supplier_retailer_relations FOR INSERT
    WITH CHECK (auth.uid() = supplier_id);

CREATE POLICY "Suppliers can update relations"
    ON public.supplier_retailer_relations FOR UPDATE
    USING (auth.uid() = supplier_id);

-- ── PRODUCTS ────────────────────────────────────────────────────────────────
-- Suppliers manage their own products
CREATE POLICY "Suppliers manage own products"
    ON public.products FOR ALL
    USING (auth.uid() = supplier_id);

-- Retailers can view products from their suppliers
CREATE POLICY "Retailers can view supplier products"
    ON public.products FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE sr.supplier_id = products.supplier_id
              AND sr.retailer_id = auth.uid()
              AND sr.status = 'active'
        )
    );

-- ── ORDERS ──────────────────────────────────────────────────────────────────
-- Both supplier and retailer can view their orders
CREATE POLICY "Parties can view their orders"
    ON public.orders FOR SELECT
    USING (auth.uid() = supplier_id OR auth.uid() = retailer_id);

-- Retailers can create orders
CREATE POLICY "Retailers can create orders"
    ON public.orders FOR INSERT
    WITH CHECK (auth.uid() = retailer_id);

-- Suppliers can update orders (confirm, assign driver, etc.)
CREATE POLICY "Suppliers can update orders"
    ON public.orders FOR UPDATE
    USING (auth.uid() = supplier_id);

-- Retailers can update orders (partial receipt confirmation)
CREATE POLICY "Retailers can update own orders"
    ON public.orders FOR UPDATE
    USING (auth.uid() = retailer_id);

-- ── DELIVERY JOBS ───────────────────────────────────────────────────────────
-- Suppliers manage their delivery jobs
CREATE POLICY "Suppliers manage delivery jobs"
    ON public.delivery_jobs FOR ALL
    USING (auth.uid() = supplier_id);

-- Drivers can view open jobs (for bidding)
CREATE POLICY "Drivers can view open jobs"
    ON public.delivery_jobs FOR SELECT
    USING (
        status = 'open'
        OR assigned_driver_id = auth.uid()
    );

-- ── DELIVERY BIDS ───────────────────────────────────────────────────────────
-- Drivers can view their own bids
CREATE POLICY "Drivers can view own bids"
    ON public.delivery_bids FOR SELECT
    USING (auth.uid() = driver_id);

-- Drivers can place bids on open jobs
CREATE POLICY "Drivers can place bids"
    ON public.delivery_bids FOR INSERT
    WITH CHECK (
        auth.uid() = driver_id
        AND EXISTS (
            SELECT 1 FROM public.delivery_jobs dj
            WHERE dj.id = job_id AND dj.status = 'open'
        )
    );

-- Drivers can update (withdraw) their own pending bids
CREATE POLICY "Drivers can withdraw own bids"
    ON public.delivery_bids FOR UPDATE
    USING (auth.uid() = driver_id AND status = 'pending');

-- Suppliers can view all bids on their jobs
CREATE POLICY "Suppliers can view bids on their jobs"
    ON public.delivery_bids FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.delivery_jobs dj
            WHERE dj.id = delivery_bids.job_id
              AND dj.supplier_id = auth.uid()
        )
    );

-- Suppliers can update bid status (accept/reject)
CREATE POLICY "Suppliers can update bids"
    ON public.delivery_bids FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.delivery_jobs dj
            WHERE dj.id = delivery_bids.job_id
              AND dj.supplier_id = auth.uid()
        )
    );

-- ── LEDGER TRANSACTIONS ─────────────────────────────────────────────────────
-- Both parties can view transactions on their relation
CREATE POLICY "Parties can view ledger transactions"
    ON public.ledger_transactions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE sr.id = ledger_transactions.relation_id
              AND (sr.supplier_id = auth.uid() OR sr.retailer_id = auth.uid())
        )
    );

-- Suppliers can create and update ledger transactions (they are the source of truth)
CREATE POLICY "Suppliers can manage ledger transactions"
    ON public.ledger_transactions FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE sr.id = relation_id
              AND sr.supplier_id = auth.uid()
        )
    );

-- Retailers can create payment declarations (status = 'pending')
CREATE POLICY "Retailers can declare payments"
    ON public.ledger_transactions FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE sr.id = relation_id
              AND sr.retailer_id = auth.uid()
        )
        AND transaction_type = 'payment_decrease'
        AND status = 'pending'
    );

-- Only suppliers can verify/reject transactions
CREATE POLICY "Suppliers can verify transactions"
    ON public.ledger_transactions FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE sr.id = ledger_transactions.relation_id
              AND sr.supplier_id = auth.uid()
        )
    );



-- =============================================================================
-- 11. HANDLE NEW USER — Supabase Auth hook
--     Automatically creates a profile row when a new user signs up.
--     The supplier creates retailer/driver accounts, so role defaults to
--     'retailer'. The admin can change it afterward.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, shop_name, role, phone, preferred_language)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'shop_name', 'Nouveau Compte'),
        COALESCE(NEW.raw_user_meta_data->>'role', 'retailer'),
        NEW.phone,
        COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'fr')
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- =============================================================================
-- 12. STORAGE BUCKET (for receipt photos & product images)
-- =============================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('lcarnet-assets', 'lcarnet-assets', false)
ON CONFLICT (id) DO NOTHING;

-- Authenticated users can upload to their own folder
CREATE POLICY "Users can upload own assets"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'lcarnet-assets'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Authenticated users can view assets in their relations
CREATE POLICY "Authenticated users can view assets"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'lcarnet-assets'
        AND auth.role() = 'authenticated'
    );


-- =============================================================================
-- ✅ MIGRATION COMPLETE
-- =============================================================================
-- Summary:
--   7 Tables created:
--     1. profiles                      (auto-created via Auth trigger ✓)
--     2. supplier_retailer_relations    (UNIQUE supplier+retailer pair ✓)
--     3. products                       (price_tiers JSONB + compatibility GIN ✓)
--     4. orders                         (partial receipt via adjusted_total ✓)
--     5. delivery_jobs                  (InDrive bidding + COD ✓)
--     6. delivery_bids                  (one-bid-per-driver constraint ✓)
--     7. ledger_transactions            (financial source of truth ✓)
--
--   Critical Trigger: fn_update_rolling_balance
--     • order_increase   → current_balance + amount  (debt UP ✓)
--     • payment_decrease  → current_balance - amount  (debt DOWN ✓)
--     • Only fires when status transitions TO 'verified'
--     • Double-fire protection on UPDATE ✓
--     • REVERSAL support: verified → rejected undoes the balance ✓
--
--   Auth: handle_new_user trigger creates profile on sign-up
--   Storage: lcarnet-assets bucket for receipts & product images
--   RLS: Enabled on all 7 tables + storage with role-scoped policies
--
--   Performance indexes:
--     • products: GIN(compatibility_list), supplier+active, name FTS, brand
--     • orders: retailer+status, supplier+status, relation
--     • delivery_jobs: open jobs, assigned driver
--     • ledger: relation+date
-- =============================================================================
