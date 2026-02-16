import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../providers/driver_providers.dart';

/// Driver Bid Screen — submit a delivery price bid for an open job.
///
/// Shows:
///   - Route card (pickup → dropoff, text-based)
///   - Job details (type, weight, COD amount)
///   - Bid form (amount in DH, estimated time, optional message)
class DriverBidScreen extends ConsumerStatefulWidget {
  final String jobId;

  const DriverBidScreen({super.key, required this.jobId});

  @override
  ConsumerState<DriverBidScreen> createState() => _DriverBidScreenState();
}

class _DriverBidScreenState extends ConsumerState<DriverBidScreen> {
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _timeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final jobAsync = ref.watch(deliveryJobByIdProvider(widget.jobId));
    final existingBid = ref.watch(myBidForJobProvider(widget.jobId));
    final bidState = ref.watch(placeBidNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(l10n.bidSheet),
        centerTitle: true,
        elevation: 0,
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return Center(child: Text(l10n.error));
          }

          // Check if driver already bid
          final hasBid = existingBid.valueOrNull != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Route Summary Card ──
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
                        Row(
                          children: [
                            const Icon(Icons.store_outlined,
                                color: AppColors.accentOrange, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.pickupFrom,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Text(
                            job.pickupLabel,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: AppColors.successGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.deliverTo,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Text(
                            job.dropoffLabel,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (job.isCOD && job.codAmount != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.payments_outlined,
                                    size: 18, color: AppColors.accentOrange),
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.cashCollection}: ${Formatters.price(job.codAmount!)}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (job.estimatedWeightKg != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.scale_outlined,
                                  size: 16, color: AppColors.textTertiary),
                              const SizedBox(width: 6),
                              Text(
                                '~${job.estimatedWeightKg!.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Already bid notice ──
                  if (hasBid) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.successGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.successGreen, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.bidAlreadyPlaced,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                                Text(
                                  '${Formatters.price(existingBid.valueOrNull!.bidAmount)} — ${existingBid.valueOrNull!.status}',
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
                    const SizedBox(height: 20),
                  ],

                  // ── Bid form (only if not already bid) ──
                  if (!hasBid) ...[
                    // Amount field
                    Text(
                      l10n.bidAmount,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        suffixText: 'DH',
                        hintText: l10n.isDarija ? 'مثلا: 50' : 'ex: 50',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.accentOrange, width: 2),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.isDarija
                              ? 'دخل الثمن'
                              : 'Veuillez entrer un montant';
                        }
                        final amount = double.tryParse(v);
                        if (amount == null || amount <= 0) {
                          return l10n.isDarija
                              ? 'الثمن خاصو يكون أكثر من 0'
                              : 'Le montant doit être supérieur à 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Estimated time
                    Text(
                      l10n.estimatedTime,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: l10n.isDarija
                            ? 'مثلا: ساعتين'
                            : 'ex: 2 heures',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.accentOrange, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Optional message
                    Text(
                      l10n.driverMessage,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.isDarija
                            ? 'رسالة للمولي (اختياري)'
                            : 'Message au fournisseur (optionnel)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.accentOrange, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: bidState.isLoading ? null : _submitBid,
                        icon: bidState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.gavel),
                        label: Text(
                          l10n.submitBid,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
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
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentOrange),
        ),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final amount = double.parse(_amountController.text);
    final bid = await ref.read(placeBidNotifierProvider.notifier).placeBid(
          jobId: widget.jobId,
          bidAmount: amount,
          estimatedTime:
              _timeController.text.isNotEmpty ? _timeController.text : null,
          message: _messageController.text.isNotEmpty
              ? _messageController.text
              : null,
        );

    if (bid != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bidSubmitted),
          backgroundColor: AppColors.successGreen,
        ),
      );
      ref.invalidate(myBidForJobProvider(widget.jobId));
      context.pop();
    }
  }
}
