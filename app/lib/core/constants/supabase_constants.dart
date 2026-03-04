/// Supabase connection constants.
/// Project: moul-sel3a (hqlmeotqpkgvcnuqslgc)
/// Region: us-east-1 (East US / North Virginia)
/// Created: 2026-02-17
///
/// **Environment config:** Override at build time with --dart-define:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
///   flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class SupabaseConstants {
  SupabaseConstants._();

  static const String _defaultUrl = 'https://hqlmeotqpkgvcnuqslgc.supabase.co';
  static const String _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxbG1lb3RxcGtndmNudXFzbGdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNDU1NTIsImV4cCI6MjA4NjkyMTU1Mn0.YFJzckJJU4QnJYpgK09O1ZVPiwy5EWpv8Hp1czKtbXM';

  /// Supabase project URL (override with --dart-define=SUPABASE_URL=...)
  static String get url =>
      String.fromEnvironment('SUPABASE_URL', defaultValue: _defaultUrl);

  /// Supabase anon/public key (override with --dart-define=SUPABASE_ANON_KEY=...)
  static String get anonKey =>
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: _defaultAnonKey);

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
