import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Retailer Handshake Confirmation — "Screen 11 — Handshake Confirmation" from UI&UX.pen.
///
/// Design spec (from `Fk1lG`):
///   Layout: vertical flex, clip: true, fill $bg-primary, height 844
///   Children:
///     1. fixedHeader: height 56, fill $bg-primary, stroke bottom 1px $border-subtle
///        - [X close (32x32, cornerRadius 8, $bg-surface)] + [Confirmation title + Darija subtitle] + [✓ Validé badge (cornerRadius 6, fill #D1FAE5)]
///     2. scrollableBody: clip true, gap 20, padding 20, fill_container height
///        a. successIcon: 72x72 circle, fill #D1FAE5, checkmark icon #059669 size 36
///        b. successText: "Réception Confirmée!" (Manrope 22/800) + Darija subtitle (Inter 14, $text-tertiary)
///        c. summaryCard: cornerRadius 16, fill $bg-surface, gap 14, padding 18
///           - title row: file icon + "Résumé de la Réception" + "ملخص"
///           - Bon N° row
///           - Articles vérifiés row (green text for count)
///           - Anomalies signalées row (amber badge)
///           - divider
///           - Montant Final row (green bold price)
///        d. participantsCard: cornerRadius 16, fill $bg-surface, gap 14, padding 18
///           - "Parties Présentes" header
///           - driver row with blue avatar + checkmark
///           - retailer row with amber avatar + checkmark
///        e. timestamp: centered, Inter 12, $text-tertiary
///     3. stickyFooter: height 120, fill $bg-primary, stroke top 1px, gap 10, padding [12,20,24,20]
///        a. shareBtn: fill $bg-dark, cornerRadius 14, height 48, bilingual WhatsApp label
///        b. doneBtn: stroke $border-subtle 1.5px, cornerRadius 14, height 48
class RetailerHandshakeScreen extends StatelessWidget {
  final String orderId;
  final double adjustedTotal;
  final double originalTotal;
  final int itemCount;
  final int adjustmentCount;
  final String driverName;
  final String retailerName;

