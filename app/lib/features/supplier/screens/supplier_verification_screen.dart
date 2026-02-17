import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/ledger_transaction.dart';
import '../providers/supplier_verification_providers.dart';

/// Supplier Verification Desk — approve/reject payment declarations.
///
/// PROJECT_CONTEXT.md — Step 5:
///   "A list of ledger_transactions where status is 'pending'.
///    Show the 'Evidence Photo' side-by-side with 'Approve/Reject' buttons.
///    Clicking 'Approve' must trigger the Database Update function."
class SupplierVerificationScreen extends ConsumerWidget {
  const SupplierVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pendingAsync = ref.watch(pendingVerificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.isDarija ? 'التحقق من الخلصات' : 'Vérification des paiements',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.accentOrange,
        onRefresh: () async {
          ref.invalidate(pendingVerificationsProvider);
        },
        child: pendingAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accentOrange),
          ),
          error: (e, _) => ErrorCard(
            error: e,
            onRetry: () => ref.invalidate(pendingVerificationsProvider),
          ),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified,
                        size: 64, color: AppColors.successGreen),
                    const SizedBox(height: 16),
                    Text(
                      l10n.isDarija
                          ? 'ما كاين تا خلصة كتسنا التأكيد ✓'
                          : 'Aucun paiement en attente ✓',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.isDarija
                          ? 'كولشي مقبول'
                          : 'Tous les paiements sont validés',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _VerificationCard(transaction: transactions[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _VerificationCard extends ConsumerStatefulWidget {
  final LedgerTransaction transaction;

  const _VerificationCard({required this.transaction});

  @override
  ConsumerState<_VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends ConsumerState<_VerificationCard> {
  bool _isProcessing = false;

  Future<void> _approve() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(
          verifyTransactionProvider(widget.transaction.id).future);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija
                ? 'الخلصة تأكدات ✓ الحساب تحدث'
                : 'Paiement validé ✓ Solde mis à jour'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    final l10n = AppLocalizations.of(context);
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(l10n.isDarija ? 'رفض الخلصة?' : 'Rejeter le paiement ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.isDarija
                  ? 'علاش كترفض هاد الخلصة؟ (اختياري)'
                  : 'Motif du rejet (optionnel)',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: l10n.isDarija ? 'السبب...' : 'Raison...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.alertRed),
            child: Text(l10n.isDarija ? 'رفض' : 'Rejeter'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      final notes = notesController.text.trim();
      await ref.read(rejectTransactionProvider((
        txId: widget.transaction.id,
        notes: notes.isNotEmpty ? notes : null,
      )).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija ? 'الخلصة ترفضات' : 'Paiement rejeté'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tx = widget.transaction;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: amount + method + date ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.badgePendingBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.statusPending,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.badgePendingFg,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.dateTime(tx.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Amount
                Text(
                  Formatters.price(tx.amount),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.successGreen,
                  ),
                ),
                const SizedBox(height: 4),
                // Payment method
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      tx.paymentMethodLabel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (tx.referenceCode != null &&
                        tx.referenceCode!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.tag, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        tx.referenceCode!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                // Notes
                if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    tx.notes!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Evidence Photo (if available) ──
          if (tx.evidenceUrl != null && tx.evidenceUrl!.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            GestureDetector(
              onTap: () => _showFullPhoto(context, tx.evidenceUrl!),
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.bgSurface,
                child: Image.network(
                  tx.evidenceUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                        color: AppColors.accentOrange,
                      ),
                    );
                  },
                  errorBuilder: (ctx, err, stack) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            size: 40, color: AppColors.textTertiary),
                        const SizedBox(height: 4),
                        Text(
                          l10n.isDarija ? 'ما قدرش نحمل الصورة' : 'Image non disponible',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── Action Buttons ──
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isProcessing
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accentOrange),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _reject,
                          icon: const Icon(Icons.close, size: 18),
                          label: Text(l10n.isDarija ? 'رفض' : 'Rejeter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.alertRed,
                            side: const BorderSide(color: AppColors.alertRed),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _approve,
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: Text(l10n.isDarija
                              ? 'قبل — خالصة صافية'
                              : 'Approuver'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showFullPhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
