-- =============================================================================
-- MOUL SEL3A — Text-Based Logistics Flow Migration
-- =============================================================================
-- Changes:
--   1. Add location_name to profiles (descriptive pickup/dropoff text label)
--   2. Add delivery_pin to delivery_jobs (4-digit handshake PIN)
--   3. Add pickup_location_name & dropoff_location_name to delivery_jobs
--      (auto-pulled from supplier/retailer profiles)
--   4. RLS: Drivers can update assigned jobs (status transitions)
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. PROFILES: Add location_name — a descriptive text label for the
--    user's physical location (e.g. "Derb Omar, n°42" or "زنقة الحرية")
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS location_name TEXT;

COMMENT ON COLUMN public.profiles.location_name IS
    'Descriptive location label for pickup/dropoff (e.g. "Derb Omar, Magasin n°42").';


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. DELIVERY_JOBS: Add delivery_pin — 4-digit code for secure handshake
--    Generated when driver is assigned, shared only with retailer.
--    Driver must collect this PIN to prove delivery.
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.delivery_jobs
    ADD COLUMN IF NOT EXISTS delivery_pin TEXT;

COMMENT ON COLUMN public.delivery_jobs.delivery_pin IS
    '4-digit PIN for delivery handshake. Retailer shares with driver to confirm receipt.';


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. DELIVERY_JOBS: Add location name fields
--    Auto-pulled from supplier/retailer profiles at job creation time.
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.delivery_jobs
    ADD COLUMN IF NOT EXISTS pickup_location_name TEXT,
    ADD COLUMN IF NOT EXISTS dropoff_location_name TEXT;

COMMENT ON COLUMN public.delivery_jobs.pickup_location_name IS
    'Human-readable supplier location label (e.g. "Magasin Derb Omar, n°42").';
COMMENT ON COLUMN public.delivery_jobs.dropoff_location_name IS
    'Human-readable retailer location label (e.g. "Boutique Hay Riad").';


-- ─────────────────────────────────────────────────────────────────────────────
-- 4. TRIGGER: Auto-generate 4-digit PIN when driver is assigned
--    Fires when assigned_driver_id transitions from NULL to a value.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.fn_generate_delivery_pin()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Only generate PIN when driver is newly assigned
    IF NEW.assigned_driver_id IS NOT NULL
       AND (OLD.assigned_driver_id IS NULL OR OLD.assigned_driver_id IS DISTINCT FROM NEW.assigned_driver_id)
       AND NEW.delivery_pin IS NULL
    THEN
        -- Generate random 4-digit PIN (1000-9999)
        NEW.delivery_pin := LPAD((1000 + floor(random() * 9000))::TEXT, 4, '0');
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_generate_delivery_pin
    BEFORE UPDATE ON public.delivery_jobs
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_generate_delivery_pin();

COMMENT ON FUNCTION public.fn_generate_delivery_pin() IS
    'Auto-generates a 4-digit delivery PIN when a driver is assigned to a job.';


-- ─────────────────────────────────────────────────────────────────────────────
-- 5. RLS: Drivers can update their assigned jobs (status: in_transit → completed)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE POLICY "Drivers can update assigned jobs"
    ON public.delivery_jobs FOR UPDATE
    USING (auth.uid() = assigned_driver_id);


-- ─────────────────────────────────────────────────────────────────────────────
-- 6. RLS: Retailers can view delivery jobs for their orders
--    (needed so retailer can see the PIN for handshake)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE POLICY "Retailers can view delivery jobs for their orders"
    ON public.delivery_jobs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.id = delivery_jobs.order_id
              AND o.retailer_id = auth.uid()
        )
    );


-- =============================================================================
-- ✅ MIGRATION COMPLETE — Text-Based Logistics Flow
-- =============================================================================
-- Summary:
--   • profiles.location_name  — descriptive location text
--   • delivery_jobs.delivery_pin — 4-digit handshake PIN (auto-generated)
--   • delivery_jobs.pickup_location_name — supplier location label
--   • delivery_jobs.dropoff_location_name — retailer location label
--   • trg_generate_delivery_pin — auto-PIN on driver assignment
--   • RLS: Drivers can update assigned jobs
--   • RLS: Retailers can view delivery jobs for their orders
-- =============================================================================
