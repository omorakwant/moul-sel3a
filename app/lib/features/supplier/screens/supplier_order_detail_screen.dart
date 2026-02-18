import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../providers/supplier_order_detail_providers.dart';

/// Supplier Order Detail — "Bon de Commande" from the supplier side.
///
/// Shows full order details with action buttons based on current status:
///   - pending → Confirm / Reject
///   - confirmed → Mark Ready for Pickup
///   - ready_for_pickup / shipped / delivered → Status info only
///
/// Design: follows the same card-based layout as RetailerOrderDetailScreen
/// but with supplier-specific actions and a status timeline.
class SupplierOrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const SupplierOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(supplierOrderDetailProvider(orderId));
    final actionState = ref.watch(supplierOrderActionProvider);

    // Show snackbar on action result
    ref.listen<OrderActionResult>(supplierOrderActionProvider, (prev, next) {
      if (next.state == OrderActionState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opération réussie ✓'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        ref.read(supplierOrderActionProvider.notifier).reset();
      } else if (next.state == OrderActionState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Erreur inconnue'),
            backgroundColor: AppColors.alertRed,
          ),
        );
        ref.read(supplierOrderActionProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: orderAsync.when(
          data: (order) {
            if (order == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text('Commande introuvable',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              );
            }
            return _buildContent(context, ref, order, actionState, l10n);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorCard(
            error: e,
            onRetry: () => ref.invalidate(supplierOrderDetailProvider(orderId)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Order order,
    OrderActionResult actionState,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // ── Header ──
        _buildHeader(context, order),

        // ── Scrollable Content ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Status Banner ──
                _StatusBanner(status: order.status),
                const SizedBox(height: 20),

                // ── Client Info ──
                _buildClientCard(context, order),
                const SizedBox(height: 20),

                // ── Items List ──
                _buildSectionLabel('ARTICLES COMMANDÉS'),
                const SizedBox(height: 8),
                _buildItemsCard(context, order),
                const SizedBox(height: 20),

                // ── Delivery Info ──
                if (order.deliveryType != null || order.driverName != null) ...[
                  _buildSectionLabel('LIVRAISON'),
                  const SizedBox(height: 8),
                  _buildDeliveryCard(context, order),
                  const SizedBox(height: 20),
                ],

                // ── Notes ──
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  _buildSectionLabel('NOTES'),
                  const SizedBox(height: 8),
                  _buildNotesCard(context, order),
                  const SizedBox(height: 20),
                ],

                // ── Partial Receipt Info ──
                if (order.isPartiallyReceived) ...[
                  _buildPartialReceiptBanner(context, order),
                  const SizedBox(height: 20),
                ],

                // ── Action Buttons ──
                _buildActions(context, ref, order, actionState),
                const SizedBox(height: 16),

                // ── Timestamps ──
                Center(
                  child: Text(
                    'Créée le ${Formatters.dateTime(order.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Order order) {
    final orderRef = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bon #$orderRef',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                ),
                if (order.retailerName != null)
                  Text(
                    order.retailerName!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                  ),
              ],
            ),
          ),
          // WhatsApp quick action
          if (order.retailerName != null)
            GestureDetector(
              onTap: () => _openWhatsApp(order),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat,
                    size: 20, color: AppColors.successGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.store_rounded,
                color: AppColors.accentOrange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.retailerName ?? 'Client',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                ),
                Text(
                  '${order.itemCount} articles · ${Formatters.price(order.finalTotal)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.timeAgo(order.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Builder(builder: (context) {
      return Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
      );
    });
  }

  Widget _buildItemsCard(BuildContext context, Order order) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Item rows
          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0)
                  const Divider(
                    height: 1,
                    color: AppColors.borderSubtle,
                    indent: 16,
                    endIndent: 16,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${Formatters.price(item.unitPrice)} × ${item.effectiveQuantity}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontFamily: 'Inter',
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.price(item.effectiveTotal),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                          ),
                          if (item.wasAdjusted)
                            Text(
                              'Ajusté: ${item.adjustedQuantity}/${item.quantity}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.accentOrange,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          // Total row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSubtle, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                ),
                Text(
                  Formatters.price(order.finalTotal),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColors.accentOrange,
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

  Widget _buildDeliveryCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    color: AppColors.accentOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.driverName ?? 'En attente de chauffeur',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                    ),
                    Text(
                      order.deliveryType == 'in_house'
                          ? 'Livraison maison'
                          : 'Chauffeur marketplace',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        order.notes!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
      ),
    );
  }

  Widget _buildPartialReceiptBanner(BuildContext context, Order order) {
    final diff = order.originalTotal - order.finalTotal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Réception partielle',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD97706),
                        fontSize: 14,
                      ),
                ),
                Text(
                  'Total ajusté: ${Formatters.price(order.finalTotal)} '
                  '(−${Formatters.price(diff)})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Inter',
                        color: const Color(0xFFD97706),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    Order order,
    OrderActionResult actionState,
  ) {
    final isLoading = actionState.state == OrderActionState.loading;
    final notifier = ref.read(supplierOrderActionProvider.notifier);

    switch (order.status) {
      case 'pending':
        return Column(
          children: [
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isLoading
                    ? null
                    : () => notifier.confirmOrder(orderId),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirmer · كونفيرمي',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Reject button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () => _showRejectDialog(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.alertRed,
                  side: const BorderSide(color: AppColors.alertRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Rejeter · رفض',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'confirmed':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () => notifier.markReadyForPickup(orderId),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.local_shipping_rounded),
                label: const Text(
                  'Prêt pour livraison · جاهز للتوصيل',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Quick link to manage delivery bids
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton.icon(
                onPressed: () =>
                    context.push('/supplier/deliveries'),
                icon: const Icon(Icons.groups_rounded, size: 18),
                label: const Text('Gérer les livraisons'),
              ),
            ),
          ],
        );

      case 'ready_for_pickup':
        return _buildStatusInfoCard(
          context,
          icon: Icons.inventory_2_rounded,
          color: AppColors.accentOrange,
          title: 'En attente de chauffeur',
          subtitle:
              'La commande est prête. Un chauffeur va bientôt la récupérer.',
        );

      case 'shipped':
        return _buildStatusInfoCard(
          context,
          icon: Icons.local_shipping_rounded,
          color: AppColors.webIndigoLight,
          title: 'En cours de livraison',
          subtitle: order.driverName != null
              ? 'Livrée par ${order.driverName}'
              : 'Le chauffeur est en route.',
        );

      case 'delivered':
        return _buildStatusInfoCard(
          context,
          icon: Icons.check_circle_rounded,
          color: AppColors.successGreen,
          title: 'Livrée ✓',
          subtitle: 'Commande livrée le ${Formatters.dateTime(order.updatedAt)}',
        );

      case 'cancelled':
        return _buildStatusInfoCard(
          context,
          icon: Icons.cancel_rounded,
          color: AppColors.alertRed,
          title: 'Annulée',
          subtitle: 'Cette commande a été annulée.',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Inter',
                        color: color.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter la commande ?'),
        content: const Text(
          'Cette action est irréversible. Le client sera notifié.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(supplierOrderActionProvider.notifier).rejectOrder(orderId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.alertRed,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp(Order order) async {
    // Build a quick WhatsApp link to the retailer
    // Note: In a real app we'd fetch the phone from the profile
    final message = Formatters.generateWhatsAppOrderMessage(
      orderId: order.id,
      retailerName: order.retailerName ?? 'Client',
      items: order.items
          .map((item) => {
                'qty': item.effectiveQuantity,
                'name': item.name,
                'price_per_unit': item.unitPrice,
              })
          .toList(),
      totalAmount: order.finalTotal,
    );

    // Use url_launcher — if phone not available, just copy message
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATUS BANNER
// ═════════════════════════════════════════════════════════════════════════════

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _statusConfig;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) get _statusConfig => switch (status) {
        'pending' => ('En attente de confirmation', AppColors.badgePendingFg,
            Icons.hourglass_top_rounded),
        'confirmed' => ('Confirmée — Préparer la commande',
            AppColors.successGreen, Icons.check_circle_outline),
        'ready_for_pickup' => ('Prête pour livraison', AppColors.accentOrange,
            Icons.inventory_2_rounded),
        'shipped' => ('En cours de livraison', AppColors.webIndigoLight,
            Icons.local_shipping_rounded),
        'delivered' => (
            'Livrée ✓',
            AppColors.successGreen,
            Icons.check_circle_rounded
          ),
        'cancelled' => (
            'Annulée',
            AppColors.alertRed,
            Icons.cancel_rounded
          ),
        _ => ('Statut inconnu', AppColors.textTertiary, Icons.help_outline),
      };
}
