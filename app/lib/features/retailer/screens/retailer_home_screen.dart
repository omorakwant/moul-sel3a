import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../providers/retailer_providers.dart';
import '../widgets/supplier_card.dart';

/// Retailer Home Screen — "Screen 1 — Dashboard" from UI&UX.pen.
///
/// Structure (from design):
///   1. Status bar (system)
///   2. Header: "المالين السلعة ديالي" subtitle + "Mes Grossistes" title + bell icon
///   3. Total Balance Card (dark bg): SOLDE TOTAL + amount + Darija subtitle
///   4. Section Header: "Fournisseurs" + count
///   5. Supplier Card list (scrollable)
///   6. Sticky footer: "Nouvelle Commande" FAB + TabBar
class RetailerHomeScreen extends ConsumerWidget {
  const RetailerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final relationsAsync = ref.watch(retailerRelationsProvider);
    final totalDebt = ref.watch(retailerTotalDebtProvider);
    final supplierCount = ref.watch(retailerSupplierCountProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Header: title + bell ──
                    _buildHeader(context, l10n),

                    const SizedBox(height: 24),

                    // ── Total Balance Card ──
                    _buildTotalBalanceCard(context, l10n, totalDebt, supplierCount),

                    const SizedBox(height: 24),

                    // ── Section header: Fournisseurs / count ──
                    _buildSectionHeader(l10n, supplierCount),

                    const SizedBox(height: 12),

                    // ── Supplier Cards ──
                    relationsAsync.when(
                      data: (relations) {
                        if (relations.isEmpty) {
                          return _buildEmptyState(l10n);
                        }
                        return Column(
                          children: [
                            ...relations.map((relation) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SupplierCard(
                                  relation: relation,
                                  onTap: () {
                                    context.pushNamed(
                                      'retailer-catalog',
                                      pathParameters: {
                                        'supplierId': relation.supplierId,
                                      },
                                      queryParameters: {
                                        if (relation.supplierName != null)
                                          'name': relation.supplierName!,
                                        'relationId': relation.id,
                                        if (relation.supplierPhone != null)
                                          'phone': relation.supplierPhone!,
                                      },
                                    );
                                  },
                                  onPay: () {
                                    context.pushNamed(
                                      'retailer-payment',
                                      pathParameters: {
                                        'relationId': relation.id,
                                      },
                                    );
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            // ── Add New Supplier via WhatsApp (Step 2 spec) ──
                            _buildAddSupplierButton(l10n),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: CircularProgressIndicator(
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                      error: (error, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.alertRed,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.error,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    ref.invalidate(retailerRelationsProvider),
                                child: Text(
                                  l10n.retry,
                                  style: const TextStyle(
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sticky footer: FAB + TabBar ──
            _buildStickyFooter(context, l10n),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: subtitle + title
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Darija subtitle — always Arabic script per UI&UX.pen design
              Text(
                'المالين السلعة ديالي',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              // French title — always French per UI&UX.pen design
              Text(
                'Mes Grossistes',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        // Right: notification bell
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              // Red dot
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.alertRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TOTAL BALANCE CARD
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTotalBalanceCard(
    BuildContext context,
    AppLocalizations l10n,
    double totalDebt,
    int supplierCount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "SOLDE TOTAL"
          const Text(
            'SOLDE TOTAL',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMutedOnDark,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          // Total amount
          Text(
            Formatters.price(totalDebt),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.textOnDark,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Darija subtitle: "الحساب لي عليك · chez 3 grossistes"
          Text(
            '${l10n.currentDebt} · chez $supplierCount grossistes',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textMutedOnDark,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(AppLocalizations l10n, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.isDarija ? 'المالين السلعة' : 'Fournisseurs',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '$count comptes',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ADD NEW SUPPLIER (WhatsApp invite — Step 2 spec)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildAddSupplierButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        // Open WhatsApp with a pre-filled invite message
        final link = Formatters.whatsappLink(
          phone: '',
          message: l10n.isDarija
              ? 'سلام! بغيتك تنزل تطبيق لكارني B2B باش نخدمو مع بعض.'
              : 'Bonjour! Rejoignez L\'Carnet B2B pour gérer nos commandes.',
        );
        final url = Uri.parse(link);
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } catch (_) {
          // WhatsApp not installed — fall back to share sheet
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderSubtle, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_add_outlined,
              size: 20,
              color: AppColors.accentOrange,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.isDarija
                  ? 'زيد مول سلعة جديد عبر واتساب'
                  : 'Ajouter un grossiste via WhatsApp',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.isDarija
                  ? 'مازال ما عندك حتى مول سلعة'
                  : 'Aucun fournisseur',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.isDarija
                  ? 'صيفط دعوة عبر واتساب'
                  : 'Invitez un grossiste via WhatsApp',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SUPPLIER PICKER — For "Nouvelle Commande" when multiple suppliers exist
  // ════════════════════════════════════════════════════════════════════════════
  void _showSupplierPicker(BuildContext context, AppLocalizations l10n) {
    final relationsAsync = ProviderScope.containerOf(context).read(retailerRelationsProvider);
    relationsAsync.whenData((relations) {
      if (relations.isEmpty) return;

      // If only one supplier, navigate directly
      if (relations.length == 1) {
        final r = relations.first;
        context.pushNamed(
          'retailer-catalog',
          pathParameters: {'supplierId': r.supplierId},
          queryParameters: {
            if (r.supplierName != null) 'name': r.supplierName!,
            'relationId': r.id,
            if (r.supplierPhone != null) 'phone': r.supplierPhone!,
          },
        );
        return;
      }

      // Multiple suppliers: show picker bottom sheet
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.bgMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.newOrder,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.isDarija
                        ? 'اختار المولي ديالك'
                        : 'Choisissez votre grossiste',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...relations.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        context.pushNamed(
                          'retailer-catalog',
                          pathParameters: {'supplierId': r.supplierId},
                          queryParameters: {
                            if (r.supplierName != null) 'name': r.supplierName!,
                            'relationId': r.id,
                            if (r.supplierPhone != null) 'phone': r.supplierPhone!,
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.bgSurface),
                        ),
                        child: Row(
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
                                  (r.supplierName ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                r.supplierName ?? '—',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STICKY FOOTER — FAB + TAB BAR
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStickyFooter(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── "Nouvelle Commande" FAB ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showSupplierPicker(context, l10n);
              },
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                l10n.newOrder,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: AppColors.onAccent,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab Bar ──
          _buildTabBar(context, l10n),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB BAR (matches Component/TabBar from UI&UX.pen)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          // Home (active)
          _tabItem(
            icon: Icons.home,
            label: l10n.isDarija ? 'الرئيسية' : 'Accueil',
            isActive: true,
            onTap: () {},
          ),
          // Catalogue
          _tabItem(
            icon: Icons.grid_view_rounded,
            label: l10n.isDarija ? 'كاتالوغ' : 'Catalogue',
            isActive: false,
            onTap: () {},
          ),
          // Bons (Orders)
          _tabItem(
            icon: Icons.description_outlined,
            label: l10n.isDarija ? 'البونات' : 'Bons',
            isActive: false,
            onTap: () {
              context.goNamed('retailer-orders');
            },
          ),
          // Profile
          _tabItem(
            icon: Icons.person_outline,
            label: l10n.isDarija ? 'بروفيل' : 'Profil',
            isActive: false,
            onTap: () {
              context.goNamed('retailer-profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? AppColors.accentOrange
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive
                    ? AppColors.accentOrange
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
