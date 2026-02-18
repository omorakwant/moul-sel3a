import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import 'supabase_service.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// STORAGE SERVICE — Centralised Supabase Storage upload helper.
///
/// Replaces duplicate upload logic in:
///   - supplier_add_edit_product_screen.dart
///   - supplier_inventory_providers.dart (uploadProductImageProvider)
///   - payment_declaration_screen.dart
///
/// All uploads go to the `lcarnet-assets` bucket under a user-scoped path.
/// ══════════════════════════════════════════════════════════════════════════════

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(supabaseClientProvider));
});

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  /// Upload a file to Supabase Storage and return its public URL.
  ///
  /// [file]     — the local file to upload.
  /// [folder]   — sub-folder under the user's directory (e.g. `products`, `receipts`).
  /// [userId]   — override user ID (defaults to current auth user).
  ///
  /// Storage path: `{userId}/{folder}/{timestamp}.{ext}`
  Future<String> upload(
    File file, {
    required String folder,
    String? userId,
  }) async {
    final uid = userId ?? _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    final ext = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = '$uid/$folder/$fileName';

    await _client.storage
        .from(SupabaseConstants.storageBucket)
        .upload(storagePath, file);

    return _client.storage
        .from(SupabaseConstants.storageBucket)
        .getPublicUrl(storagePath);
  }

  /// Convenience: upload a product image.
  Future<String> uploadProductImage(File file) =>
      upload(file, folder: 'products');

  /// Convenience: upload a payment receipt photo.
  Future<String> uploadReceipt(File file) =>
      upload(file, folder: 'receipts');
}
