import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/delivery_job.dart';
import '../providers/driver_providers.dart';

/// Driver Active Trip Screen — shows route, status, and PIN handshake.
///
/// Flow:
///   1. "Start Trip" → marks job as in_transit
///   2. Drive to retailer location (text-based directions shown)
///   3. "I've Arrived" → shows PIN entry field
///   4. Enter 4-digit PIN from retailer → verifies + completes delivery
///   5. If COD → ledger auto-updated with verified payment
class DriverActiveTripScreen extends ConsumerStatefulWidget {
  final String jobId;

  const DriverActiveTripScreen({super.key, required this.jobId});

  @override
  ConsumerState<DriverActiveTripScreen> createState() =>
      _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState
    extends ConsumerState<DriverActiveTripScreen> {
  final _pinController = TextEditingController();
  bool _showPinEntry = false;
  bool _pinError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final jobAsync = ref.watch(deliveryJobByIdProvider(widget.jobId));
    final tripState = ref.watch(tripActionNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(l10n.activeTrip),
        centerTitle: true,
        elevation: 0,
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return Center(child: Text(l10n.error));
          }
          return _buildTripContent(context, job, l10n, tripState);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
        error: (e, _) => ErrorCard(error: e),
      ),
    );
  }

  Widget _buildTripContent(
    BuildContext context,
    DeliveryJob job,
    AppLocalizations l10n,
    AsyncValue<void> tripState,
  ) {
    final isAssigned = job.status == 'assigned';
    final isInTransit = job.status == 'in_transit';
    final isCompleted = job.status == 'completed';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status indicator ──
          _StatusBanner(
            status: job.status,
            l10n: l10n,
          ),

          const SizedBox(height: 20),

          // ── Route card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.routeDetails,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Pickup
                _TripRouteStop(
                  icon: Icons.store_outlined,
                  iconColor: AppColors.accentOrange,
                  label: l10n.pickupFrom,
                  location: job.pickupLabel,
                  subtitle: job.supplierName,
                  isActive: isAssigned,
                ),

                // Connector
                Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => Container(
                        width: 2,
                        height: 8,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: isInTransit
                            ? AppColors.accentOrange
                            : AppColors.bgMuted,
                      ),
                    ),
                  ),
                ),

                // Dropoff
                _TripRouteStop(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.successGreen,
                  label: l10n.deliverTo,
                  location: job.dropoffLabel,
                  isActive: isInTransit,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── WhatsApp: contact retailer (prototype: mock phone) ──
          Consumer(
            builder: (context, ref, _) {
              final phoneAsync = ref.watch(retailerPhoneForJobProvider(job.id));
              return phoneAsync.when(
                data: (phone) {
                  if (phone == null || phone.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final message = l10n.isDarija
                            ? 'السلام عليكم، وصلت للعنوان، واش نقد نوصلك؟'
                            : 'Bonjour, je suis arrivé à l\'adresse. Pouvez-vous me confirmer ?';
                        final url = Uri.parse(Formatters.whatsappLink(
                          phone: phone,
                          message: message,
                        ));
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.chat_outlined, size: 20),
                      label: Text(l10n.contactRetailerWhatsApp),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25D366),
                        side: const BorderSide(color: Color(0xFF25D366)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),

          // ── COD / weight info ──
          if (job.isCOD && job.codAmount != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.accentOrange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.accentOrange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.codCollect,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.price(job.codAmount!),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Action area ──
          if (isCompleted)
            _CompletedBanner(l10n: l10n)
          else if (isAssigned)
            _buildStartTripButton(l10n, tripState)
          else if (isInTransit && !_showPinEntry)
            _buildArrivedButton(l10n)
          else if (isInTransit && _showPinEntry)
            _buildPinEntry(l10n, tripState),
        ],
      ),
    );
  }

  Widget _buildStartTripButton(
      AppLocalizations l10n, AsyncValue<void> tripState) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: tripState.isLoading
            ? null
            : () async {
                final success = await ref
                    .read(tripActionNotifierProvider.notifier)
                    .startTrip(widget.jobId);
                if (success) {
                  ref.invalidate(deliveryJobByIdProvider(widget.jobId));
                }
              },
        icon: tripState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.play_arrow_rounded, size: 28),
        label: Text(
          l10n.startTrip,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: AppColors.onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildArrivedButton(AppLocalizations l10n) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showPinEntry = true),
        icon: const Icon(Icons.flag_outlined, size: 24),
        label: Text(
          l10n.iArrived,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildPinEntry(AppLocalizations l10n, AsyncValue<void> tripState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _pinError ? AppColors.alertRed : AppColors.borderSubtle,
          width: _pinError ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline,
            size: 40,
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.enterPin,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.askRetailerPin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // PIN input — 4 digits
          SizedBox(
            width: 200,
            child: TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _pinError ? AppColors.alertRed : AppColors.borderSubtle,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _pinError ? AppColors.alertRed : AppColors.borderSubtle,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.accentOrange, width: 2),
                ),
              ),
              onChanged: (_) {
                if (_pinError) setState(() => _pinError = false);
              },
            ),
          ),

          if (_pinError) ...[
            const SizedBox(height: 8),
            Text(
              l10n.wrongPin,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.alertRed,
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: tripState.isLoading ? null : _verifyPin,
              icon: tripState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.verified_outlined),
              label: Text(
                l10n.verifyDelivery,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _pinError = true);
      return;
    }

    final l10n = AppLocalizations.of(context);
    final success = await ref
        .read(tripActionNotifierProvider.notifier)
        .verifyPinAndComplete(jobId: widget.jobId, pin: pin);

    if (success && mounted) {
      ref.invalidate(deliveryJobByIdProvider(widget.jobId));
      ref.invalidate(myActiveJobsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deliveryCompleted),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else if (mounted) {
      setState(() => _pinError = true);
      _pinController.clear();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusBanner extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;

  const _StatusBanner({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      'assigned' => (
          AppColors.accentOrange,
          Icons.assignment_outlined,
          l10n.statusAssigned,
        ),
      'in_transit' => (
          const Color(0xFF1565C0),
          Icons.delivery_dining,
          l10n.statusShipped,
        ),
      'completed' => (
          AppColors.successGreen,
          Icons.check_circle_outline,
          l10n.statusDelivered,
        ),
      _ => (
          AppColors.textTertiary,
          Icons.info_outline,
          l10n.statusLabel(status),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripRouteStop extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String location;
  final String? subtitle;
  final bool isActive;

  const _TripRouteStop({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.location,
    this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? iconColor.withOpacity(0.12) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
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
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final AppLocalizations l10n;

  const _CompletedBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle,
              color: AppColors.successGreen, size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.deliveryCompleted,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.deliveryCompletedSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
