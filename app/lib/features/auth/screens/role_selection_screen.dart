import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../data/services/phone_auth_service.dart';
import '../providers/auth_providers.dart';
import '../widgets/language_toggle_pill.dart';

/// Role Selection Screen — first-login onboarding.
///
/// PROJECT_CONTEXT.md:
///   "Upon first login, if a profile doesn't exist, the user must choose:
///    Grossiste (Supplier), Détaillant (Retailer), or Livreur (Driver)."
///
/// After role selection, the user enters their shop/business name,
/// then we update the profile row (created by trigger with defaults).
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  final _shopNameController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isDarija => ref.watch(localeProvider) == 'ar';

  @override
  void dispose() {
    _shopNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (_selectedRole == null) {
      setState(() => _errorMessage = _isDarija
          ? 'اختار الدور ديالك'
          : 'Veuillez choisir votre rôle');
      return;
    }

    final shopName = _shopNameController.text.trim();
    if (shopName.isEmpty) {
      setState(() => _errorMessage = _isDarija
          ? 'دخل اسم المحل'
          : "Veuillez entrer le nom de l'activité");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(phoneAuthServiceProvider);
      final currentLang = ref.read(localeProvider);
      await authService.updateProfileAfterRoleSelection(
        role: _selectedRole!,
        shopName: shopName,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        preferredLanguage: currentLang,
      );

      // Invalidate profile provider to re-fetch
      ref.invalidate(currentProfileProvider);

      if (!mounted) return;

      // Navigate to the correct dashboard based on role
      switch (_selectedRole!) {
        case AppConstants.roleSupplier:
          context.goNamed('supplier-dashboard');
          break;
        case AppConstants.roleDriver:
          context.goNamed('driver-marketplace');
          break;
        case AppConstants.roleRetailer:
        default:
          context.goNamed('retailer-dashboard');
          break;
      }
    } catch (e) {
      if (mounted) {
        final appErr = toAppException(e);
        setState(() {
          _errorMessage = appErr.message(_isDarija);
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarija = _isDarija;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ══════════════════════════════════════════════
                // LANGUAGE TOGGLE — FR / AR (switch back to French when in Darija)
                // ══════════════════════════════════════════════
                const Center(child: LanguageTogglePill()),
                const SizedBox(height: 24),
                // ══════════════════════════════════════════════
                // HEADER
                // ══════════════════════════════════════════════
                Center(
                  child: Column(
                    children: [
                      Text(
                        isDarija ? 'مرحبا بيك!' : 'Bienvenue !',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isDarija
                            ? 'شكون نتا فالسوق؟'
                            : 'Quel est votre rôle ?',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDarija
                            ? 'Quel est votre rôle ?'
                            : 'شكون نتا فالسوق؟',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ══════════════════════════════════════════════
                // ROLE CARDS — 3 big selectable cards
                // ══════════════════════════════════════════════
                _buildRoleCard(
                  role: AppConstants.roleSupplier,
                  icon: Icons.store,
                  frTitle: 'Grossiste',
                  arTitle: 'مول السلعة',
                  frSubtitle: 'Je vends en gros aux détaillants',
                  arSubtitle: 'كنبيع بالجملة',
                  color: const Color(0xFF4F46E5),
                  bgColor: const Color(0xFFEEF2FF),
                  isDarija: isDarija,
                ),
                const SizedBox(height: 12),

                _buildRoleCard(
                  role: AppConstants.roleRetailer,
                  icon: Icons.shopping_bag,
                  frTitle: 'Détaillant',
                  arTitle: 'مول الحانوت',
                  frSubtitle: "J'achète pour revendre",
                  arSubtitle: 'كنشري باش نبيع',
                  color: AppColors.accentOrange,
                  bgColor: const Color(0xFFFFF7ED),
                  isDarija: isDarija,
                ),
                const SizedBox(height: 12),

                _buildRoleCard(
                  role: AppConstants.roleDriver,
                  icon: Icons.local_shipping,
                  frTitle: 'Livreur',
                  arTitle: 'كورتيا',
                  frSubtitle: 'Je livre les marchandises',
                  arSubtitle: 'كنوصل السلعة',
                  color: AppColors.successGreen,
                  bgColor: const Color(0xFFECFDF5),
                  isDarija: isDarija,
                ),
                const SizedBox(height: 28),

                // ══════════════════════════════════════════════
                // SHOP NAME INPUT — only shown after role selection
                // ══════════════════════════════════════════════
                if (_selectedRole != null) ...[
                  Text(
                    isDarija
                        ? 'اسم المحل / النشاط'
                        : "Nom de l'activité",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _shopNameController,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: _selectedRole == AppConstants.roleDriver
                            ? (isDarija ? 'الاسم ديالك' : 'Votre nom')
                            : (isDarija ? 'مثلا: حانوت النجاح' : 'Ex: Boutique Atlas'),
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        prefixIcon: const Icon(
                          Icons.business,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── City input ──
                  Text(
                    isDarija ? 'المدينة' : 'Ville',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _cityController,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: isDarija
                            ? 'الدار البيضاء، فاس...'
                            : 'Casablanca, Fès...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        prefixIcon: const Icon(
                          Icons.location_city,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Error message ──
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.alertRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ══════════════════════════════════════════════
                  // SUBMIT BUTTON
                  // ══════════════════════════════════════════════
                  GestureDetector(
                    onTap: _isSubmitting ? null : _submitProfile,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isSubmitting
                            ? AppColors.bgMuted
                            : AppColors.accentOrange,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isSubmitting
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
                                    isDarija ? 'بدا' : 'Commencer',
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onAccent,
                                    ),
                                  ),
                                  Text(
                                    isDarija ? 'Commencer' : 'يلاه نبداو',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      color:
                                          AppColors.onAccent.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                      ),
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

  // ════════════════════════════════════════════════════════════════════════════
  // ROLE CARD — selectable card with icon, bilingual title, subtitle
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String frTitle,
    required String arTitle,
    required String frSubtitle,
    required String arSubtitle,
    required Color color,
    required Color bgColor,
    required bool isDarija,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // ── Icon circle ──
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : AppColors.bgMuted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isDarija ? arTitle : frTitle,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDarija ? frTitle : arTitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDarija ? arSubtitle : frSubtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Selection indicator ──
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppColors.borderSubtle,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
