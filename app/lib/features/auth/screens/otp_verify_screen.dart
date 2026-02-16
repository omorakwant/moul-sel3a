import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/phone_auth_service.dart';
import '../providers/auth_providers.dart';

/// OTP Verification Screen — 6-digit code entry with resend timer.
///
/// PROJECT_CONTEXT.md: Phone Auth via Supabase OTP.
///   - User enters 6-digit code received via SMS
///   - On success: check if profile is complete → route accordingly
///   - Resend timer: 60 seconds cooldown
class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpVerifyScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  String? _errorMessage;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  bool get _isDarija => ref.watch(localeProvider) == 'ar';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendSeconds > 0) {
            _resendSeconds--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length != 6) {
      setState(() => _errorMessage = _isDarija
          ? 'دخل 6 ديال الأرقام'
          : 'Entrez les 6 chiffres');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(phoneAuthServiceProvider);
      await authService.verifyOtp(
        rawPhone: widget.phone,
        otpCode: code,
      );

      if (!mounted) return;

      // Invalidate profile provider to re-fetch after auth
      ref.invalidate(currentProfileProvider);

      // Check if profile is complete (has real shop_name)
      final isComplete = await authService.isProfileComplete();

      if (!mounted) return;

      if (isComplete) {
        // Existing user → restore saved language, then go to dashboard
        final profile = await authService.getProfile();
        final role = profile?['role'] as String? ?? 'retailer';
        final savedLang = profile?['preferred_language'] as String? ?? 'fr';
        ref.read(localeProvider.notifier).state = savedLang;
        _navigateToDashboard(role);
      } else {
        // New user → role selection (keeps the locale chosen on login screen)
        context.goNamed('role-selection');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _isDarija
              ? 'الكود غالط، عاود'
              : 'Code incorrect, réessayez';
        });
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _navigateToDashboard(String role) {
    switch (role) {
      case 'supplier':
        context.goNamed('supplier-dashboard');
        break;
      case 'driver':
        context.goNamed('driver-marketplace');
        break;
      case 'retailer':
      default:
        context.goNamed('retailer-dashboard');
        break;
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;

    try {
      final authService = ref.read(phoneAuthServiceProvider);
      await authService.sendOtp(widget.phone);
      _startResendTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isDarija
                ? 'كود جديد تصيفط'
                : 'Nouveau code envoyé'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _isDarija
              ? 'مشكل فالإرسال'
              : "Erreur lors de l'envoi";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarija = _isDarija;
    final maskedPhone = PhoneAuthService.normalizePhone(widget.phone);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
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
                const SizedBox(height: 40),

                // ══════════════════════════════════════════════
                // HEADER — SMS icon + title
                // ══════════════════════════════════════════════
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sms_outlined,
                      size: 32,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  isDarija ? 'دخل الكود' : 'Vérification',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isDarija
                      ? 'صيفطنا كود ل $maskedPhone'
                      : 'Code envoyé au $maskedPhone',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // ══════════════════════════════════════════════
                // 6-DIGIT OTP BOXES
                // ══════════════════════════════════════════════
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 46,
                      height: 56,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 6,
                        right: index == 2 ? 10 : 0, // gap between 3rd and 4th
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty
                              ? Colors.white
                              : AppColors.bgSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty
                                  ? AppColors.accentOrange
                                  : AppColors.borderSubtle,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty
                                  ? AppColors.accentOrange
                                  : AppColors.borderSubtle,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.accentOrange,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Refresh box styling
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          // Auto-verify when all 6 digits entered
                          if (_otpCode.length == 6) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),

                // ── Error message ──
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.alertRed,
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // ══════════════════════════════════════════════
                // VERIFY BUTTON
                // ══════════════════════════════════════════════
                GestureDetector(
                  onTap: _isVerifying ? null : _verifyOtp,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isVerifying
                          ? AppColors.bgMuted
                          : AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _isVerifying
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
                                  isDarija ? 'تأكد' : 'Vérifier',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onAccent,
                                  ),
                                ),
                                Text(
                                  isDarija ? 'Vérifier le code' : 'تأكد من الكود',
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
                const SizedBox(height: 24),

                // ══════════════════════════════════════════════
                // RESEND TIMER / BUTTON
                // ══════════════════════════════════════════════
                if (_resendSeconds > 0)
                  Text(
                    isDarija
                        ? 'عاود صيفط بعد $_resendSeconds ثانية'
                        : 'Renvoyer dans ${_resendSeconds}s',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _resendOtp,
                    child: Text(
                      isDarija
                          ? 'ما وصلكش الكود؟ عاود صيفط'
                          : "Pas reçu ? Renvoyer le code",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
