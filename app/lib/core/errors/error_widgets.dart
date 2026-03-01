import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import 'app_exception.dart';

/// Converts any error into a user-friendly AppException.
AppException toAppException(Object error) {
  if (error is AppException) return error;
  return AppException.unknown(error);
}

// ══════════════════════════════════════════════════════════════════════════════
// ERROR CARD — full-width card with icon, message, retry button
// Use in .when(error:) callbacks for main content areas
// ══════════════════════════════════════════════════════════════════════════════

class ErrorCard extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorCard({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appError = toAppException(error);
    final info = _errorVisuals(appError.type);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(info.icon, size: 32, color: info.color),
            ),
            const SizedBox(height: 16),
            Text(
              appError.message(l10n.isDarija),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh,
                          size: 18, color: AppColors.accentOrange),
                      const SizedBox(width: 8),
                      Text(
                        l10n.isDarija ? 'عاود' : 'Réessayer',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
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

// ══════════════════════════════════════════════════════════════════════════════
// ERROR SLIVER — same as ErrorCard but wrapped in SliverToBoxAdapter
// Use inside CustomScrollView slivers
// ══════════════════════════════════════════════════════════════════════════════

class ErrorSliver extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorSliver({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorCard(error: error, onRetry: onRetry),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ERROR SNACKBAR — show a SnackBar with user-friendly error message
// Use in action catch blocks: showErrorSnackBar(context, e);
// ══════════════════════════════════════════════════════════════════════════════

void showErrorSnackBar(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final appError = toAppException(error);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              appError.message(l10n.isDarija),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.alertRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SUCCESS SNACKBAR — bilingual success message
// ══════════════════════════════════════════════════════════════════════════════

void showSuccessSnackBar(
  BuildContext context, {
  required String messageFr,
  required String messageDarija,
}) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.isDarija ? messageDarija : messageFr,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE — friendly "nothing here yet" widget
// ══════════════════════════════════════════════════════════════════════════════

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String messageFr;
  final String messageDarija;
  final VoidCallback? onAction;
  final String? actionLabelFr;
  final String? actionLabelDarija;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.messageFr,
    required this.messageDarija,
    this.onAction,
    this.actionLabelFr,
    this.actionLabelDarija,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 14),
            Text(
              l10n.isDarija ? messageDarija : messageFr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            if (onAction != null &&
                actionLabelFr != null &&
                actionLabelDarija != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.isDarija ? actionLabelDarija! : actionLabelFr!,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrange,
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

// ══════════════════════════════════════════════════════════════════════════════
// LOADING SKELETON — pulsing placeholder cards
// ══════════════════════════════════════════════════════════════════════════════

class LoadingSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingSkeleton({super.key, this.itemCount = 3, this.itemHeight = 80});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(itemCount, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SkeletonCard(height: itemHeight),
          );
        }),
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.3 + (_controller.value * 0.3);
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.bgSurface.withOpacity(opacity),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INTERNAL — icon + color per error type
// ══════════════════════════════════════════════════════════════════════════════

_ErrorVisuals _errorVisuals(ErrorType type) {
  switch (type) {
    case ErrorType.network:
      return const _ErrorVisuals(Icons.wifi_off, AppColors.alertRed);
    case ErrorType.server:
      return const _ErrorVisuals(Icons.cloud_off, AppColors.alertRed);
    case ErrorType.auth:
      return const _ErrorVisuals(Icons.lock_outline, AppColors.accentOrange);
    case ErrorType.permission:
      return const _ErrorVisuals(Icons.block, AppColors.alertRed);
    case ErrorType.notFound:
      return const _ErrorVisuals(Icons.search_off, AppColors.textTertiary);
    case ErrorType.duplicate:
      return const _ErrorVisuals(Icons.copy, AppColors.accentOrange);
    case ErrorType.validation:
      return const _ErrorVisuals(Icons.warning_amber, AppColors.accentOrange);
    case ErrorType.storage:
      return const _ErrorVisuals(Icons.cloud_upload_outlined, AppColors.alertRed);
    case ErrorType.rateLimit:
      return const _ErrorVisuals(Icons.timer_off, AppColors.accentOrange);
    case ErrorType.unknown:
      return const _ErrorVisuals(Icons.error_outline, AppColors.alertRed);
  }
}

class _ErrorVisuals {
  final IconData icon;
  final Color color;
  const _ErrorVisuals(this.icon, this.color);
}
