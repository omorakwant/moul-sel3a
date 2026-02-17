import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../data/models/delivery_job.dart';
import '../providers/supplier_dashboard_providers.dart';

/// Supplier Delivery Management Screen — overview of all delivery jobs.
///
/// Features:
///   - Status filter tabs: All, Open, Assigned, In Transit, Completed
///   - Each job card: route, status badge, driver info, bid count
///   - Tap open/bidding jobs → navigate to bid manager
///   - Pull-to-refresh
class SupplierDeliveryScreen extends ConsumerStatefulWidget {
  const SupplierDeliveryScreen({super.key});

  @override
  ConsumerState<SupplierDeliveryScreen> createState() =>
      _SupplierDeliveryScreenState();
}

class _SupplierDeliveryScreenState
    extends ConsumerState<SupplierDeliveryScreen> {
  String _selectedFilter = 'all';

  static const _filters = ['all', 'open', 'assigned', 'in_transit', 'completed'];

  List<DeliveryJob> _applyFilter(List<DeliveryJob> jobs) {
    if (_selectedFilter == 'all') return jobs;
    return jobs.where((j) => j.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final jobsAsync = ref.watch(supplierDeliveryJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 12),
            _buildFilterRow(l10n),
            const SizedBox(height: 12),
            Expanded(
              child: jobsAsync.when(
                data: (jobs) {
                  final filtered = _applyFilter(jobs);
                  if (filtered.isEmpty) {
                    return Center(
                      child: EmptyState(
                        icon: Icons.local_shipping_outlined,
                        messageFr: _selectedFilter == 'all'
                            ? 'Aucune livraison pour le moment'
                            : 'Aucune livraison "${_filterLabelFr(_selectedFilter)}"',
                        messageDarija: _selectedFilter == 'all'
                            ? 'مازال ما كاينة حتى توصيلة'
                            : 'ما كاينة حتى توصيلة "${_filterLabelDarija(_selectedFilter)}"',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(supplierDeliveryJobsProvider);
                    },
                    color: AppColors.accentOrange,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _buildJobCard(filtered[index], l10n),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accentOrange),
                ),
                error: (e, _) => ErrorCard(
                  error: e,
                  onRetry: () => ref.invalidate(supplierDeliveryJobsProvider),
                ),
              ),
            ),
          ],
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
                  l10n.isDarija ? 'التوصيلات' : 'Livraisons',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.isDarija ? 'Livraisons' : 'التوصيلات',
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
  // FILTER TABS
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildFilterRow(AppLocalizations l10n) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          final label = l10n.isDarija
              ? _filterLabelDarija(filter)
              : _filterLabelFr(filter);

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.bgDark : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // JOB CARD
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildJobCard(DeliveryJob job, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        // Navigate to bid manager for open/bidding_closed jobs
        if (job.status == 'open' || job.status == 'bidding_closed') {
          context.pushNamed(
            'supplier-bid-manager',
            pathParameters: {'jobId': job.id},
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Route + Status Badge ──
            Row(
              children: [
                const Icon(Icons.route, size: 18, color: AppColors.accentOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.routeDisplay,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusBadge(job.status, l10n),
              ],
            ),
            const SizedBox(height: 10),

            // ── Pickup / Dropoff Labels ──
            _buildLocationRow(
              Icons.warehouse_outlined,
              l10n.isDarija ? 'من' : 'De',
              job.pickupLabel,
            ),
            const SizedBox(height: 4),
            _buildLocationRow(
              Icons.storefront_outlined,
              l10n.isDarija ? 'ل' : 'À',
              job.dropoffLabel,
            ),

            const SizedBox(height: 10),

            // ── Bottom Row: Type + Driver/Bids ──
            Row(
              children: [
                // Job Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: job.isCOD
                        ? AppColors.accentOrange.withValues(alpha: 0.12)
                        : AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.isCOD ? 'COD' : (l10n.isDarija ? 'توصيلة فقط' : 'Livraison'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: job.isCOD
                          ? AppColors.accentOrange
                          : AppColors.textSecondary,
                    ),
                  ),
                ),

                if (job.codAmount != null && job.isCOD) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${job.codAmount!.toStringAsFixed(0)} DH',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrange,
                    ),
                  ),
                ],

                const Spacer(),

                // Driver name or bid count
                if (job.assignedDriverId != null && job.driverName != null)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        job.driverName!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                else if (job.bidCount != null && job.bidCount! > 0)
                  Row(
                    children: [
                      const Icon(Icons.gavel, size: 14, color: AppColors.accentOrange),
                      const SizedBox(width: 4),
                      Text(
                        '${job.bidCount} ${l10n.isDarija ? 'عرض' : 'offre(s)'}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String prefix, String location) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          '$prefix: ',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          ),
        ),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // STATUS BADGE
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    final (label, color) = _statusInfo(status, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  (String, Color) _statusInfo(String status, AppLocalizations l10n) {
    return switch (status) {
      'open' => (
        l10n.isDarija ? 'مفتوح' : 'Ouvert',
        AppColors.accentOrange,
      ),
      'bidding_closed' => (
        l10n.isDarija ? 'الطلبات مسدودة' : 'Enchères fermées',
        const Color(0xFF6366F1),
      ),
      'assigned' => (
        l10n.isDarija ? 'معيّن' : 'Assigné',
        const Color(0xFF3B82F6),
      ),
      'in_transit' => (
        l10n.isDarija ? 'فالطريق' : 'En route',
        const Color(0xFF8B5CF6),
      ),
      'completed' => (
        l10n.isDarija ? 'وصلات' : 'Livré',
        AppColors.successGreen,
      ),
      'cancelled' => (
        l10n.isDarija ? 'ملغية' : 'Annulé',
        AppColors.alertRed,
      ),
      _ => (status, AppColors.textTertiary),
    };
  }

  // ────────────────────────────────────────────────────────────────────────────
  // FILTER LABELS
  // ────────────────────────────────────────────────────────────────────────────
  String _filterLabelFr(String filter) => switch (filter) {
    'all' => 'Tous',
    'open' => 'Ouvert',
    'assigned' => 'Assigné',
    'in_transit' => 'En route',
    'completed' => 'Livré',
    _ => filter,
  };

  String _filterLabelDarija(String filter) => switch (filter) {
    'all' => 'الكل',
    'open' => 'مفتوح',
    'assigned' => 'معيّن',
    'in_transit' => 'فالطريق',
    'completed' => 'وصلات',
    _ => filter,
  };
}
