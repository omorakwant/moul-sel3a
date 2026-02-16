import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../services/supabase_service.dart';
import '../../core/constants/supabase_constants.dart';

/// Repository for Profile CRUD operations.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  /// Fetch the current user's profile.
  Future<Profile?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  /// Fetch a profile by ID.
  Future<Profile?> getById(String id) async {
    final response = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  /// Update a profile.
  Future<void> update(Profile profile) async {
    await _client
        .from(SupabaseConstants.profilesTable)
        .update(profile.toJson())
        .eq('id', profile.id);
  }
}
