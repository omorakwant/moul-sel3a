import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/delivery_bid.dart';
import '../../../data/models/delivery_job.dart';
import '../../driver/providers/driver_providers.dart';

/// Supplier Bid Manager Screen — view and accept/reject driver bids.
///
/// Shows:
///   - Route summary for the job
///   - List of bids sorted by amount (cheapest first)
///   - Accept/reject buttons per bid
///   - Accepted driver info with PIN generation confirmation
class SupplierBidManagerScreen extends ConsumerWidget {
  final String jobId;

  const SupplierBidManagerScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobAsync = ref.watch(deliveryJobByIdProvider(jobId));
    final bidsAsync = ref.watch(jobBidsProvider(jobId));
    final acceptState = ref.watch(acceptBidNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(l10n.bidManager),
        centerTitle: true,
        elevation: 0,
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) return Center(child: Text(l10n.error));

          return RefreshIndicator(
            color: AppColors.accentOrange,
            onRefresh: () async {
              ref.invalidate(deliveryJobByIdProvider(jobId));
              ref.invalidate(jobBidsProvider(jobId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Route summary ──
                  _RouteHeader(job: job, l10n: l10n),
                  const SizedBox(height: 20),

                  // ── Job status ──
                  if (job.status != 'open') ...[
                    _JobStatusCard(job: job, l10n: l10n),
                    const SizedBox(height: 20),
                  ],

                  // ── Bids section ──
                  Text(
                    l10n.driverBids,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  bidsAsync.when(
                    data: (bids) {
                      if (bids.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.gavel_outlined,
                                  size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noBidsYet,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: bids.map((bid) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _BidCard(
                              bid: bid,
                              l10n: l10n,
                              isJobOpen: job.status == 'open',
                              isLoading: acceptState.isLoading,
                              onAccept: () =>
                                  _acceptBid(context, ref, bid, l10n),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentOrange),
                    ),
                    error: (e, _) => ErrorCard(error: e),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
        error: (e, _) => ErrorCard(error: e),
      ),
    );
  }

  Future<void> _acceptBid(
    BuildContext context,
    WidgetRef ref,
    DeliveryBid bid,
    AppLocalizations l10n,
  ) async {
    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmAcceptBid),
        content: Text(
          l10n.isDarija
              ? 'بغيتي تقبل العرض ديال ${bid.driverName ?? 'هاد الكورتيا'} بـ ${Formatters.price(bid.bidAmount)}؟'
              : 'Accepter l\'offre de ${bid.driverName ?? 'ce livreur'} à ${Formatters.price(bid.bidAmount)} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
            ),
            child: Text(l10n.isDarija ? 'قبل' : 'Accepter'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref
        .read(acceptBidNotifierProvider.notifier)
        .acceptBid(bidId: bid.id, jobId: bid.jobId, driverId: bid.driverId);

    if (success && context.mounted) {
      ref.invalidate(deliveryJobByIdProvider(jobId));
      ref.invalidate(jobBidsProvider(jobId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bidAccepted),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _RouteHeader extends StatelessWidget {
  final DeliveryJob job;
  final AppLocalizations l10n;

  const _RouteHeader({required this.job, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store_outlined,
                  color: AppColors.accentOrange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.pickupLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_downward,
                size: 16, color: AppColors.textTertiary),
          ),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.successGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.dropoffLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (job.isCOD && job.codAmount != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n.cashCollection}: ${Formatters.price(job.codAmount!)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _JobStatusCard extends StatelessWidget {
  final DeliveryJob job;
  final AppLocalizations l10n;

  const _JobStatusCard({required this.job, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isAssigned = job.status == 'assigned' || job.status == 'bidding_closed';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAssigned
            ? AppColors.successGreen.withOpacity(0.06)
            : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAssigned
              ? AppColors.successGreen.withOpacity(0.25)
              : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAssigned ? Icons.check_circle : Icons.info_outline,
            color: isAssigned ? AppColors.successGreen : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAssigned ? l10n.driverAssigned : l10n.statusLabel(job.status),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAssigned
                        ? AppColors.successGreen
                        : AppColors.textPrimary,
                  ),
                ),
                if (isAssigned && job.driverName != null)
                  Text(
                    job.driverName!,
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
    );
  }
}

class _BidCard extends StatelessWidget {
  final DeliveryBid bid;
  final AppLocalizations l10n;
  final bool isJobOpen;
  final bool isLoading;
  final VoidCallback onAccept;

  const _BidCard({
    required this.bid,
    required this.l10n,
    required this.isJobOpen,
    required this.isLoading,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (bid.status) {
      'accepted' => AppColors.successGreen,
      'rejected' => AppColors.alertRed,
      'withdrawn' => AppColors.textTertiary,
      _ => AppColors.accentOrange,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: bid.isAccepted
              ? AppColors.successGreen.withOpacity(0.4)
              : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Driver avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.bgMuted,
                child: Text(
                  (bid.driverName ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.driverName ?? l10n.roleDriver,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (bid.driverCity != null)
                      Text(
                        bid.driverCity!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Bid amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.price(bid.bidAmount),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  if (bid.estimatedTime != null)
                    Text(
                      bid.estimatedTime!,
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

          if (bid.message != null && bid.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bid.message!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Status / action row
          if (bid.isPending && isJobOpen)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.isDarija ? 'كتسنا' : 'En attente',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onAccept,
                    icon: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(
                      l10n.isDarija ? 'قبل' : 'Accepter',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _bidStatusLabel(bid.status, l10n),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _bidStatusLabel(String status, AppLocalizations l10n) {
    return switch (status) {
      'pending' => l10n.isDarija ? 'كتسنا' : 'En attente',
      'accepted' => l10n.isDarija ? 'مقبول' : 'Accepté',
      'rejected' => l10n.isDarija ? 'مرفوض' : 'Refusé',
      'withdrawn' => l10n.isDarija ? 'منسحب' : 'Retiré',
      _ => status,
    };
  }
}
