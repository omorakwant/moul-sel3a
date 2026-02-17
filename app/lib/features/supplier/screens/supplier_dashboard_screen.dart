import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../../../data/models/supplier_retailer_relation.dart';
import '../providers/supplier_dashboard_providers.dart';

/// Supplier Dashboard — the admin control center.
///
/// PROJECT_CONTEXT.md — Step 5: Supplier Admin Portal
///   Tab 1: Overview (pending orders, revenue, active deliveries, retailer list)
///   Tab 2: Inventory (link to existing screen)
///   Tab 3: Retailer management
class SupplierDashboardScreen extends ConsumerStatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  ConsumerState<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState
    extends ConsumerState<SupplierDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(l10n),

            // ── Tab Bar ──
            Container(
              color: AppColors.bgPrimary,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.accentOrange,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accentOrange,
                labelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: l10n.isDarija ? 'الملخص' : 'Aperçu'),
                  Tab(text: l10n.isDarija ? 'الطلبيات' : 'Commandes'),
                  Tab(text: l10n.isDarija ? 'الزبناء' : 'Clients'),
                ],
              ),
            ),

            // ── Tab Content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(),
                  _OrdersTab(),
                  _RetailersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.isDarija ? 'لوحة التحكم' : 'Tableau de bord',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.isDarija ? 'المولي' : 'Espace Grossiste',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Quick actions
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            color: AppColors.textSecondary,
            tooltip: l10n.isDarija ? 'المخزون' : 'Inventaire',
            onPressed: () => context.pushNamed('supplier-inventory'),
          ),
          IconButton(
            icon: const Icon(Icons.verified_user_outlined),
            color: AppColors.textSecondary,
            tooltip: l10n.isDarija ? 'التحقق' : 'Vérification',
            onPressed: () => context.pushNamed('supplier-verification'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            color: AppColors.textSecondary,
            tooltip: l10n.isDarija ? 'الملف ديالي' : 'Mon Profil',
            onPressed: () => context.pushNamed('supplier-profile'),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1: OVERVIEW
// ═════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pendingCount = ref.watch(supplierPendingOrderCountProvider);
    final activeDeliveries = ref.watch(supplierActiveDeliveryCountProvider);
    final totalRevenue = ref.watch(supplierTotalRevenueProvider);
    final totalOutstanding = ref.watch(supplierTotalOutstandingProvider);

    return RefreshIndicator(
      color: AppColors.accentOrange,
      onRefresh: () async {
        ref.invalidate(supplierPendingOrdersProvider);
        ref.invalidate(supplierOrdersProvider);
        ref.invalidate(supplierRelationsProvider);
        ref.invalidate(supplierDeliveryJobsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Cards Grid ──
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.pending_actions,
                    label: l10n.isDarija ? 'طلبيات كتسنا' : 'En attente',
                    value: '$pendingCount',
                    color: AppColors.badgePendingFg,
                    bgColor: AppColors.badgePendingBg,
                    onTap: () {
                      // Switch to orders tab
                      final tabController = DefaultTabController.of(context);
                      tabController.animateTo(1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.local_shipping_outlined,
                    label: l10n.isDarija ? 'توصيلات نشطة' : 'Livraisons',
                    value: '$activeDeliveries',
                    color: AppColors.webIndigoLight,
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.trending_up,
                    label: l10n.isDarija ? 'الدخل الكلي' : 'Revenu total',
                    value: Formatters.price(totalRevenue),
                    color: AppColors.successGreen,
                    bgColor: AppColors.badgeDeliveredBg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.isDarija ? 'الديون' : 'Créances',
                    value: Formatters.price(totalOutstanding),
                    color: AppColors.accentOrange,
                    bgColor: const Color(0xFFFFF7ED),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Pending Orders Preview ──
            _SectionHeader(
              title: l10n.isDarija ? 'طلبيات جديدة' : 'Nouvelles commandes',
              icon: Icons.fiber_new_rounded,
            ),
            const SizedBox(height: 12),
            _PendingOrdersList(),

            const SizedBox(height: 28),

            // ── Quick Links ──
            _SectionHeader(
              title: l10n.isDarija ? 'وصول سريع' : 'Accès rapide',
              icon: Icons.bolt,
            ),
            const SizedBox(height: 12),
            _QuickLinksGrid(),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2: ORDERS
// ═════════════════════════════════════════════════════════════════════════════

class _OrdersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(supplierOrdersProvider);

    return RefreshIndicator(
      color: AppColors.accentOrange,
      onRefresh: () async {
        ref.invalidate(supplierOrdersProvider);
      },
      child: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
        error: (e, _) => ErrorCard(
          error: e,
          onRetry: () => ref.invalidate(supplierOrdersProvider),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(
                    l10n.isDarija ? 'مازال ما جات تا طلبية' : 'Aucune commande',
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
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3: RETAILERS
// ═════════════════════════════════════════════════════════════════════════════

class _RetailersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final relationsAsync = ref.watch(supplierRelationsProvider);

    return RefreshIndicator(
      color: AppColors.accentOrange,
      onRefresh: () async {
        ref.invalidate(supplierRelationsProvider);
      },
      child: relationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
        error: (e, _) => ErrorCard(error: e),
        data: (relations) {
          if (relations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(
                    l10n.isDarija ? 'مازال ما عندك تا زبون' : 'Aucun client',
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
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: relations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final relation = relations[index];
              return _RetailerCard(relation: relation);
            },
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accentOrange),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Shows the first 3 pending orders on the overview tab.
class _PendingOrdersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pendingAsync = ref.watch(supplierPendingOrdersProvider);

    return pendingAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
      ),
      error: (e, _) => ErrorCard(error: e),
      data: (orders) {
        if (orders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                l10n.isDarija ? 'ما كاين تا طلبية جديدة ✓' : 'Aucune commande en attente ✓',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        // Show first 3 pending orders
        final preview = orders.take(3).toList();
        return Column(
          children: [
            ...preview.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OrderCard(order: order, compact: true),
            )),
            if (orders.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to full orders list handled by tab switch
                },
                child: Text(
                  l10n.isDarija
                      ? 'شوف الكل (${orders.length})'
                      : 'Voir tout (${orders.length})',
                  style: const TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Order card with confirm/reject actions for supplier.
class _OrderCard extends ConsumerWidget {
  final Order order;
  final bool compact;

  const _OrderCard({required this.order, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final orderRef = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return Container(
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
              _StatusBadge(status: order.status, l10n: l10n),
            ],
          ),
          const SizedBox(height: 8),

          // ── Retailer name + date ──
          Row(
            children: [
              const Icon(Icons.store_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.retailerName ?? (l10n.isDarija ? 'مول الحانوت' : 'Détaillant'),
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

          // ── Items + total ──
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

          // ── Action buttons for pending orders ──
          if (order.status == 'pending' && !compact) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderSubtle),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectOrder(context, ref, order.id, l10n),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.isDarija ? 'رفض' : 'Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.alertRed,
                      side: const BorderSide(color: AppColors.alertRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmOrder(context, ref, order.id, l10n),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l10n.isDarija ? 'قبل' : 'Confirmer'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ── Mark ready for pickup for confirmed orders ──
          if (order.status == 'confirmed' && !compact) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderSubtle),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    _markReadyForPickup(context, ref, order.id, l10n),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: Text(l10n.isDarija ? 'جاهزة للنقل' : 'Prête pour ramassage'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmOrder(
      BuildContext context, WidgetRef ref, String orderId, AppLocalizations l10n) async {
    try {
      await ref.read(confirmOrderProvider(orderId).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija ? 'الطلبية تأكدات ✓' : 'Commande confirmée ✓'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _rejectOrder(
      BuildContext context, WidgetRef ref, String orderId, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.isDarija ? 'رفض الطلبية?' : 'Refuser la commande ?'),
        content: Text(l10n.isDarija
            ? 'واش بصح بغيتي ترفض هاد الطلبية?'
            : 'Voulez-vous vraiment refuser cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.alertRed),
            child: Text(l10n.isDarija ? 'رفض' : 'Refuser'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(rejectOrderProvider(orderId).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija ? 'الطلبية ترفضات' : 'Commande refusée'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _markReadyForPickup(
      BuildContext context, WidgetRef ref, String orderId, AppLocalizations l10n) async {
    try {
      await ref.read(markReadyForPickupProvider(orderId).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija ? 'جاهزة للنقل ✓' : 'Prête pour ramassage ✓'),
            backgroundColor: AppColors.accentOrange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }
}

/// Status badge following the design system colors.
class _StatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

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
      case 'in_transit':
        bg = const Color(0xFFFFF7ED);
        fg = AppColors.accentOrange;
        break;
      case 'delivered':
      case 'verified':
        bg = AppColors.badgeDeliveredBg;
        fg = AppColors.badgeDeliveredFg;
        break;
      case 'cancelled':
      case 'rejected':
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

/// Retailer card for the Clients tab.
class _RetailerCard extends StatelessWidget {
  final SupplierRetailerRelation relation;

  const _RetailerCard({required this.relation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOverLimit = relation.isOverLimit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverLimit ? AppColors.alertRed : AppColors.borderSubtle,
        ),
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
          // ── Retailer name + status ──
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    (relation.retailerName ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentOrange,
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
                      relation.retailerName ?? (l10n.isDarija ? 'مول الحانوت' : 'Détaillant'),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${l10n.isDarija ? 'الحالة' : 'Statut'}: ${relation.status}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverLimit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.badgeCODBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.isDarija ? 'فات البلافو' : 'Hors limite',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.alertRed,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Balance bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.currentDebt,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                Formatters.price(relation.currentBalance),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isOverLimit ? AppColors.alertRed : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: relation.creditUsagePercent,
              backgroundColor: AppColors.bgSurface,
              valueColor: AlwaysStoppedAnimation(
                isOverLimit ? AppColors.alertRed : AppColors.accentOrange,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${l10n.creditLimit}: ${Formatters.price(relation.creditLimit)}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick links grid for common supplier actions.
class _QuickLinksGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _QuickLinkTile(
          icon: Icons.inventory_2_outlined,
          label: l10n.isDarija ? 'المخزون' : 'Inventaire',
          onTap: () => context.pushNamed('supplier-inventory'),
        ),
        _QuickLinkTile(
          icon: Icons.verified_user_outlined,
          label: l10n.isDarija ? 'التحقق' : 'Vérification',
          onTap: () => context.pushNamed('supplier-verification'),
        ),
        _QuickLinkTile(
          icon: Icons.add_box_outlined,
          label: l10n.isDarija ? 'زيد منتوج' : 'Ajouter produit',
          onTap: () => context.pushNamed('supplier-product-add'),
        ),
        _QuickLinkTile(
          icon: Icons.local_shipping_outlined,
          label: l10n.isDarija ? 'التوصيلات' : 'Livraisons',
          onTap: () => context.pushNamed('supplier-deliveries'),
        ),
      ],
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.accentOrange),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
