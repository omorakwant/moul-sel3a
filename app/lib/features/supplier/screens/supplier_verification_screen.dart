import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/ledger_transaction.dart';
import '../providers/supplier_verification_providers.dart';
import 'supplier_web_shell.dart';

/// Supplier Verification Desk — approve/reject payment declarations.
///
/// **Mobile**: Scrollable card list with approve/reject actions.
/// **Web (>1024px)**: 50/50 split view (Screen G — "The Verification Desk").
///   Left pane: Receipt image with zoom controls.
///   Right pane: Transaction details + balance impact + action buttons.
/// See UI&UX.pen node `Lgg5P` for design reference.
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
    final useWeb = isWebLayout(context);

    if (useWeb) {
      return SupplierWebShell(
        activeRoute: 'supplier-verification',
        child: _buildWebVerificationDesk(context, ref, l10n, pendingAsync),
      );
    }

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

  // ════════════════════════════════════════════════════════════════════════════
  // WEB SPLIT-VIEW LAYOUT (Screen G — "The Verification Desk")
  // UI&UX.pen node: Lgg5P
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildWebVerificationDesk(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AsyncValue<List<LedgerTransaction>> pendingAsync,
  ) {
    return pendingAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accentOrange),
      ),
      error: (e, _) => ErrorCard(
        error: e,
        onRetry: () => ref.invalidate(pendingVerificationsProvider),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return _buildWebEmptyState(l10n);
        }

        return _WebVerificationDesk(
          transactions: transactions,
          l10n: l10n,
        );
      },
    );
  }

  Widget _buildWebEmptyState(AppLocalizations l10n) {
    return Column(
      children: [
        _buildWebTopBar(l10n, 0, 0, 0),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 64, color: AppColors.successGreen),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebTopBar(AppLocalizations l10n, int total, int current, int _) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.webCardBg,
        border: Border(bottom: BorderSide(color: AppColors.webCardBorder)),
      ),
      child: Row(
        children: [
          Text(
            l10n.isDarija ? 'التحقق' : 'Vérifications',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          if (total > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$total ${l10n.isDarija ? 'كتسنا' : 'en attente'}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Stateful web split-view with queue navigation.
class _WebVerificationDesk extends ConsumerStatefulWidget {
  final List<LedgerTransaction> transactions;
  final AppLocalizations l10n;

  const _WebVerificationDesk({
    required this.transactions,
    required this.l10n,
  });

  @override
  ConsumerState<_WebVerificationDesk> createState() =>
      _WebVerificationDeskState();
}

class _WebVerificationDeskState extends ConsumerState<_WebVerificationDesk> {
  int _currentIndex = 0;

  LedgerTransaction get _current => widget.transactions[_currentIndex];

  void _next() {
    if (_currentIndex < widget.transactions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final total = widget.transactions.length;

    return Column(
      children: [
        // ── TopBar with queue navigation ──
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: AppColors.webCardBg,
            border: Border(bottom: BorderSide(color: AppColors.webCardBorder)),
          ),
          child: Row(
            children: [
              Text(
                l10n.isDarija ? 'التحقق' : 'Vérifications',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total ${l10n.isDarija ? 'كتسنا' : 'en attente'}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
              const Spacer(),
              // Previous
              GestureDetector(
                onTap: _currentIndex > 0 ? _prev : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.webBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.webCardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chevron_left, size: 16,
                          color: _currentIndex > 0 ? AppColors.textSecondary : AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.isDarija ? 'السابق' : 'Précédent',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _currentIndex > 0 ? AppColors.textSecondary : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentIndex + 1} / $total',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              // Next
              GestureDetector(
                onTap: _currentIndex < total - 1 ? _next : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _currentIndex < total - 1
                        ? AppColors.webIndigoLight
                        : AppColors.webBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.isDarija ? 'التالي' : 'Suivant',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _currentIndex < total - 1 ? Colors.white : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16,
                          color: _currentIndex < total - 1 ? Colors.white : AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Split View ──
        Expanded(
          child: Row(
            children: [
              // Left pane: Receipt image
              Expanded(child: _ReceiptPane(transaction: _current, l10n: l10n)),
              // Right pane: Validation panel
              SizedBox(
                width: 480,
                child: _ValidationPane(transaction: _current, l10n: l10n),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Left pane — receipt image with zoom controls.
class _ReceiptPane extends StatelessWidget {
  final LedgerTransaction transaction;
  final AppLocalizations l10n;

  const _ReceiptPane({required this.transaction, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F4),
      child: Column(
        children: [
          // Receipt header
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.webCardBg,
              border: Border(bottom: BorderSide(color: AppColors.webCardBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  l10n.isDarija ? 'الورقة ديال الخلصة' : 'Reçu ${transaction.paymentMethodLabel}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${Formatters.timeAgo(transaction.createdAt)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                // Zoom controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.webBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.webCardBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.zoom_out, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text(
                        '100%',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.zoom_in, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Receipt image area
          Expanded(
            child: Center(
              child: transaction.evidenceUrl != null
                  ? InteractiveViewer(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        margin: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          transaction.evidenceUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildNoImage(),
                        ),
                      ),
                    )
                  : _buildNoImage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.image_not_supported_outlined,
            size: 64, color: AppColors.textTertiary),
        const SizedBox(height: 12),
        Text(
          l10n.isDarija ? 'ما كاينش صورة' : 'Aucune image disponible',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Right pane — transaction validation panel.
class _ValidationPane extends ConsumerStatefulWidget {
  final LedgerTransaction transaction;
  final AppLocalizations l10n;

  const _ValidationPane({required this.transaction, required this.l10n});

  @override
  ConsumerState<_ValidationPane> createState() => _ValidationPaneState();
}

class _ValidationPaneState extends ConsumerState<_ValidationPane> {
  bool _isProcessing = false;

  Future<void> _approve() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(
          verifyTransactionProvider(widget.transaction.id).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.isDarija
                ? 'الخلصة تأكدات ✓ الحساب تحدث'
                : 'Paiement validé ✓ Solde mis à jour'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reject() async {
    final l10n = widget.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(l10n.isDarija ? 'رفض الخلصة?' : 'Rejeter le paiement ?'),
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
      await ref.read(rejectTransactionProvider((
        txId: widget.transaction.id,
        notes: null,
      )).future);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final tx = widget.transaction;

    return Container(
      color: AppColors.webCardBg,
      child: Column(
        children: [
          // Header
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.webCardBorder)),
            ),
            child: Text(
              l10n.isDarija ? 'تأكيد الخلصة' : 'Validation du Paiement',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.webBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CLIENT',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  '••',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.webIndigoLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.retailerName ?? (l10n.isDarija ? 'مول الحانوت' : 'Détaillant'),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    tx.paymentMethodLabel,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Declared amount
                  Text(
                    l10n.isDarija ? 'المبلغ المعلن' : 'MONTANT DÉCLARÉ',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.price(tx.amount),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      tx.notes!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Reference
                  if (tx.referenceCode != null) ...[
                    Text(
                      l10n.isDarija ? 'رقم المرجع' : 'RÉFÉRENCE DU TRANSFERT',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.webCardBorder),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tx.referenceCode!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.successGreen),
                        const SizedBox(width: 6),
                        Text(
                          l10n.isDarija ? 'المرجع كيتوافق مع الورقة' : 'Référence correspond au reçu',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Balance impact preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.isDarija ? 'التأثير على الحساب' : 'IMPACT SUR LE SOLDE',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _impactRow(
                          l10n.isDarija ? 'الحساب الحالي' : 'Solde actuel',
                          '—',
                          false,
                        ),
                        const SizedBox(height: 8),
                        _impactRow(
                          l10n.isDarija ? 'الخلصة' : 'Paiement reçu',
                          '- ${Formatters.price(tx.amount)}',
                          true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFFBBF7D0), height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.isDarija ? 'الحساب الجديد' : 'Nouveau solde',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15803D),
                              ),
                            ),
                            const Text(
                              '—',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (_isProcessing)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.accentOrange),
                    )
                  else ...[
                    // Validate button (green)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _approve,
                        icon: const Icon(Icons.check, size: 20),
                        label: Text(
                          l10n.isDarija ? 'صادق على الخلاص' : 'Valider Paiement',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Reject button (red outline)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _reject,
                        icon: const Icon(Icons.close, size: 20),
                        label: Text(
                          l10n.isDarija ? 'رفض' : 'Rejeter',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.alertRed,
                          side: const BorderSide(color: AppColors.alertRed, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'صادق على الخلاص',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _impactRow(String label, String value, bool isHighlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF15803D),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight ? const Color(0xFF16A34A) : const Color(0xFF15803D),
          ),
        ),
      ],
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
            color: Colors.black.withOpacity(0.04),
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
                    const Icon(Icons.payment, size: 16, color: AppColors.textSecondary),
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
                      const Icon(Icons.tag, size: 14, color: AppColors.textTertiary),
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
                        const Icon(Icons.broken_image_outlined,
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
