import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../data/models/ledger_transaction.dart';
import '../../../data/repositories/ledger_repository.dart';

/// Supplier Dispute Resolution Screen — dispute a ledger transaction.
///
/// Flow:
///   1. Supplier navigates here from the verification screen when a
///      transaction seems incorrect.
///   2. Shows the transaction details (type, amount, date, status).
///   3. Supplier writes a dispute reason (text field).
///   4. Submit marks the transaction as 'disputed' in the ledger.
class SupplierDisputeScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const SupplierDisputeScreen({
    super.key,
    required this.transactionId,
  });

  @override
  ConsumerState<SupplierDisputeScreen> createState() =>
      _SupplierDisputeScreenState();
}

class _SupplierDisputeScreenState extends ConsumerState<SupplierDisputeScreen> {
  final _reasonCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) return;

    setState(() => _submitting = true);

    try {
      final repo = ref.read(ledgerRepositoryProvider);
      await repo.disputeTransaction(widget.transactionId, reason);

      if (mounted) {
        showSuccessSnackBar(
          context,
          messageFr: 'Litige soumis avec succès',
          messageDarija: 'تم تسجيل النزاع بنجاح',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final txnAsync = ref.watch(_transactionProvider(widget.transactionId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: txnAsync.when(
          data: (txn) {
            if (txn == null) {
              return Center(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  messageFr: 'Transaction introuvable',
                  messageDarija: 'ما لقيناش هاد المعاملة',
                ),
              );
            }
            return Column(
              children: [
                _buildHeader(l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTransactionCard(txn, l10n),
                        const SizedBox(height: 20),
                        _buildReasonSection(l10n),
                        const SizedBox(height: 24),
                        _buildSubmitButton(l10n),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accentOrange),
          ),
          error: (e, _) => ErrorCard(error: e),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.isDarija ? 'نزاع' : 'Litige',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.isDarija ? 'Contestation' : 'نزاع',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TRANSACTION DETAILS CARD
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildTransactionCard(LedgerTransaction txn, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isDarija ? 'تفاصيل المعاملة' : 'DÉTAILS DE LA TRANSACTION',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            icon: Icons.category_outlined,
            label: l10n.isDarija ? 'النوع' : 'Type',
            value: _txnTypeLabel(txn.transactionType, l10n),
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: l10n.isDarija ? 'المبلغ' : 'Montant',
            value: '${txn.amount.toStringAsFixed(2)} DH',
            valueColor: txn.isPaymentDecrease
                ? AppColors.successGreen
                : AppColors.alertRed,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.isDarija ? 'التاريخ' : 'Date',
            value: '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year}',
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            icon: Icons.info_outline,
            label: l10n.isDarija ? 'الحالة' : 'Statut',
            value: _statusLabel(txn.status, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // REASON SECTION
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildReasonSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isDarija ? 'السبب ديال النزاع' : 'MOTIF DU LITIGE',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          // Warning hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: AppColors.accentOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.isDarija
                        ? 'كتب علاش كاتعترض على هاد المعاملة'
                        : 'Expliquez pourquoi vous contestez cette transaction',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _reasonCtrl,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: l10n.isDarija
                  ? 'مثلا: المبلغ ماشي هو...'
                  : 'ex: Le montant ne correspond pas...',
              filled: true,
              fillColor: AppColors.bgPrimary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.accentOrange, width: 1.5),
              ),
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SUBMIT BUTTON
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildSubmitButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _submitting ? null : _submitDispute,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _submitting
              ? AppColors.alertRed.withValues(alpha: 0.6)
              : AppColors.alertRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gavel, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      l10n.isDarija ? 'سجّل النزاع' : 'Soumettre le litige',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────────
  String _txnTypeLabel(String type, AppLocalizations l10n) => switch (type) {
    'order_increase' => l10n.isDarija ? 'زيادة (طلبية)' : 'Augmentation (commande)',
    'payment' => l10n.isDarija ? 'خلاص' : 'Paiement',
    'adjustment' => l10n.isDarija ? 'تعديل' : 'Ajustement',
    _ => type,
  };

  String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
    'pending' => l10n.isDarija ? 'في الانتظار' : 'En attente',
    'verified' => l10n.isDarija ? 'متأكد' : 'Vérifié',
    'disputed' => l10n.isDarija ? 'متنازع عليه' : 'Contesté',
    _ => status,
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE PROVIDER — fetch single transaction by ID
// ═══════════════════════════════════════════════════════════════════════════════
final _transactionProvider =
    FutureProvider.family<LedgerTransaction?, String>((ref, txnId) async {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.getById(txnId);
});
