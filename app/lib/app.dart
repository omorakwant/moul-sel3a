import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/providers/auth_providers.dart';

/// Dark gray background for desktop viewport (investor pitch).
const Color _kDesktopOuterBg = Color(0xFF1C1917);

/// Max width of the "phone" container on wide screens.
const double _kMaxMobileWidth = 450;

/// Breakpoint above which we show the centered mobile frame.
const double _kDesktopBreakpoint = 600;

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

    // ── Desktop-as-mobile wrapper for investor pitch ──
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > _kDesktopBreakpoint) {
          return Container(
            color: _kDesktopOuterBg,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: _kMaxMobileWidth),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: app,
              ),
            ),
          );
        }
        return app;
      },
    );
  }
}
