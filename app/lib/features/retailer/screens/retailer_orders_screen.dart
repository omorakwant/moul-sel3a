import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../providers/order_providers.dart';

/// Retailer Orders List — order history with status filter tabs.
///
/// PROJECT_CONTEXT.md — Priority 1:
///   "List of all orders with status filters, tap to view detail"
class RetailerOrdersScreen extends ConsumerStatefulWidget {
  const RetailerOrdersScreen({super.key});

  @override
  ConsumerState<RetailerOrdersScreen> createState() =>
      _RetailerOrdersScreenState();
}

class _RetailerOrdersScreenState extends ConsumerState<RetailerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab filter states
  static const _filters = [
    null,          // All
    'pending',
    'confirmed',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(retailerOrdersProvider);

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
          l10n.isDarija ? 'الطلبيات ديالي' : 'Mes Commandes',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.accentOrange,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accentOrange,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: l10n.isDarija ? 'الكل' : 'Tout'),
            Tab(text: l10n.statusPending),
            Tab(text: l10n.statusConfirmed),
            Tab(text: l10n.statusDelivered),
            Tab(text: l10n.statusCancelled),
          ],
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
        error: (e, _) => ErrorCard(
          error: e,
          onRetry: () => ref.invalidate(retailerOrdersProvider),
        ),
        data: (orders) {
          return TabBarView(
            controller: _tabController,
            children: _filters.map((filter) {
              final filtered = filter == null
                  ? orders
                  : orders.where((o) => o.status == filter).toList();
              return _OrdersList(orders: filtered);
            }).toList(),
          );
        },
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<Order> orders;

  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              l10n.isDarija ? 'مازال ما كاين تا طلبية' : 'Aucune commande',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accentOrange,
      onRefresh: () async {
        // Parent will handle refresh
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _RetailerOrderCard(order: order);
        },
      ),
    );
  }
}

class _RetailerOrderCard extends StatelessWidget {
  final Order order;

  const _RetailerOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderRef = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'retailer-order-detail',
          pathParameters: {'orderId': order.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
            // ── Header: order ref + status badge ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#$orderRef',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _OrderStatusBadge(status: order.status, l10n: l10n),
              ],
            ),
            const SizedBox(height: 8),

            // ── Supplier name + date ──
            Row(
              children: [
                const Icon(Icons.store_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.supplierName ?? (l10n.isDarija ? 'المولي' : 'Grossiste'),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  Formatters.date(order.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Items summary + total ──
            Row(
              children: [
                Text(
                  '${order.itemCount} ${l10n.items} · ${order.totalPieces} ${l10n.pieces}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.price(order.finalTotal),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),

            // ── Partial receipt indicator ──
            if (order.isPartiallyReceived) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgePendingBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: AppColors.badgePendingFg),
                    const SizedBox(width: 4),
                    Text(
                      l10n.partialReceipt,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.badgePendingFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Tap hint ──
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.isDarija ? 'شوف التفاصيل ←' : 'Voir détails →',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;

  const _OrderStatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'pending':
        bg = AppColors.badgePendingBg;
        fg = AppColors.badgePendingFg;
        break;
      case 'confirmed':
      case 'ready_for_pickup':
        bg = const Color(0xFFEEF2FF);
        fg = AppColors.webIndigoLight;
        break;
      case 'shipped':
        bg = const Color(0xFFFFF7ED);
        fg = AppColors.accentOrange;
        break;
      case 'delivered':
        bg = AppColors.badgeDeliveredBg;
        fg = AppColors.badgeDeliveredFg;
        break;
      case 'cancelled':
        bg = AppColors.badgeCODBg;
        fg = AppColors.badgeCODFg;
        break;
      default:
        bg = AppColors.bgSurface;
        fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.statusLabel(status),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
