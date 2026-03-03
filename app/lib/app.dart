import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/providers/auth_providers.dart';

class LCarnetApp extends ConsumerWidget {
  const LCarnetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(selectedLocaleProvider);

    final app = MaterialApp.router(
      title: "L'Carnet B2B",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // ── Localization (French + Moroccan Darija) ──
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // ── GoRouter ──
      routerConfig: router,
    );

    // Phone frame is applied per-route in app_router (_DesktopFrameShell)
    // so Supplier gets full width and Retailer/Driver get the 450px frame on desktop.
    return app;
  }
}
