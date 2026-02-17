import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../providers/order_providers.dart';

/// Retailer Partial Receipt Screen — "Screen 10 — Partial Receipt" from UI&UX.pen.
///
/// Design spec (from `SltHq`):
///   Layout: vertical flex, clip: true, fill $bg-primary, height 844
///   Children:
///     1. fixedHeader: fill $bg-primary, height 80, gap 6, padding [0,20]
///        - headerTop: supplier avatar + "Vérification" title + BON-XXXX badge ($bg-dark, cornerRadius 6)
///        - headerBottom: driver icon (green) + driver name + "→" + retailer name + phone icon
///     2. searchBar: cornerRadius 10, fill $bg-surface, height 38 — optional search
///     3. scrollableBody: clip true, gap 6, padding [8,16], fill_container height
///        - each item row: cornerRadius 12, gap 10, height 76, padding [0,12]
///          * unchanged: fill $bg-surface, stepper buttons fill $bg-primary
///          * changed: fill #FFFBEB, stroke #FDE68A, stepper fill #FEF3C7, qty text #D97706
///          * info: thumbnail (50x50, icon, cornerRadius 10) + name (Inter 13/600) + brand·darija (Inter 11, $text-tertiary)
///            + "Original: XX → YY" label (#D97706 for changed)
///          * stepper: [−][qty][+] buttons 30x30, cornerRadius 8, gap 6
///     4. stickyFooter: fill $bg-primary, height 120, gap 10, padding [12,20,24,20], stroke top 1px $border-subtle
///        - totalsRow: [original total] [adjusted total with diff badge]
///        - confirmBtn: cornerRadius 14, fill $success-green, height 52, bilingual label
class RetailerPartialReceiptScreen extends ConsumerStatefulWidget {
  final String orderId;

  const RetailerPartialReceiptScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<RetailerPartialReceiptScreen> createState() =>
      _RetailerPartialReceiptScreenState();
}

