/// Supabase connection constants.
/// Project: moul-sel3a (hqlmeotqpkgvcnuqslgc)
/// Region: us-east-1 (East US / North Virginia)
/// Created: 2026-02-17
class SupabaseConstants {
  SupabaseConstants._();

  /// Supabase project URL
  static const String url = 'https://hqlmeotqpkgvcnuqslgc.supabase.co';

  /// Supabase anon/public key (safe for client-side use)
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxbG1lb3RxcGtndmNudXFzbGdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNDU1NTIsImV4cCI6MjA4NjkyMTU1Mn0.YFJzckJJU4QnJYpgK09O1ZVPiwy5EWpv8Hp1czKtbXM';

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
