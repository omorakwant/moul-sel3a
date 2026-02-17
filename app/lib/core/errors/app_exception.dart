import 'package:supabase_flutter/supabase_flutter.dart';

/// Typed application exception — wraps Supabase/network errors into
/// user-friendly categories so the UI never shows raw exception text.
///
/// Usage in repositories:
///   try { ... } on PostgrestException catch (e) {
///     throw AppException.fromPostgrest(e);
///   }
///
/// Usage in UI:
///   error: (e, _) => ErrorCard(error: e is AppException ? e : AppException.unknown(e))
class AppException implements Exception {
  final ErrorType type;
  final String messageFr;
  final String messageDarija;
  final String? debugInfo; // only logged, never shown to user

  const AppException({
    required this.type,
    required this.messageFr,
    required this.messageDarija,
    this.debugInfo,
  });

  /// Get the user-facing message based on locale.
  String message(bool isDarija) => isDarija ? messageDarija : messageFr;

  // ────────────────────────────────────────────────────────────────────────
  // Factory constructors from common Supabase exception types
  // ────────────────────────────────────────────────────────────────────────

  factory AppException.fromPostgrest(PostgrestException e) {
    // RLS / permission denied
    if (e.code == '42501' || (e.message.contains('policy'))) {
      return AppException(
        type: ErrorType.permission,
        messageFr: 'Accès refusé. Vous n\'avez pas les droits nécessaires.',
        messageDarija: 'ما عندكش الصلاحية باش تدير هاد الشي',
        debugInfo: 'Postgrest ${e.code}: ${e.message}',
      );
    }
    // Unique constraint violation
    if (e.code == '23505') {
      return AppException(
        type: ErrorType.duplicate,
        messageFr: 'Cet élément existe déjà.',
        messageDarija: 'هاد الشي كاين من قبل',
        debugInfo: 'Postgrest ${e.code}: ${e.message}',
      );
    }
    // Foreign key violation
    if (e.code == '23503') {
      return AppException(
        type: ErrorType.notFound,
        messageFr: 'L\'élément référencé n\'existe pas ou a été supprimé.',
        messageDarija: 'ما لقيناش هاد الشي، يمكن تمسح',
        debugInfo: 'Postgrest ${e.code}: ${e.message}',
      );
    }
    // Not found (no rows)
    if (e.code == 'PGRST116') {
      return AppException(
        type: ErrorType.notFound,
        messageFr: 'Élément introuvable.',
        messageDarija: 'ما لقيناش هاد الشي',
        debugInfo: 'Postgrest ${e.code}: ${e.message}',
      );
    }
    // Generic DB error
    return AppException(
      type: ErrorType.server,
      messageFr: 'Erreur serveur. Réessayez dans quelques instants.',
      messageDarija: 'مشكل ف السيرفر، عاود من بعد',
      debugInfo: 'Postgrest ${e.code}: ${e.message}',
    );
  }

  factory AppException.fromAuth(AuthException e) {
    if (e.statusCode == '429' || e.message.contains('rate')) {
      return AppException(
        type: ErrorType.rateLimit,
        messageFr: 'Trop de tentatives. Attendez un moment.',
        messageDarija: 'بزاف ديال المحاولات، تسنا شوية',
        debugInfo: 'Auth: ${e.message}',
      );
    }
    if (e.message.contains('Invalid') || e.message.contains('invalid')) {
      return AppException(
        type: ErrorType.validation,
        messageFr: 'Données invalides. Vérifiez et réessayez.',
        messageDarija: 'المعلومات غالطة، صحح وعاود',
        debugInfo: 'Auth: ${e.message}',
      );
    }
    return AppException(
      type: ErrorType.auth,
      messageFr: 'Erreur d\'authentification. Reconnectez-vous.',
      messageDarija: 'مشكل ف الدخول، عاود كونيكطي',
      debugInfo: 'Auth: ${e.message}',
    );
  }

  factory AppException.fromStorage(StorageException e) {
    if (e.statusCode == '413' || e.message.contains('size')) {
      return AppException(
        type: ErrorType.validation,
        messageFr: 'Fichier trop volumineux (max 5 Mo).',
        messageDarija: 'الفيشي كبير بزاف (ماكس 5 Mo)',
        debugInfo: 'Storage: ${e.message}',
      );
    }
    return AppException(
      type: ErrorType.storage,
      messageFr: 'Erreur de téléchargement. Réessayez.',
      messageDarija: 'مشكل فالتحميل، عاود',
      debugInfo: 'Storage: ${e.message}',
    );
  }

  factory AppException.network() {
    return const AppException(
      type: ErrorType.network,
      messageFr: 'Pas de connexion Internet. Vérifiez votre réseau.',
      messageDarija: 'ما كاينش الإنترنيت، شوف الريزو ديالك',
    );
  }

  factory AppException.unknown(Object error) {
    final msg = error.toString();
    // Detect network-related errors from the exception message
    if (msg.contains('SocketException') ||
        msg.contains('HandshakeException') ||
        msg.contains('TimeoutException') ||
        msg.contains('Connection refused') ||
        msg.contains('Network is unreachable')) {
      return AppException.network();
    }
    return AppException(
      type: ErrorType.unknown,
      messageFr: 'Une erreur inattendue s\'est produite.',
      messageDarija: 'وقع شي مشكل ما كانش متوقع',
      debugInfo: msg,
    );
  }

  @override
  String toString() => 'AppException($type, debugInfo: $debugInfo)';
}

/// Error categories for UI icon/color decisions.
enum ErrorType {
  network,     // No internet
  server,      // 5xx / DB errors
  auth,        // Auth failures
  permission,  // RLS / 403
  notFound,    // 404 / empty
  duplicate,   // Unique constraint
  validation,  // Bad input
  storage,     // File upload issues
  rateLimit,   // Too many requests
  unknown,     // Catch-all
}
