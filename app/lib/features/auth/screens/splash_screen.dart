import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

/// Splash Screen — checks auth state and routes accordingly.
///
/// Flow:
///   1. Show logo + loading indicator
///   2. Check Supabase session
///   3. If no session → /login
///   4. If session but incomplete profile → /role-select
///   5. If session + complete profile → role-based dashboard
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay slightly to let providers initialize
    Future.delayed(const Duration(milliseconds: 800), _checkAuth);
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    final authStatus = ref.read(authGuardProvider);

    switch (authStatus) {
      case AuthStatus.loading:
        // Still loading — wait and retry
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _checkAuth();
        break;

      case AuthStatus.unauthenticated:
        if (mounted) context.goNamed('login');
        break;

      case AuthStatus.needsOnboarding:
        if (mounted) {
          // Restore saved language even for incomplete profiles
          final profile = ref.read(currentProfileProvider).valueOrNull;
          if (profile != null) {
            ref.read(localeProvider.notifier).state =
                profile.preferredLanguage;
          }
          context.goNamed('role-selection');
        }
        break;

      case AuthStatus.authenticated:
        if (mounted) {
          // ── Restore saved language preference ──
          final profile = ref.read(currentProfileProvider).valueOrNull;
          if (profile != null) {
            ref.read(localeProvider.notifier).state =
                profile.preferredLanguage;
          }

          final role = ref.read(currentRoleProvider) ?? 'retailer';
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
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ──
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'ل',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "L'Carnet B2B",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'لكارني B2B',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 40),

            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
