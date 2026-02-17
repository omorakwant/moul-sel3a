import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';

/// Mixin for all repositories — wraps Supabase calls with typed error handling.
///
/// Usage:
///   class MyRepo with SupabaseErrorHandler { ... }
///   Future<List<Item>> getItems() => guard(() async { ... });
mixin SupabaseErrorHandler {
  /// Wrap any Supabase operation with typed error translation.
  /// Converts PostgrestException, AuthException, StorageException,
  /// and network errors into AppException.
  Future<T> guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on PostgrestException catch (e) {
      throw AppException.fromPostgrest(e);
    } on AuthException catch (e) {
      throw AppException.fromAuth(e);
    } on StorageException catch (e) {
      throw AppException.fromStorage(e);
    } on SocketException {
      throw AppException.network();
    } on AppException {
      rethrow; // Already wrapped
    } catch (e) {
      throw AppException.unknown(e);
    }
  }
}
