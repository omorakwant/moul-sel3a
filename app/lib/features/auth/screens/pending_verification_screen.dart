import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/profile_repository.dart';
import '../providers/auth_providers.dart';

/// Fetch supplier phone for WhatsApp contact on pending verification.
final _supplierPhoneProvider =
    FutureProvider.family<String?, String>((ref, supplierId) async {
  final profile = await ref.watch(profileRepositoryProvider).getById(supplierId);
  return profile?.phone;
});

/// Pending Verification Gate — "Compte en attente" screen.
///
/// PROJECT_CONTEXT.md:
///   "Suppliers must 'verify' Retailers. For the MVP, let new users create
///    a profile, but show a 'Compte en attente' (Account Pending) message
///    if they try to access a specific Supplier's catalog before being linked."
///
/// This screen is shown when a retailer navigates to a supplier's catalog
/// but no active `supplier_retailer_relations` row exists for that pair.
class PendingVerificationScreen extends ConsumerWidget {
  final String supplierId;
  final String? supplierName;

  const PendingVerificationScreen({
    super.key,
    required this.supplierId,
    this.supplierName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDarija = locale == 'ar';
    // Pre-fetch supplier phone for WhatsApp button
    ref.watch(_supplierPhoneProvider(supplierId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              // ── Back button ──
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back,
                          size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ),

              // ── Centered content ──
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Pending icon ──
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.badgePendingBg,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.hourglass_top_rounded,
                            size: 40,
                            color: AppColors.badgePendingFg,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Title ──
                      Text(
                        isDarija
                            ? 'الحساب كيتسنى التأكيد'
                            : 'Compte en attente',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDarija
                            ? 'Compte en attente de validation'
                            : 'الحساب كيتسنى التأكيد',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // ── Explanation ──
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isDarija
                                  ? 'باش تشري من ${supplierName ?? 'هاد المول السلعة'}، خاصو يضيفك أولا فالنظام ديالو.'
                                  : 'Pour accéder au catalogue de ${supplierName ?? 'ce grossiste'}, vous devez d\'abord être ajouté comme client.',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isDarija
                                  ? 'صيفط ليه رسالة واتساب باش يضيفك'
                                  : 'Contactez-le via WhatsApp pour demander l\'accès',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── WhatsApp contact button ──
                      GestureDetector(
                        onTap: () async {
                          final phoneAsync = ref.read(_supplierPhoneProvider(supplierId));
                          final phone = phoneAsync.valueOrNull;
                          final message = isDarija
                              ? 'سلام، أنا بغيت نخدم معاك ف لكارني B2B. ممكن تضيفني؟'
                              : 'Bonjour, je souhaite être ajouté(e) comme client sur L\'Carnet B2B.';
                          final url = Uri.parse(Formatters.whatsappLink(
                            phone: phone ?? '',
                            message: message,
                          ));
                          try {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isDarija
                                      ? 'ما قدرناش نفتحو واتساب'
                                      : 'Impossible d\'ouvrir WhatsApp'),
                                  backgroundColor: AppColors.alertRed,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat,
                                  size: 20, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                isDarija
                                    ? 'تواصل مع المول السلعة'
                                    : 'Contacter le Grossiste',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Return home ──
                      GestureDetector(
                        onTap: () => context.goNamed('retailer-dashboard'),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isDarija
                                  ? 'رجع للرئيسية'
                                  : "Retour à l'accueil",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