  const RetailerHandshakeScreen({
    super.key,
    required this.orderId,
    required this.adjustedTotal,
    required this.originalTotal,
    required this.itemCount,
    required this.adjustmentCount,
    required this.driverName,
    required this.retailerName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bonRef = 'BON-${orderId.substring(0, 8).toUpperCase()}';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed Header ──
            _buildFixedHeader(context, l10n),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ══════════════════════════════════════════════
                    // SUCCESS ICON — 72x72, fill #D1FAE5, checkmark
                    // ══════════════════════════════════════════════
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          size: 36,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ══════════════════════════════════════════════
                    // SUCCESS TEXT — bilingual
                    // ══════════════════════════════════════════════
                    Text(
                      l10n.isDarija
                          ? 'تم تأكيد الإستلام بنجاح'
                          : 'Réception Confirmée!',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.isDarija
                          ? 'Réception Confirmée!'
                          : 'تم تأكيد الإستلام بنجاح',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // ══════════════════════════════════════════════
                    // SUMMARY CARD
                    // ══════════════════════════════════════════════
                    _buildSummaryCard(l10n, bonRef),
                    const SizedBox(height: 20),

                    // ══════════════════════════════════════════════
                    // PARTICIPANTS CARD
                    // ══════════════════════════════════════════════
                    _buildParticipantsCard(l10n),
                    const SizedBox(height: 20),

                    // ══════════════════════════════════════════════
                    // TIMESTAMP
                    // ══════════════════════════════════════════════
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${Formatters.dateTime(DateTime.now())} · GPS vérifié',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Sticky Footer ──
            _buildStickyFooter(context, l10n),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FIXED HEADER — Confirmation + ✓ Validé badge
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildFixedHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Close button — 32x32, cornerRadius 8, $bg-surface
              GestureDetector(
                onTap: () => context.goNamed('retailer-dashboard'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.close, size: 18, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isDarija ? 'تأكيد التسليم' : 'Confirmation',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.isDarija ? 'Confirmation' : 'تأكيد التسليم',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ✓ Validé badge — cornerRadius 6, fill #D1FAE5, height 26
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '✓ ${l10n.statusVerified}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SUMMARY CARD — receipt details
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSummaryCard(AppLocalizations l10n, String bonRef) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ── Title row ──
          Row(
            children: [
              const Icon(Icons.description_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                l10n.isDarija
                    ? 'ملخص الإستلام'
                    : 'Résumé de la Réception',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.isDarija ? '' : 'ملخص',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Bon N° ──
          _summaryRow(
            label: 'Bon N°',
            value: bonRef,
            valueStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // ── Articles vérifiés ──
          _summaryRow(
            label: l10n.isDarija ? 'المنتوجات المتحققة' : 'Articles vérifiés',
            value: '$itemCount / $itemCount',
            valueStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(height: 14),

          // ── Anomalies ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.isDarija
                    ? 'المشاكل المسجلة'
                    : 'Anomalies signalées',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (adjustmentCount > 0)
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '$adjustmentCount ${l10n.isDarija ? 'تبدلو' : 'modifiés'}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                )
              else
                const Text(
                  '0',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Divider ──
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.borderSubtle,
          ),
          const SizedBox(height: 14),

          // ── Montant Final ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isDarija ? 'المبلغ النهائي' : 'Montant Final',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    l10n.isDarija ? 'Montant Final' : 'المبلغ النهائي',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              Text(
                Formatters.price(adjustedTotal),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PARTICIPANTS CARD — driver + retailer
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildParticipantsCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ── Header ──
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                l10n.isDarija ? 'اللي كانو حاضرين' : 'Parties Présentes',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Driver row ──
          _participantRow(
            name: driverName.isNotEmpty ? driverName : 'Livreur',
            role: l10n.isDarija ? 'كورتيا · Livreur' : 'Livreur · كورتيا',
            avatarColor: const Color(0xFFDBEAFE),
            avatarText: driverName.isNotEmpty
                ? driverName.substring(0, 2).toUpperCase()
                : 'LV',
          ),
          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.borderSubtle,
          ),
          const SizedBox(height: 14),

          // ── Retailer row ──
          _participantRow(
            name: retailerName.isNotEmpty ? retailerName : 'Détaillant',
            role: l10n.isDarija ? 'مّولي · Détaillant' : 'Détaillant · مّولي',
            avatarColor: const Color(0xFFFEF3C7),
            avatarText: retailerName.isNotEmpty
                ? retailerName.substring(0, 2).toUpperCase()
                : 'DT',
          ),
        ],
      ),
    );
  }

  Widget _participantRow({
    required String name,
    required String role,
    required Color avatarColor,
    required String avatarText,
  }) {
    return Row(
      children: [
        // Avatar — 40x40, cornerRadius 20
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: avatarColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              avatarText,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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
                name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        // Checkmark — green
        const Icon(
          Icons.check_circle,
          size: 18,
          color: Color(0xFF059669),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STICKY FOOTER — share + return home
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStickyFooter(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Share button — fill $bg-dark, cornerRadius 14, height 48 ──
          GestureDetector(
            onTap: () async {
              // Share receipt summary via WhatsApp
              final bonRef = 'BON-${orderId.substring(0, 8).toUpperCase()}';
              final message = l10n.isDarija
                  ? '✅ وصل التسليم\n'
                    '$bonRef\n'
                    '${itemCount} articles · ${Formatters.price(adjustedTotal)}\n'
                    '${adjustmentCount > 0 ? '⚠️ $adjustmentCount anomalies' : '✓ Pas d\'anomalies'}'
                  : '✅ Reçu de livraison\n'
                    '$bonRef\n'
                    '${itemCount} articles · ${Formatters.price(adjustedTotal)}\n'
                    '${adjustmentCount > 0 ? '⚠️ $adjustmentCount anomalie(s)' : '✓ Aucune anomalie'}';
              final url = Uri.parse(Formatters.whatsappLink(phone: '', message: message));
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.isDarija
                          ? 'ما قدرناش نفتحو واتساب'
                          : 'Impossible d\'ouvrir WhatsApp'),
                      backgroundColor: AppColors.alertRed,
                    ),
                  );
                }
              }
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share, size: 18, color: AppColors.textOnDark),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.isDarija
                            ? 'شارك الوصل'
                            : 'Partager le Reçu',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        l10n.isDarija
                            ? 'Partager · WhatsApp'
                            : 'شارك الوصل · WhatsApp',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: AppColors.textMutedOnDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Return home button — stroke only, cornerRadius 14, height 48 ──
          GestureDetector(
            onTap: () => context.goNamed('retailer-dashboard'),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home, size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.isDarija
                        ? 'رجع للرئيسية'
                        : "Retour à l'accueil",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
