import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Riverpod provider for the phone auth service.
final phoneAuthServiceProvider = Provider<PhoneAuthService>((ref) {
  return PhoneAuthService(ref.watch(supabaseClientProvider));
});

/// Phone Auth service wrapping Supabase Phone OTP.
///
/// Flow per PROJECT_CONTEXT.md:
///   1. User enters phone number (Morocco +212 prefix).
///   2. Supabase sends SMS OTP.
///   3. User enters 6-digit code.
///   4. On verify, if new user → SQL trigger `handle_new_user()` auto-creates
///      a profile with role from `raw_user_meta_data`.
///   5. If profile already exists → skip role selection, go to dashboard.
///
/// Morocco phone normalization:
///   06xxxxxxxx → +2126xxxxxxxx
///   07xxxxxxxx → +2127xxxxxxxx
///   +212xxxxxxx → already correct
class PhoneAuthService {
  final SupabaseClient _client;

  PhoneAuthService(this._client);

  /// Normalize a Morocco phone number to E.164 format (+212XXXXXXXXX).
  ///
  /// Handles:
  ///   - "06 12 34 56 78" → "+212612345678"
  ///   - "0612345678"     → "+212612345678"
  ///   - "+212612345678"  → "+212612345678"
  ///   - "212612345678"   → "+212612345678"
  static String normalizePhone(String input) {
    // Strip spaces, dashes, parentheses
    var phone = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Remove leading + if present (we'll add it back)
    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    // 06/07 local → 2126/2127
    if (phone.startsWith('0') && phone.length == 10) {
      phone = '212${phone.substring(1)}';
    }

    // Ensure starts with +
    return '+$phone';
  }

  /// Send OTP to a Morocco phone number.
  ///
  /// Returns `true` on success, throws on failure.
  Future<bool> sendOtp(String rawPhone) async {
    final phone = normalizePhone(rawPhone);

    await _client.auth.signInWithOtp(
      phone: phone,
    );
    return true;
  }

  /// Verify the 6-digit OTP code.
  ///
  /// On success, Supabase creates (or signs in) the user.
  /// The `handle_new_user()` trigger auto-creates a profile row
  /// with `role` and `shop_name` from `raw_user_meta_data`.
  ///
  /// [role] and [shopName] are passed via `data` only for new sign-ups
  /// (when the user hasn't selected a role yet, these will be null
  /// and the trigger falls back to 'retailer' / 'Nouveau Compte').
  Future<AuthResponse> verifyOtp({
    required String rawPhone,
    required String otpCode,
  }) async {
    final phone = normalizePhone(rawPhone);

    final response = await _client.auth.verifyOTP(
      phone: phone,
      token: otpCode,
      type: OtpType.sms,
    );
    return response;
  }

  /// Update user metadata (role + shop_name) for a first-time user.
  ///
  /// Called after role selection to write the role into the profile.
  /// Since the trigger already created a default profile, we update it.
  Future<void> updateProfileAfterRoleSelection({
    required String role,
    required String shopName,
    String? city,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Update the profile row in `public.profiles`
    await _client.from('profiles').update({
      'role': role,
      'shop_name': shopName,
      if (city != null) 'city': city,
    }).eq('id', userId);
  }

  /// Check if a profile already exists for the current user.
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  /// Check if profile has been properly set up (has a real shop_name, not default).
  Future<bool> isProfileComplete() async {
    final profile = await getProfile();
    if (profile == null) return false;

    final shopName = profile['shop_name'] as String?;
    return shopName != null && shopName != 'Nouveau Compte';
  }

  /// Sign out.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Current session (for checking auth state).
  Session? get currentSession => _client.auth.currentSession;

  /// Current user.
  User? get currentUser => _client.auth.currentUser;

  /// Auth state stream.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}
