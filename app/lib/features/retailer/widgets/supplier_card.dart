import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/supplier_retailer_relation.dart';

/// Supplier Card widget — matches the "Component/SupplierCard" design
/// from UI&UX.pen exactly.
///
/// Layout: horizontal flex (gap 14, padding 18, cornerRadius 16)
///   [Avatar 48x48] [Info column: shopName, balance, action buttons] [chevron-right]
///
/// From PROJECT_CONTEXT.md Step 2:
///   Each card shows: Business Name, Current Debt in DH,
///   a 'Pay' button (opens Wafacash upload) and a 'Buy' button (opens catalog).
///
/// Colors:
///   - balance text: alertRed if debt > 0, successGreen if credit/zero
///   - bg: bgSurface (#E7E5E4)
class SupplierCard extends StatelessWidget {
  final SupplierRetailerRelation relation;
  final VoidCallback? onTap;
  final VoidCallback? onPay;

  const SupplierCard({
    super.key,
    required this.relation,
    this.onTap,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = relation.currentBalance;
    final isDebt = balance > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // ── Avatar placeholder ──
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _initials(relation.supplierName ?? '?'),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Info column ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop name
                  Text(
                    relation.supplierName ?? '—',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Balance (red for debt, green for credit)
                  Text(
                    Formatters.price(balance),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDebt
                          ? AppColors.alertRed
                          : AppColors.successGreen,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Credit limit subtitle
                  Text(
                    '${l10n.creditLimit}: ${Formatters.price(relation.creditLimit)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // ── Pay + Buy buttons (Step 2 spec) ──
                  Row(
                    children: [
                      // Pay button → opens payment declaration
                      _ActionChip(
                        label: l10n.declarePayment,
                        icon: Icons.payments_outlined,
                        color: AppColors.successGreen,
                        onTap: onPay,
                      ),
                      const SizedBox(width: 8),
                      // Buy button → opens catalog
                      _ActionChip(
                        label: l10n.isDarija ? 'شري' : 'Acheter',
                        icon: Icons.shopping_bag_outlined,
                        color: AppColors.accentOrange,
                        onTap: onTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Chevron ──
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// Extract initials from a shop name (e.g., "Alami Grossiste" → "AG").
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Small action chip used inside the SupplierCard for Pay/Buy actions.
class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
