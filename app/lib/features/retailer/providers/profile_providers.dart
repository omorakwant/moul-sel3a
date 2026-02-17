import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/profile.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../../auth/providers/auth_providers.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// RETAILER PROFILE PROVIDERS — edit shop name, city, location, language, logout
/// ══════════════════════════════════════════════════════════════════════════════

/// Update profile fields and persist to Supabase.
///
/// Usage: `ref.read(updateProfileProvider)(profile.copyWith(shopName: '...'))`
final updateProfileProvider = Provider<Future<void> Function(Profile)>((ref) {
  return (Profile updatedProfile) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.update(updatedProfile);
    // Refresh auth profile cache so the whole app sees the new data
    ref.invalidate(currentProfileProvider);
  };
});

/// Sign out the current user and clear session.
///
/// Usage: `await ref.read(signOutProvider)()`
final signOutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final client = ref.read(supabaseClientProvider);
    await client.auth.signOut();
    // Auth state stream will trigger route redirect automatically via authGuardProvider
  };
});
