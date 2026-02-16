import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../providers/order_providers.dart';

/// Retailer Order Detail Screen — "Screen 3 — Digital Bon" from UI&UX.pen.
///
/// Design spec (from `QXRud`):
///   Layout: vertical flex, clip: true, fill $bg-primary
///   Children:
///     1. statusBar (system)
///     2. contentWrapper: vertical flex, gap 20, padding [0,24,24,24]
///        a. header: "Bon de Commande" (Manrope 26/800) + supplier name (Inter 14, $text-secondary) + close button
///        b. itemsLabel: "ARTICLES COMMANDÉS" (Manrope 12/700, letterSpacing 2, $text-secondary)
///        c. orderItems card: cornerRadius 16, fill $bg-surface, vertical layout
///           - each row: [name (Manrope 15/600) + price detail (Inter 13, $text-secondary)] + [−][qty][+] stepper
///           - dividers: 1px $border-subtle
///           - total row: "Total Bon" (Manrope 16/700) + amount ($alert-red, Manrope 22/800, letterSpacing -0.3)
///        d. delivLabel: "LIVRAISON" (same style as itemsLabel)
///        e. deliverySection card: cornerRadius 16, fill $bg-surface
///           - driver row: truck icon ($accent-orange) + driver name + role subtitle
///           - COD toggle: banknote icon + "Payer à la livraison" + toggle switch
///        f. waNote: green info box (cornerRadius 12, fill #ECFDF5, gap 10, padding [12,16])
///        g. confirmBtn: ButtonPrimary ref, full width — "Valider la Commande · كونفطرمي"
///        h. disclaimer: center text, Inter 12, $text-tertiary
class RetailerOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const RetailerOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<RetailerOrderDetailScreen> createState() =>
      _RetailerOrderDetailScreenState();
}

class _RetailerOrderDetailScreenState
    extends ConsumerState<RetailerOrderDetailScreen> {
  bool _payOnDelivery = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: orderAsync.when(
          data: (order) {
            if (order == null) {
              return Center(
                child: Text(
                  l10n.error,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, l10n, order),
                          const SizedBox(height: 20),

                          // ── "ARTICLES COMMANDÉS" label ──
                          Text(
                            l10n.isDarija
                                ? 'المنتوجات المطلوبة'
                                : 'ARTICLES COMMANDÉS',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Order items card ──
                          _buildOrderItemsCard(order, l10n),
                          const SizedBox(height: 20),

                          // ── "LIVRAISON" label ──
                          Text(
                            l10n.isDarija ? 'التوصيل' : 'LIVRAISON',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Delivery section ──
                          _buildDeliverySection(order, l10n),
                          const SizedBox(height: 16),

                          // ── WhatsApp note ──
                          _buildWhatsAppNote(l10n),
                          const SizedBox(height: 20),

                          // ── Confirm / Partial Receipt button ──
                          _buildActionButton(order, l10n),
                          const SizedBox(height: 12),

                          // ── Disclaimer ──
                          Center(
                            child: Text(
                              l10n.isDarija
                                  ? 'الحساب غادي يتبدل بعد ما تأكد الإستلام'
                                  : 'Le solde sera mis à jour après réception confirmée',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accentOrange),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.alertRed),
                const SizedBox(height: 12),
                Text(l10n.error),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(orderDetailProvider(widget.orderId)),
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
  // HEADER — "Bon de Commande" + supplier name + close button
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, AppLocalizations l10n, Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.isDarija ? 'بون الطلبية' : 'Bon de Commande',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.isDarija
                    ? 'الطلبية · ${order.supplierName ?? ''}'
                    : 'الطلبية · ${order.supplierName ?? ''}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Close button — cornerRadius 12, fill $bg-surface, 48x48
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.close,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ORDER ITEMS CARD — line items with stepper + total
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildOrderItemsCard(Order order, AppLocalizations l10n) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ── Line items ──
          ...order.items.asMap().entries.expand((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == order.items.length - 1;

            return [
              _buildOrderItemRow(item, l10n),
              if (!isLast)
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.borderSubtle,
                ),
            ];
          }),

          // ── Divider before total ──
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.borderSubtle,
          ),

          // ── Total row ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.isDarija ? 'المجموع ديال البون' : 'Total Bon',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  Formatters.price(order.finalTotal),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.alertRed,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ── Item info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.price(item.unitPrice)} × ${item.quantity} = ${Formatters.price(item.lineTotal)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Quantity stepper (view-only on this screen) ──
          Row(
            children: [
              _buildMiniStepper(
                symbol: '−',
                onTap: null,
              ),
              const SizedBox(width: 8),
              Text(
                '${item.effectiveQuantity}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              _buildMiniStepper(
                symbol: '+',
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStepper({
    required String symbol,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.bgMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            symbol == '+' ? Icons.add : Icons.remove,
            size: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DELIVERY SECTION — driver info + COD toggle
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDeliverySection(Order order, AppLocalizations l10n) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ── Driver row ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 22,
                  color: AppColors.accentOrange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.driverName ??
                            (l10n.isDarija ? 'ما كاين كورتي' : 'Pas de livreur assigné'),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.isDarija ? 'كورتيا ديال التوصيل' : 'Nom du Livreur',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.borderSubtle,
          ),

          // ── COD toggle ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.isDarija
                          ? 'خلص عند التوصيل'
                          : 'Payer à la livraison',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                // Toggle — matches UI&UX.pen: cornerRadius 100, fill $accent-orange, 50x28
                GestureDetector(
                  onTap: () => setState(() => _payOnDelivery = !_payOnDelivery),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 28,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _payOnDelivery
                          ? AppColors.accentOrange
                          : AppColors.bgMuted,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _payOnDelivery
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
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

  // ════════════════════════════════════════════════════════════════════════════
  // WHATSAPP NOTE — green info box
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildWhatsAppNote(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 20,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.isDarija
                  ? 'غادي نصيفطو واحد الرسالة واتساب للكورتي'
                  : 'Un SMS WhatsApp sera envoyé au livreur',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ACTION BUTTON — context-sensitive based on order status
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildActionButton(Order order, AppLocalizations l10n) {
    // If order is shipped → show "Confirm Receipt" (goes to partial receipt)
    // If order is pending → show "Validate Order"
    final isShipped = order.status == 'shipped';

    final label = isShipped
        ? (l10n.isDarija
            ? 'تأكد الإستلام · أكّد مع الكورتيا'
            : 'Confirmer la Réception')
        : (l10n.isDarija
            ? '${l10n.confirmOrder} · كونفطرمي'
            : '${l10n.confirmOrder} · كونفطرمي');

    final color = isShipped ? AppColors.successGreen : AppColors.accentOrange;
    final icon = isShipped ? Icons.check_circle_outline : Icons.check;

    return GestureDetector(
      onTap: () {
        if (isShipped) {
          // Navigate to partial receipt screen
          context.pushNamed(
            'retailer-partial-receipt',
            pathParameters: {'orderId': widget.orderId},
          );
        } else {
          // TODO: Validate order logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.isDarija ? 'الطلبية تأكدات!' : 'Commande validée!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.onAccent),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
