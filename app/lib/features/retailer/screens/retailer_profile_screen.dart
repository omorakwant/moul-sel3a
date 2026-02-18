import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../data/models/profile.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

/// Retailer Profile Screen — edit shop name, city, location, language + logout.
///
/// Design: matches bgPrimary/bgSurface card style used across the app.
/// Fields map directly to `public.profiles` columns:
///   - shop_name (required)
///   - city
///   - location_name (descriptive: "Derb Omar, n°42")
///   - preferred_language ('fr' | 'ar') toggle
///   - Sign out button
class RetailerProfileScreen extends ConsumerStatefulWidget {
  const RetailerProfileScreen({super.key});

  @override
  ConsumerState<RetailerProfileScreen> createState() =>
      _RetailerProfileScreenState();
}

class _RetailerProfileScreenState extends ConsumerState<RetailerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _locationCtrl;
  bool _initialized = false;
  bool _saving = false;
  bool _signingOut = false;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _cityCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _initControllers(Profile profile) {
    if (!_initialized) {
      _shopNameCtrl = TextEditingController(text: profile.shopName);
      _cityCtrl = TextEditingController(text: profile.city ?? '');
      _locationCtrl = TextEditingController(text: profile.locationName ?? '');
      _initialized = true;
    }
  }

  Future<void> _saveProfile(Profile currentProfile) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final updated = currentProfile.copyWith(
        shopName: _shopNameCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        locationName:
            _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      );
      await ref.read(updateProfileProvider)(updated);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija
                ? '✅ تم الحفظ بنجاح'
                : '✅ Profil mis à jour'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija
                ? '❌ ما قدرناش نحفظو'
                : '❌ Erreur lors de la mise à jour'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleLanguage(Profile currentProfile) async {
    final newLang = currentProfile.preferredLanguage == 'fr' ? 'ar' : 'fr';
    // Update locale immediately for responsive UX
    ref.read(localeProvider.notifier).state = newLang;
    // Persist to DB
    await ref.read(persistLocaleProvider(newLang).future);
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.isDarija ? 'تسجيل الخروج' : 'Déconnexion',
          style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.isDarija
              ? 'واش بصح بغيتي تخرج؟'
              : 'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.isDarija ? 'لا' : 'Non',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.isDarija ? 'نعم، خرج' : 'Oui, déconnecter',
              style: const TextStyle(
                color: AppColors.alertRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _signingOut = true);
    try {
      await ref.read(signOutProvider)();
      // Auth state change will automatically redirect to login via router
    } catch (e) {
      if (mounted) {
        setState(() => _signingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija
                ? '❌ ما قدرناش نخرجو'
                : '❌ Erreur de déconnexion'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Center(
                child: Text(l10n.error,
                    style: const TextStyle(fontFamily: 'Manrope', fontSize: 18)),
              );
            }

            _initControllers(profile);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(l10n),
                            const SizedBox(height: 24),
                            _buildAvatarSection(profile, l10n),
                            const SizedBox(height: 24),
                            _buildInfoCard(profile, l10n),
                            const SizedBox(height: 16),
                            _buildLanguageCard(profile, l10n),
                            const SizedBox(height: 16),
                            _buildAccountCard(profile, l10n),
                            const SizedBox(height: 24),
                            _buildSaveButton(profile, l10n),
                            const SizedBox(height: 12),
                            _buildSignOutButton(l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorCard(error: e),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
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
                l10n.isDarija ? 'الملف ديالي' : 'Mon Profil',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                l10n.isDarija ? 'Mon Profil' : 'الملف ديالي',
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
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // AVATAR
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildAvatarSection(Profile profile, AppLocalizations l10n) {
    final initials = _extractInitials(profile.shopName);

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.phone ?? '—',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            l10n.isDarija ? 'مول الحانوت' : 'Détaillant',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // INFO CARD — shop name, city, location
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildInfoCard(Profile profile, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            l10n.isDarija ? 'المعلومات ديالي' : 'MES INFORMATIONS',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Shop name
          _buildTextField(
            controller: _shopNameCtrl,
            label: l10n.shopNameLabel,
            hint: l10n.shopNameHint,
            icon: Icons.storefront,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l10n.isDarija
                    ? 'خصك تدخل سمية الحانوت'
                    : 'Le nom du commerce est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // City
          _buildTextField(
            controller: _cityCtrl,
            label: l10n.cityLabel,
            hint: l10n.cityHint,
            icon: Icons.location_city,
          ),
          const SizedBox(height: 12),

          // Location name
          _buildTextField(
            controller: _locationCtrl,
            label: l10n.isDarija ? 'العنوان' : 'Adresse',
            hint: l10n.isDarija ? 'مثلا: درب عمر، رقم 42' : 'ex: Derb Omar, n°42',
            icon: Icons.pin_drop,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentOrange, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // LANGUAGE CARD
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildLanguageCard(Profile profile, AppLocalizations l10n) {
    final isFr = profile.preferredLanguage == 'fr';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, size: 22, color: AppColors.accentOrange),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.isDarija ? 'اللغة' : 'Langue',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isFr ? 'Français' : 'الدارجة المغربية',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Toggle button
          GestureDetector(
            onTap: () => _toggleLanguage(profile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isFr ? 'الدارجة' : 'FR',
                style: TextStyle(
                  fontFamily: isFr ? 'Inter' : 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ACCOUNT INFO CARD (read-only)
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildAccountCard(Profile profile, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isDarija ? 'الحساب' : 'COMPTE',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'ID',
            value: profile.id.substring(0, 8).toUpperCase(),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.isDarija ? 'تاريخ التسجيل' : 'Inscrit le',
            value: '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SAVE BUTTON
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildSaveButton(Profile profile, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _saving ? null : () => _saveProfile(profile),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _saving ? AppColors.bgDark.withValues(alpha: 0.6) : AppColors.bgDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.textOnDark),
                  ),
                )
              : Text(
                  l10n.isDarija ? 'حفظ التعديلات' : 'Enregistrer',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnDark,
                  ),
                ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SIGN OUT BUTTON
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildSignOutButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _signingOut ? null : _signOut,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Center(
          child: _signingOut
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.alertRed),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 20, color: AppColors.alertRed),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.isDarija ? 'خروج' : 'Déconnexion',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.alertRed,
                          ),
                        ),
                        Text(
                          l10n.isDarija ? 'Se déconnecter' : 'تسجيل الخروج',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: AppColors.alertRed.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UTILS
  // ────────────────────────────────────────────────────────────────────────────
  String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
