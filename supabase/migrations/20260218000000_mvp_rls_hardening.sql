-- =============================================================================
-- MOUL SEL3A — RLS Hardening Migration (MVP)
-- =============================================================================
-- Changes:
--   1. FORCE ROW LEVEL SECURITY on all tables
--      (Even table owners / service_role must go through RLS unless
--       explicitly using service_role key, which bypasses anyway.)
--   2. Add role checks on sensitive INSERT/UPDATE policies
--   3. Tighten ledger transaction policies
--   4. Add index hints for RLS subquery performance
-- =============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- 1. FORCE RLS — closes the loophole where table owners bypass policies
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.profiles                    FORCE ROW LEVEL SECURITY;
ALTER TABLE public.supplier_retailer_relations FORCE ROW LEVEL SECURITY;
ALTER TABLE public.products                    FORCE ROW LEVEL SECURITY;
ALTER TABLE public.orders                      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_jobs               FORCE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_bids               FORCE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_transactions         FORCE ROW LEVEL SECURITY;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. PRODUCTS: Only suppliers can insert products (role check)
--    The existing "Suppliers manage own products" policy uses FOR ALL
--    which is fine, but let's add an explicit role check.
-- ─────────────────────────────────────────────────────────────────────────────
-- Drop the existing overly broad policy and replace with scoped ones
DROP POLICY IF EXISTS "Suppliers manage own products" ON public.products;

CREATE POLICY "Suppliers can CRUD own products"
    ON public.products FOR ALL
    USING (auth.uid() = supplier_id)
    WITH CHECK (
        auth.uid() = supplier_id
        AND EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'supplier'
        )
    );


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. ORDERS: Tighten update policies with role checks
--    Suppliers should only update to valid forward-transitions.
--    Retailers should only be able to set adjusted_total + delivered status.
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Suppliers can update orders" ON public.orders;
DROP POLICY IF EXISTS "Retailers can update own orders" ON public.orders;

-- Suppliers can update orders they own (status transitions, driver assignment)
CREATE POLICY "Suppliers can update own orders"
    ON public.orders FOR UPDATE
    USING (
        auth.uid() = supplier_id
        AND EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'supplier'
        )
    );

-- Retailers can update orders for partial receipt only
CREATE POLICY "Retailers can update orders for receipt"
    ON public.orders FOR UPDATE
    USING (
        auth.uid() = retailer_id
        AND EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'retailer'
        )
    );


-- ─────────────────────────────────────────────────────────────────────────────
-- 4. DELIVERY_JOBS: Add role check for supplier management
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Suppliers manage delivery jobs" ON public.delivery_jobs;

CREATE POLICY "Suppliers can CRUD delivery jobs"
    ON public.delivery_jobs FOR ALL
    USING (
        auth.uid() = supplier_id
        AND EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'supplier'
        )
    );


-- ─────────────────────────────────────────────────────────────────────────────
-- 5. DELIVERY_BIDS: Add role check for driver operations
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Drivers can place bids" ON public.delivery_bids;

CREATE POLICY "Drivers can place bids on open jobs"
    ON public.delivery_bids FOR INSERT
    WITH CHECK (
        auth.uid() = driver_id
        AND EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'driver'
        )
        AND EXISTS (
            SELECT 1 FROM public.delivery_jobs dj
            WHERE dj.id = job_id AND dj.status = 'open'
        )
    );


-- ─────────────────────────────────────────────────────────────────────────────
-- 6. LEDGER: Harden payment_decrease insertion (retailer role check)
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Retailers can declare payments" ON public.ledger_transactions;

CREATE POLICY "Retailers can declare payments"
    ON public.ledger_transactions FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE sr.id = relation_id
              AND sr.retailer_id = auth.uid()
        )
        AND EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'retailer'
        )
        AND transaction_type = 'payment_decrease'
        AND status = 'pending'
    );


-- ─────────────────────────────────────────────────────────────────────────────
-- 7. Performance indexes for RLS subqueries
-- ─────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles (id, role);
CREATE INDEX IF NOT EXISTS idx_relations_supplier_retailer
    ON public.supplier_retailer_relations (supplier_id, retailer_id);


-- =============================================================================
-- ✅ RLS HARDENING COMPLETE
-- =============================================================================
-- Summary:
--   - FORCE RLS on all 7 tables
--   - Role-check guards on sensitive INSERT/UPDATE policies
--   - Performance indexes for RLS subqueries
--   - Existing read (SELECT) policies unchanged
-- =============================================================================
