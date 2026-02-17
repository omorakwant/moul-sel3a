import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/phone_auth_service.dart';
import '../providers/auth_providers.dart';

/// Login Screen — Phone Auth with FR/AR toggle.
///
/// Design follows the established design system:
///   - bg: $bg-primary (#FAF9F7)
///   - Accent: $accent-orange (#C2410C)
///   - Typography: Manrope (headings) + Inter (body)
///   - Big buttons, no keyboard entry where a button works
///
/// PROJECT_CONTEXT.md:
///   - "Phone Auth: Use Supabase Phone Auth"
///   - "Bilingual Onboarding: login screen should have a toggle at top for FR / AR"
///   - Morocco phone prefix: +212
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      setState(() => _errorMessage = _isDarija
          ? 'دخل الرقم ديالك'
          : 'Veuillez entrer votre numéro');
      return;
    }

    // Validate Morocco number format
    final cleaned = rawPhone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length < 9) {
      setState(() => _errorMessage = _isDarija
          ? 'الرقم قصير بزاف'
          : 'Numéro trop court');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(phoneAuthServiceProvider);
      await authService.sendOtp(rawPhone);

      if (mounted) {
        context.pushNamed(
          'otp-verify',
          pathParameters: {'phone': rawPhone},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _isDarija
              ? 'مشكل: $e'
              : 'Erreur: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isDarija => ref.watch(localeProvider) == 'ar';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDarija = locale == 'ar';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ══════════════════════════════════════════════
                // LANGUAGE TOGGLE — FR / AR at top
                // ══════════════════════════════════════════════
                _buildLanguageToggle(isDarija),
                const SizedBox(height: 48),

                // ══════════════════════════════════════════════
                // APP LOGO / TITLE
                // ══════════════════════════════════════════════
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'ل',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  isDarija ? 'لكارني B2B' : "L'Carnet B2B",
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isDarija
                      ? 'سوق الجملة ديال الإكسسوار'
                      : 'Marketplace B2B — Accessoires Téléphone',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ══════════════════════════════════════════════
                // PHONE INPUT SECTION
                // ══════════════════════════════════════════════
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isDarija ? 'الرقم ديالك' : 'Votre numéro de téléphone',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isDarija
                        ? 'غادي نصيفطو ليك كود SMS'
                        : 'Nous vous enverrons un code SMS',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Phone field with +212 prefix ──
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: _errorMessage != null
                        ? Border.all(color: AppColors.alertRed, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      // +212 prefix badge
                      Container(
                        width: 72,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.bgMuted,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '🇲🇦',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '+212',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Phone number input
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.2,
                          ),
                          decoration: InputDecoration(
                            hintText: isDarija
                                ? '6 12 34 56 78'
                                : '6 12 34 56 78',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: AppColors.textTertiary,
                              letterSpacing: 1.2,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Error message ──
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // ══════════════════════════════════════════════
                // SEND OTP BUTTON — big, full width
                // ══════════════════════════════════════════════
                GestureDetector(
                  onTap: _isLoading ? null : _sendOtp,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? AppColors.bgMuted
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isDarija
                                      ? 'صيفط الكود'
                                      : 'Envoyer le code',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onAccent,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  isDarija
                                      ? 'Envoyer le code SMS'
                                      : 'صيفط الكود',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: AppColors.onAccent.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ══════════════════════════════════════════════
                // FOOTER NOTE
                // ══════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isDarija
                              ? 'الحساب ديالك خاصو يتأكد من عند المول السلعة قبل ما تقدر تشري'
                              : 'Votre compte doit être validé par un grossiste avant de pouvoir passer commande',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LANGUAGE TOGGLE — FR / AR pill switcher
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildLanguageToggle(bool isDarija) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FR button
              GestureDetector(
                onTap: () => ref.read(localeProvider.notifier).state = 'fr',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    color: !isDarija ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: !isDarija
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'FR',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: !isDarija
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              // AR button
              GestureDetector(
                onTap: () => ref.read(localeProvider.notifier).state = 'ar',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDarija ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isDarija
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'ع',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarija
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
