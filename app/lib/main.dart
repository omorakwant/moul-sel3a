import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/supabase_constants.dart';
import 'data/services/offline_read_cache.dart';
import 'data/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Hive for offline caching ──
  await Hive.initFlutter();

  // ── Offline read cache (catalog + orders); no-op on web ──
  await OfflineReadCache.init();

  // ── Initialize Supabase with PKCE auth ──
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // ── Initialize offline action queue ──
  await SyncService().init();

  runApp(
    const ProviderScope(
      child: LCarnetApp(),
    ),
  );
}
