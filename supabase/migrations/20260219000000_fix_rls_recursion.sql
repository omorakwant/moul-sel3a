-- =============================================================================
-- FIX: Infinite recursion in RLS policies on profiles table
-- =============================================================================
-- Problem: profiles policies reference delivery_jobs, and delivery_jobs
--   policies (from hardening migration) reference profiles.
--   This creates: profiles → delivery_jobs → profiles → ...
--   causing "infinite recursion detected in policy for relation profiles"
--
-- Solution:
--   1. Drop the "Drivers can view job supplier profiles" policy that
--      references delivery_jobs, and replace it with a simpler approach
--      using a SECURITY DEFINER function.
--   2. Also fix products policies that reference profiles (same pattern).
-- =============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Create SECURITY DEFINER helper functions
--    These bypass RLS, breaking the recursion cycle.
-- ─────────────────────────────────────────────────────────────────────────────

-- Helper: Get the role for a given user id (bypasses RLS on profiles)
CREATE OR REPLACE FUNCTION public.get_user_role(user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT role FROM public.profiles WHERE id = user_id LIMIT 1;
$$;

-- Helper: Check if a user has a specific role (bypasses RLS on profiles)
CREATE OR REPLACE FUNCTION public.user_has_role(user_id uuid, required_role text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = user_id AND role = required_role
  );
$$;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Fix profiles policies — remove cross-table references that recurse
-- ─────────────────────────────────────────────────────────────────────────────

-- Drop the problematic policy that causes profiles → delivery_jobs → profiles
DROP POLICY IF EXISTS "Drivers can view job supplier profiles" ON public.profiles;

-- Replace with a version that does NOT trigger delivery_jobs RLS.
-- Since delivery_jobs.supplier_id is just a UUID column, we can query
-- it directly if we bypass RLS via a security definer function.
CREATE OR REPLACE FUNCTION public.can_view_supplier_profile(profile_id uuid, viewer_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.delivery_jobs dj
    WHERE dj.supplier_id = profile_id
      AND (dj.status = 'open' OR dj.assigned_driver_id = viewer_id)
  );
$$;

CREATE POLICY "Drivers can view job supplier profiles"
    ON public.profiles FOR SELECT
    USING (
        public.can_view_supplier_profile(profiles.id, auth.uid())
    );


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Fix hardened policies that reference profiles — use helper functions
-- ─────────────────────────────────────────────────────────────────────────────

-- Products: "Suppliers can CRUD own products" references profiles
DROP POLICY IF EXISTS "Suppliers can CRUD own products" ON public.products;
CREATE POLICY "Suppliers can CRUD own products"
    ON public.products FOR ALL
    USING (auth.uid() = supplier_id)
    WITH CHECK (
        auth.uid() = supplier_id
        AND public.user_has_role(auth.uid(), 'supplier')
    );

-- Delivery jobs: "Suppliers can CRUD delivery jobs" references profiles
DROP POLICY IF EXISTS "Suppliers can CRUD delivery jobs" ON public.delivery_jobs;
CREATE POLICY "Suppliers can CRUD delivery jobs"
    ON public.delivery_jobs FOR ALL
    USING (
        auth.uid() = supplier_id
        AND public.user_has_role(auth.uid(), 'supplier')
    );

-- Delivery bids: "Drivers can place bids on open jobs" references profiles
DROP POLICY IF EXISTS "Drivers can place bids on open jobs" ON public.delivery_bids;
CREATE POLICY "Drivers can place bids on open jobs"
    ON public.delivery_bids FOR INSERT
    WITH CHECK (
        auth.uid() = driver_id
        AND public.user_has_role(auth.uid(), 'driver')
        AND EXISTS (
            SELECT 1 FROM public.delivery_jobs dj
            WHERE dj.id = job_id AND dj.status = 'open'
        )
    );

-- Orders: Suppliers update policy references profiles
DROP POLICY IF EXISTS "Suppliers can update own orders" ON public.orders;
CREATE POLICY "Suppliers can update own orders"
    ON public.orders FOR UPDATE
    USING (
        auth.uid() = supplier_id
        AND public.user_has_role(auth.uid(), 'supplier')
    );

-- Orders: Retailers update policy references profiles
DROP POLICY IF EXISTS "Retailers can update orders for receipt" ON public.orders;
CREATE POLICY "Retailers can update orders for receipt"
    ON public.orders FOR UPDATE
    USING (
        auth.uid() = retailer_id
        AND public.user_has_role(auth.uid(), 'retailer')
    );

-- Ledger: Retailers declare payments references profiles
DROP POLICY IF EXISTS "Retailers can declare payments" ON public.ledger_transactions;
CREATE POLICY "Retailers can declare payments"
    ON public.ledger_transactions FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.supplier_retailer_relations sr
            WHERE sr.id = relation_id
              AND sr.retailer_id = auth.uid()
        )
        AND public.user_has_role(auth.uid(), 'retailer')
        AND transaction_type = 'payment_decrease'
        AND status = 'pending'
    );


-- =============================================================================
-- ✅ RLS RECURSION FIX COMPLETE
-- =============================================================================
-- All cross-table profile role checks now use SECURITY DEFINER functions
-- which bypass RLS, breaking the recursion cycle.
-- =============================================================================
