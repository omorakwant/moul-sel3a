import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/profile.dart';
import '../../../data/services/phone_auth_service.dart';
import '../../../data/services/supabase_service.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// AUTH PROVIDERS — Riverpod state management for the authentication flow.
///
/// Flow:
///   1. authStateProvider → stream of AuthState changes
///   2. currentProfileProvider → fetch profile from `public.profiles`
///   3. isProfileCompleteProvider → check if profile has real shop_name
///   4. authGuardProvider → combines session + profile to determine route
///
/// Auth guard returns one of:
///   - AuthStatus.unauthenticated → show login
///   - AuthStatus.needsOnboarding → show role selection
///   - AuthStatus.authenticated   → route to role-based dashboard
/// ══════════════════════════════════════════════════════════════════════════════

/// Auth status enum for routing decisions.
enum AuthStatus {
  /// Initial loading state
  loading,

  /// No session — user needs to log in
  unauthenticated,

  /// Has session but profile is default ("Nouveau Compte") — needs role selection
  needsOnboarding,

  /// Fully authenticated with complete profile
  authenticated,
}

/// Stream of auth state changes from Supabase.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Current user's profile (from public.profiles).
/// Refreshes when auth state changes.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  // Watch auth state to auto-refresh when user signs in/out
  final authState = ref.watch(authStateProvider);

  // If auth state is still loading, return null
  if (authState is AsyncLoading) return null;

  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return null;

  final response = await client
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();

  if (response == null) return null;
  return Profile.fromJson(response);
});

/// Whether the current user's profile has been properly set up.
/// A profile created by the trigger defaults to shop_name = "Nouveau Compte".
final isProfileCompleteProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  return profileAsync.when(
    data: (profile) {
      if (profile == null) return false;
      return profile.shopName != 'Nouveau Compte';
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Combined auth guard — determines routing based on session + profile state.
final authGuardProvider = Provider<AuthStatus>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final session = client.auth.currentSession;

  // No session → unauthenticated
  if (session == null) return AuthStatus.unauthenticated;

  // Has session → check profile completeness
  final isComplete = ref.watch(isProfileCompleteProvider);
  if (!isComplete) {
    // Profile might still be loading
    final profileAsync = ref.watch(currentProfileProvider);
    if (profileAsync is AsyncLoading) return AuthStatus.loading;
    return AuthStatus.needsOnboarding;
  }

  return AuthStatus.authenticated;
});

/// Current user's role (convenience provider).
final currentRoleProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  return profileAsync.valueOrNull?.role;
});

/// Provider to check if a retailer has an active relation with a given supplier.
/// Returns null if loading, true/false when resolved.
/// Used for the "Compte en attente" verification gate.
final hasSupplierRelationProvider =
    FutureProvider.family<bool, String>((ref, supplierId) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return false;

  final response = await client
      .from('supplier_retailer_relations')
      .select('id')
      .eq('supplier_id', supplierId)
      .eq('retailer_id', userId)
      .eq('status', 'active')
      .maybeSingle();

  return response != null;
});

/// Send OTP provider — wraps phone auth service.
/// Returns a FutureProvider so the UI can show loading/error states.
final sendOtpProvider =
    FutureProvider.family<bool, String>((ref, rawPhone) async {
  final authService = ref.watch(phoneAuthServiceProvider);
  return authService.sendOtp(rawPhone);
});

/// Locale toggle provider — allows switching between FR and AR at app level.
/// Used by the login screen's language toggle.
final localeProvider = StateProvider<String>((ref) => 'fr');

/// Derived Locale object for MaterialApp.
/// Maps the string locale code to a Flutter Locale.
final selectedLocaleProvider = Provider<Locale>((ref) {
  final code = ref.watch(localeProvider);
  if (code == 'ar') return const Locale('ar', 'MA');
  return const Locale('fr');
});
