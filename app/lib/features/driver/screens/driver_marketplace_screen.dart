import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/delivery_job.dart';
import '../providers/driver_providers.dart';

/// Driver Marketplace — Feed of open delivery jobs.
///
/// Each job displays a text-based route card:
///   📦 From: [Supplier Location] → To: [Retailer Location]
///   No maps — just city/location_name text labels.
class DriverMarketplaceScreen extends ConsumerWidget {
  const DriverMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final openJobs = ref.watch(openJobsFeedProvider);
    final activeJobs = ref.watch(myActiveJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(l10n.driverMarketplace),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.accentOrange,
        onRefresh: () async {
          ref.invalidate(openJobsFeedProvider);
          ref.invalidate(myActiveJobsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Active trips banner ──
            activeJobs.when(
              data: (jobs) {
                if (jobs.isEmpty) return const SliverToBoxAdapter();
                return SliverToBoxAdapter(
                  child: _ActiveTripsBanner(
                    jobs: jobs,
                    l10n: l10n,
                    onTap: (job) => context.push('/driver/active-trip/${job.id}'),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(),
              error: (_, __) => const SliverToBoxAdapter(),
            ),

            // ── Section header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  l10n.availableJobs,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // ── Job cards ──
            openJobs.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noJobsAvailable,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RouteCard(
                          job: jobs[index],
                          l10n: l10n,
                          onBid: () =>
                              context.push('/driver/bid/${jobs[index].id}'),
                        ),
                      ),
                      childCount: jobs.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accentOrange),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.error,
                          style: const TextStyle(color: AppColors.alertRed)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(openJobsFeedProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROUTE CARD — Text-based route display (no maps!)
// ═══════════════════════════════════════════════════════════════════════════════

class _RouteCard extends StatelessWidget {
  final DeliveryJob job;
  final AppLocalizations l10n;
  final VoidCallback onBid;

  const _RouteCard({
    required this.job,
    required this.l10n,
    required this.onBid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onBid,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Supplier name + type badge ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.supplierName ?? (l10n.isDarija ? 'المولي' : 'Fournisseur'),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _JobTypeBadge(job: job, l10n: l10n),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Route: From → To ──
                _RouteLabel(
                  icon: Icons.store_outlined,
                  iconColor: AppColors.accentOrange,
                  label: l10n.pickupFrom,
                  location: job.pickupLabel,
                ),
                // Connector line
                Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Container(
                    width: 2,
                    height: 20,
                    color: AppColors.bgMuted,
                  ),
                ),
                _RouteLabel(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.successGreen,
                  label: l10n.deliverTo,
                  location: job.dropoffLabel,
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.bgMuted),
                const SizedBox(height: 12),

                // ── Bottom row: weight + COD amount + bid button ──
                Row(
                  children: [
                    if (job.estimatedWeightKg != null) ...[
                      const Icon(Icons.scale_outlined,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '~${job.estimatedWeightKg!.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (job.isCOD && job.codAmount != null) ...[
                      const Icon(Icons.payments_outlined,
                          size: 16, color: AppColors.accentOrange),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.isDarija ? 'فلوس:' : 'COD:'} ${Formatters.price(job.codAmount!)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onBid,
                      icon: const Icon(Icons.gavel_outlined, size: 18),
                      label: Text(l10n.placeBid),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accentOrange,
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Route label row (icon + label + location text) ──
class _RouteLabel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String location;

  const _RouteLabel({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Job type badge (Delivery / COD) ──
class _JobTypeBadge extends StatelessWidget {
  final DeliveryJob job;
  final AppLocalizations l10n;

  const _JobTypeBadge({required this.job, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isCod = job.isCOD;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCod
            ? AppColors.accentOrange.withValues(alpha: 0.1)
            : AppColors.successGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCod ? l10n.cashCollection : l10n.deliveryOnly,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCod ? AppColors.accentOrange : AppColors.successGreen,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTIVE TRIPS BANNER
// ═══════════════════════════════════════════════════════════════════════════════

class _ActiveTripsBanner extends StatelessWidget {
  final List<DeliveryJob> jobs;
  final AppLocalizations l10n;
  final ValueChanged<DeliveryJob> onTap;

  const _ActiveTripsBanner({
    required this.jobs,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onTap(jobs.first),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.activeTrips,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${jobs.length} ${l10n.isDarija ? 'مسار نشط' : 'trajet(s) actif(s)'}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
