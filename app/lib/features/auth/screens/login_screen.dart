import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../shared/widgets/app_title_offline_toggle.dart';
import '../../../data/services/phone_auth_service.dart';
import '../providers/auth_providers.dart';
import '../widgets/language_toggle_pill.dart';

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
        final appErr = toAppException(e);
        setState(() {
          _errorMessage = appErr.message(_isDarija);
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isDarija => ref.watch(localeProvider) == 'ar';

  /// Dev-only login bypass using email+password.
  /// These accounts were created via Admin API with email credentials.
  Future<void> _devLogin(String email, String password, String label) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Invalidate auth-related providers so they re-fetch
      ref.invalidate(currentProfileProvider);
      // Wait for the profile to actually load before navigating
      final profile = await ref.read(currentProfileProvider.future);
      if (!mounted) return;

      if (profile == null || profile.shopName == 'Nouveau Compte') {
        context.go('/role-selection');
      } else {
        final role = profile.role;
        switch (role) {
          case 'supplier':
            context.go('/supplier/dashboard');
            break;
          case 'driver':
            context.go('/driver/marketplace');
            break;
          case 'retailer':
          default:
            context.go('/retailer/dashboard');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Dev login failed: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                const LanguageTogglePill(),
                const SizedBox(height: 48),

                // ══════════════════════════════════════════════
                // APP LOGO / TITLE
                // ══════════════════════════════════════════════
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
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

                AppTitleWithOfflineToggle(
                  title: Text(
                    isDarija ? 'لكارني B2B' : "L'Carnet B2B",
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
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
                        decoration: const BoxDecoration(
                          color: AppColors.bgMuted,
                          borderRadius: BorderRadius.only(
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
                          : AppColors.accentOrange,
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
                const SizedBox(height: 16),

                // ══════════════════════════════════════════════
                // SKIP LOGIN — test the app without SMS
                // ══════════════════════════════════════════════
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          ref.read(testModeEnabledProvider.notifier).state = true;
                          ref.invalidate(currentProfileProvider);
                          ref.invalidate(authGuardProvider);
                          if (mounted) context.goNamed('retailer-dashboard');
                        },
                  child: Text(
                    isDarija
                        ? 'دخول بدون كونيكسيون (تجربة)'
                        : 'Continuer sans connexion (test)',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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

                // ══════════════════════════════════════════════
                // DEV LOGIN PANEL — debug only, quick test accounts
                // ══════════════════════════════════════════════
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bug_report,
                                size: 16, color: Color(0xFF7C3AED)),
                            SizedBox(width: 8),
                            Text(
                              'DEV Quick Login',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDevLoginButton(
                          icon: Icons.store,
                          label: 'Grossiste Alami',
                          subtitle: 'Supplier',
                          email: 'supplier@test.com',
                          color: const Color(0xFF059669),
                        ),
                        const SizedBox(height: 8),
                        _buildDevLoginButton(
                          icon: Icons.shopping_bag,
                          label: 'Hanout Brahim',
                          subtitle: 'Retailer',
                          email: 'retailer@test.com',
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 8),
                        _buildDevLoginButton(
                          icon: Icons.local_shipping,
                          label: 'Kourtia Youssef',
                          subtitle: 'Driver',
                          email: 'driver@test.com',
                          color: const Color(0xFFD97706),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDevLoginButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required String email,
    required Color color,
  }) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => _devLogin(email, 'test123456', label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

}
