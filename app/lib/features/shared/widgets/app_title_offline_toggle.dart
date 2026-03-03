import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/sync_providers.dart';

/// Wraps the app title ("L'Carnet B2B") with a hidden triple-tap gesture.
/// Triple-tap toggles [simulatedOfflineProvider] for demo (offline banner without turning off internet).
class AppTitleWithOfflineToggle extends ConsumerStatefulWidget {
  /// The title widget to show (e.g. Text("L'Carnet B2B")).
  /// If null, builds title from [AppLocalizations.appTitle].
  final Widget? title;

  const AppTitleWithOfflineToggle({super.key, this.title});

  @override
  ConsumerState<AppTitleWithOfflineToggle> createState() =>
      _AppTitleWithOfflineToggleState();
}

class _AppTitleWithOfflineToggleState
    extends ConsumerState<AppTitleWithOfflineToggle> {
  int _tapCount = 0;
  Timer? _tapResetTimer;

  static const _tripleTapWindow = Duration(milliseconds: 500);

  void _onTap() {
    _tapResetTimer?.cancel();
    _tapCount++;
    if (_tapCount >= 3) {
      _tapCount = 0;
      ref.read(simulatedOfflineProvider.notifier).state =
          !ref.read(simulatedOfflineProvider);
    } else {
      _tapResetTimer = Timer(_tripleTapWindow, () {
        if (mounted) setState(() => _tapCount = 0);
      });
    }
  }

  @override
  void dispose() {
    _tapResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final child = widget.title ??
        Text(
          l10n.appTitle,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        );
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
