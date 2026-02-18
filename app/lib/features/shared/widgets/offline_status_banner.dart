import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../data/services/sync_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// OFFLINE STATUS BANNER — shows when actions are queued or device is offline.
//
// Drop this widget at the top of any Scaffold body:
//   Column(children: [
//     const OfflineStatusBanner(),
//     Expanded(child: ... ),
//   ])
//
// States:
//   • Offline (red)      — "Hors connexion • N actions en attente"
//   • Syncing (amber)    — "Synchronisation en cours..."
//   • Failed  (red)      — "N actions échouées" + Retry button
//   • Online + empty     — hidden (SizedBox.shrink)
// ═══════════════════════════════════════════════════════════════════════════════

class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(queueStatusProvider);
    final l10n = AppLocalizations.of(context);

    return statusAsync.when(
      data: (status) => _buildBanner(context, ref, status, l10n),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(
    BuildContext context,
    WidgetRef ref,
    QueueStatus status,
    AppLocalizations l10n,
  ) {
    // Nothing to show
    if (status.isOnline && !status.hasWork && !status.isSyncing) {
      return const SizedBox.shrink();
    }

    final Color bg;
    final Color fg;
    final IconData icon;
    final String text;
    final VoidCallback? action;

    if (!status.isOnline) {
      // ── Offline ──
      bg = const Color(0xFFFEE2E2); // red-100
      fg = const Color(0xFFDC2626); // red-600
      icon = Icons.cloud_off_rounded;
      text = l10n.isDarija
          ? 'ما كاينش إنترنت • ${status.pendingCount} فالانتظار'
          : 'Hors connexion • ${status.pendingCount} en attente';
      action = null;
    } else if (status.isSyncing) {
      // ── Syncing ──
      bg = const Color(0xFFFEF3C7); // amber-100
      fg = const Color(0xFFD97706); // amber-600
      icon = Icons.sync_rounded;
      text = l10n.isDarija
          ? 'كيتسنكرونيزي...'
          : 'Synchronisation en cours...';
      action = null;
    } else if (status.failedCount > 0) {
      // ── Failed actions ──
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
      icon = Icons.error_outline_rounded;
      text = l10n.isDarija
          ? '${status.failedCount} ما مشاوش • عاود'
          : '${status.failedCount} actions échouées';
      action = () => ref.read(retryFailedActionsProvider);
    } else {
      // ── Pending (online, waiting to sync) ──
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      icon = Icons.schedule_rounded;
      text = l10n.isDarija
          ? '${status.pendingCount} كيتسناو التسنيكرونيزا'
          : '${status.pendingCount} en attente de synchronisation';
      action = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: action,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: fg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.isDarija ? 'عاود' : 'Réessayer',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
