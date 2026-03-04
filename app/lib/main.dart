import 'package:flutter/foundation.dart';
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

  try {
    // ── Initialize Hive for offline caching (skip on web to avoid white screen) ──
    if (!kIsWeb) {
      await Hive.initFlutter();
      await OfflineReadCache.init();
    }

    // ── Initialize Supabase with PKCE auth ──
    await Supabase.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // ── Initialize offline action queue (no-op on web; web uses mock data) ──
    await SyncService().init();
  } catch (e, st) {
    debugPrint('LCarnet init error: $e');
    debugPrintStack(stackTrace: st);
    // Continue to runApp so user sees UI; Supabase may still work for web mock flow
  }

  runApp(
    const ProviderScope(
      child: LCarnetApp(),
    ),
  );
}
