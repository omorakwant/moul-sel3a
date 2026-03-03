import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/mock_data.dart';
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
///
/// Test mode: when [testModeEnabledProvider] is true, login is bypassed and
/// the app uses a fake retailer profile so you can test the UI without SMS.
/// ══════════════════════════════════════════════════════════════════════════════

/// When true, skip login and use a fake retailer profile (for testing the app).
final testModeEnabledProvider = StateProvider<bool>((ref) => false);

/// On web: which role to simulate for the prototype (retailer | supplier | driver).
/// Used by [currentProfileProvider] to return the matching mock profile.
final prototypeRoleProvider = StateProvider<String>((ref) => 'retailer');

/// Fake profile used when [testModeEnabledProvider] is true.
Profile get _kTestProfile => Profile(
      id: '00000000-0000-0000-0000-000000000001',
      shopName: 'Démo',
      role: 'retailer',
      preferredLanguage: 'fr',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

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
/// When [testModeEnabledProvider] is true or on web (prototype), returns mock profile.
/// On web, [prototypeRoleProvider] selects retailer, supplier, or driver.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  if (kIsWeb) {
    final role = ref.watch(prototypeRoleProvider);
    return mockProfiles.firstWhere(
      (p) => p.role == role,
      orElse: () => mockProfiles.firstWhere((p) => p.role == 'retailer'),
    );
  }
  if (ref.watch(testModeEnabledProvider)) return _kTestProfile;

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
  if (kIsWeb) return true;
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
/// On web (deployed prototype), skip login and go straight to retailer dashboard.
final authGuardProvider = Provider<AuthStatus>((ref) {
  if (kIsWeb) return AuthStatus.authenticated;
  if (ref.watch(testModeEnabledProvider)) return AuthStatus.authenticated;

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
/// Defaults to 'fr'. On app start, the splash screen reads the profile's
/// `preferred_language` and overrides this value.
final localeProvider = StateProvider<String>((ref) => 'fr');

/// Derived Locale object for MaterialApp.
/// Maps the string locale code to a Flutter Locale.
final selectedLocaleProvider = Provider<Locale>((ref) {
  final code = ref.watch(localeProvider);
  if (code == 'ar') return const Locale('ar', 'MA');
  return const Locale('fr');
});

/// Call this after toggling [localeProvider] to persist to Supabase.
/// Fire-and-forget — UI stays responsive, DB update happens in background.
final persistLocaleProvider =
    FutureProvider.family<void, String>((ref, langCode) async {
  final authService = ref.read(phoneAuthServiceProvider);
  await authService.updatePreferredLanguage(langCode);
  // Invalidate profile so it picks up the new preferred_language
  ref.invalidate(currentProfileProvider);
});
