/// Supabase connection constants.
/// ⚠️ SETUP REQUIRED: Replace these with your actual Supabase project credentials.
/// 1. Create a project at https://supabase.com/dashboard
/// 2. Run migrations from supabase/migrations/ against your project
/// 3. Copy the project URL and anon key from Settings > API
class SupabaseConstants {
  SupabaseConstants._();

  /// Your Supabase project URL — replace with actual value
  // TODO: Replace with your Supabase project URL
  static const String url = 'https://YOUR_PROJECT_REF.supabase.co';

  /// Your Supabase anon/public key (safe for client-side use)
  // TODO: Replace with your Supabase anon key
  static const String anonKey = 'YOUR_ANON_KEY';

  /// Storage bucket for receipt photos & product images
  static const String storageBucket = 'lcarnet-assets';

  /// Tables
  static const String profilesTable = 'profiles';
  static const String relationsTable = 'supplier_retailer_relations';
  static const String productsTable = 'products';
  static const String ordersTable = 'orders';
  static const String deliveryJobsTable = 'delivery_jobs';
  static const String deliveryBidsTable = 'delivery_bids';
  static const String ledgerTable = 'ledger_transactions';
}
