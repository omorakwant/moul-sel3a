/// Supabase connection constants.
/// Replace these with your actual Supabase project credentials.
class SupabaseConstants {
  SupabaseConstants._();

  /// Your Supabase project URL
  static const String url = 'https://YOUR_PROJECT_REF.supabase.co';

  /// Your Supabase anon/public key (safe for client-side use)
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
