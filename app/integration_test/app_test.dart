import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lcarnet_b2b/app.dart';
import 'package:lcarnet_b2b/core/constants/supabase_constants.dart';
import 'package:lcarnet_b2b/data/services/offline_read_cache.dart';
import 'package:lcarnet_b2b/data/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// E2E smoke test: app launches and shows retailer dashboard (or splash then redirect).
/// Run: flutter test integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and shows dashboard or splash', (tester) async {
    await Hive.initFlutter();
    await OfflineReadCache.init();
    await Supabase.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );
    await SyncService().init();

    await tester.pumpWidget(
      const ProviderScope(
        child: LCarnetApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // On web/mock we land on retailer dashboard with "Solde" or "L'Carnet" or similar
    // On native we might see splash then login or dashboard
    final solde = find.textContaining('Solde');
    final appTitle = find.textContaining("L'Carnet");
    final carnet = find.textContaining('Carnet');
    final dashboard = find.textContaining('لوحة'); // Darija dashboard
    expect(
      solde.evaluate().isNotEmpty ||
          appTitle.evaluate().isNotEmpty ||
          carnet.evaluate().isNotEmpty ||
          dashboard.evaluate().isNotEmpty,
      true,
      reason: 'Expected to see dashboard or app title after launch',
    );
  });
}