class _RetailerPartialReceiptScreenState
    extends ConsumerState<RetailerPartialReceiptScreen> {
  bool _initialized = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedOrderIdProvider.notifier).state = widget.orderId;
    });
  }

  void _initQuantities(Order order) {
    if (!_initialized) {
      ref.read(adjustedQuantitiesProvider.notifier).initFromOrder(order);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));
    final adjustments = ref.watch(adjustedQuantitiesProvider);
    final adjustedTotal = ref.watch(adjustedTotalProvider);
    final adjustmentCount = ref.watch(adjustmentCountProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: orderAsync.when(
          data: (order) {
            if (order == null) {
              return Center(child: Text(l10n.error));
            }

            _initQuantities(order);

            return Column(
              children: [
                // ── Fixed Header ──
                _buildFixedHeader(context, l10n, order),

                // ── Search Bar (optional) ──
                _buildSearchBar(l10n),

                // ── Scrollable item list ──
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      final adjustedQty =
                          adjustments[index] ?? item.quantity;
                      final isChanged = adjustedQty != item.quantity;

                      return _buildItemRow(
                        item: item,
                        index: index,
                        adjustedQty: adjustedQty,
                        isChanged: isChanged,
                        l10n: l10n,
                      );
                    },
                  ),
                ),

                // ── Sticky Footer ──
                _buildStickyFooter(
                  order: order,
                  l10n: l10n,
                  adjustedTotal: adjustedTotal,
                  adjustmentCount: adjustmentCount,
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.alertRed),
                const SizedBox(height: 12),
                Text(l10n.error),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(orderDetailProvider(widget.orderId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FIXED HEADER — supplier info + BON badge + driver row
  //   fill $bg-primary, height 80, gap 6, padding [0,20]
  //   stroke bottom 1px $border-subtle
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildFixedHeader(
    BuildContext context,
    AppLocalizations l10n,
    Order order,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top row: back + title + BON badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Back button — 32x32, cornerRadius 8, fill $bg-surface
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isDarija ? 'التحقق' : 'Vérification',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        l10n.isDarija ? 'تأكيد الإستلام' : 'Réception partielle',
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

              // BON badge — cornerRadius 6, fill $bg-dark, height 26
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'BON-${order.id.substring(0, 4).toUpperCase()}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Bottom row: driver info ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    size: 14,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.driverName ?? 'Livreur',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '→',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.retailerName ?? 'Hanout',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Phone button — cornerRadius 8, fill #D1FAE5, 28x28
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.phone,
                    size: 14,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEARCH BAR — cornerRadius 10, fill $bg-surface, height 38
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 16,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.isDarija
                    ? 'قلّب على منتوج...'
                    : 'Chercher un produit...',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Text(
              l10n.isDarija ? '' : 'قلّب على منتوج',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ITEM ROW — adjustable quantity with +/- steppers
  //
  // Design spec from Screen 10:
  //   unchanged: fill $bg-surface, cornerRadius 12, height 76
  //   changed: fill #FFFBEB, stroke #FDE68A, stepper #FEF3C7, text #D97706
  //   thumbnail: 50x50, cornerRadius 10, icon placeholder
  //   stepper buttons: 30x30, cornerRadius 8
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildItemRow({
    required OrderItem item,
    required int index,
    required int adjustedQty,
    required bool isChanged,
    required AppLocalizations l10n,
  }) {
    // Colors based on whether the item was adjusted
    final bgColor = isChanged ? const Color(0xFFFFFBEB) : AppColors.bgSurface;
    final strokeColor = isChanged ? const Color(0xFFFDE68A) : Colors.transparent;
    final stepperBg = isChanged ? const Color(0xFFFEF3C7) : AppColors.bgPrimary;
    final qtyColor = isChanged ? const Color(0xFFD97706) : AppColors.textPrimary;

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: strokeColor,
          width: isChanged ? 1 : 0,
        ),
      ),
      child: Row(
        children: [
          // ── Thumbnail ──
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isChanged ? AppColors.bgSurface : const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.smartphone,
                size: 24,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Info ──
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${Formatters.price(item.unitPrice)} × ${item.quantity}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                // ── Change indicator ──
                if (isChanged)
                  Row(
                    children: [
                      Text(
                        'Original: ${item.quantity}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '→ $adjustedQty',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    l10n.isDarija
                        ? 'الكمية: $adjustedQty'
                        : 'Qté: $adjustedQty',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // ── Stepper ──
          Row(
            children: [
              // Minus button — 30x30, cornerRadius 8
              GestureDetector(
                onTap: () {
                  ref
                      .read(adjustedQuantitiesProvider.notifier)
                      .decrement(index);
                  ref.read(quantitiesReviewedProvider.notifier).state = true;
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: stepperBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '−',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: qtyColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Quantity display — Manrope 16/800, width 28
              SizedBox(
                width: 28,
                child: Center(
                  child: Text(
                    '$adjustedQty',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: qtyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Plus button — 30x30, cornerRadius 8
              GestureDetector(
                onTap: () {
                  ref
                      .read(adjustedQuantitiesProvider.notifier)
                      .increment(index, item.quantity);
                  ref.read(quantitiesReviewedProvider.notifier).state = true;
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: stepperBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: qtyColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STICKY FOOTER — totals + confirm button
  //
  // Design spec:
  //   fill $bg-primary, height 120, gap 10, padding [12,20,24,20]
  //   stroke top 1px $border-subtle
  //   totalsRow: [original] [adjusted with diff badge]
  //   confirmBtn: cornerRadius 14, fill $success-green, height 52
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStickyFooter({
    required Order order,
    required AppLocalizations l10n,
    required double adjustedTotal,
    required int adjustmentCount,
  }) {
    final diff = adjustedTotal - order.originalTotal;
    final isReviewed = ref.watch(quantitiesReviewedProvider);
    final canConfirm = isReviewed && !_isSubmitting;

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
          // ── Totals row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Original total
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isDarija ? 'المبلغ الأصلي' : 'Total initial',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    l10n.isDarija ? 'Total initial' : 'المبلغ الأصلي',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.price(order.originalTotal),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Adjusted total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.isDarija ? 'المبلغ المعدّل' : 'Total ajusté',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.isDarija ? 'Total ajusté' : 'المبلغ المعدّل',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        Formatters.price(adjustedTotal),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      if (diff != 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          height: 20,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(2)} DH',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Confirm button ──
          GestureDetector(
            onTap: canConfirm
                ? () async {
                    setState(() => _isSubmitting = true);
                    try {
                      await ref.read(
                        confirmReceiptProvider(widget.orderId).future,
                      );
                      if (mounted) {
                        context.pushReplacementNamed(
                          'retailer-handshake',
                          pathParameters: {'orderId': widget.orderId},
                          queryParameters: {
                            'adjustedTotal': adjustedTotal.toStringAsFixed(2),
                            'originalTotal': order.originalTotal.toStringAsFixed(2),
                            'itemCount': '${order.items.length}',
                            'adjustmentCount': '$adjustmentCount',
                            'driverName': order.driverName ?? '',
                            'retailerName': order.retailerName ?? '',
                          },
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${l10n.error}: $e'),
                            backgroundColor: AppColors.alertRed,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSubmitting = false);
                    }
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: canConfirm
                    ? AppColors.successGreen
                    : AppColors.bgMuted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSubmitting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else ...[
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: canConfirm
                          ? Colors.white
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.isDarija
                              ? 'أكّد مع الكورتيا'
                              : 'Confirmer avec le Livreur',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: canConfirm
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          l10n.isDarija
                              ? 'Confirmer avec le Livreur'
                              : 'أكّد مع الكورتيا',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: canConfirm
                                ? Colors.white.withOpacity(0.7)
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
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
}
