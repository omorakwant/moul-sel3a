import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Bilingual localization helper for L'Carnet B2B.
///
/// Implements the PROJECT_CONTEXT.md spec:
///   - French: Professional structure (e.g., "Solde Actuel")
///   - Darija: Direct action/status (e.g., "وصلاتني السلعة")
///
/// Usage:
///   final l10n = AppLocalizations.of(context);
///   Text(l10n.currentDebt);  // Returns FR or Darija based on locale
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('fr'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),       // French (default)
    Locale('ar', 'MA'), // Moroccan Darija (Arabic script)
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  bool get isDarija => locale.languageCode == 'ar';

  // ══════════════════════════════════════════════════════════════════════════
  // APP
  // ══════════════════════════════════════════════════════════════════════════
  String get appTitle => isDarija ? 'لكارني B2B' : "L'Carnet B2B";

  // ══════════════════════════════════════════════════════════════════════════
  // DASHBOARD
  // ══════════════════════════════════════════════════════════════════════════
  String get currentDebt => isDarija ? 'الحساب لي عليك' : 'Solde Actuel';
  String get creditLimit => isDarija ? 'بلافو ديالك' : 'Limite de Crédit';
  String get mySuppliers => isDarija ? 'المالين السلعة ديالي' : 'Mes Grossistes';

  // ══════════════════════════════════════════════════════════════════════════
  // CATALOG
  // ══════════════════════════════════════════════════════════════════════════
  String get searchCompatibility => isDarija
      ? 'قلب بالموديل (مثلا ايفون 13)'
      : 'Filtrer par modèle (ex: iPhone 13)';
  String get newArrival => isDarija ? 'جديد' : 'Nouveauté';
  String get wholesalePrice => isDarija ? 'ثمن الجملة' : 'Prix de Gros';
  String get addToCart => isDarija ? 'زيد للياني' : 'Ajouter au Panier';

  // ══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════════════════
  String get confirmOrder =>
      isDarija ? 'كونفطرمي الطلبية' : 'Valider la Commande';
  String get confirmReceipt =>
      isDarija ? 'وصلاتني السلعة' : "J'ai reçu la marchandise";
  String get partialReceipt =>
      isDarija ? 'نقص السلعة لي ناقصة' : 'Réception Partielle';
  String get declarePayment =>
      isDarija ? 'خلصت شوية' : 'Déclarer un Paiement';
  String get uploadReceipt =>
      isDarija ? 'صور الورقة ديال كاش بلوس' : 'Photo du reçu (Wafacash/CashPlus)';
  String get callWhatsApp =>
      isDarija ? 'صيفط أوديو' : 'Contacter via WhatsApp';

  // ══════════════════════════════════════════════════════════════════════════
  // LOGISTICS
  // ══════════════════════════════════════════════════════════════════════════
  String get findDriver => isDarija ? 'قلب على كورتي' : 'Chercher un livreur';
  String get bidAmount =>
      isDarija ? 'ثمن الخدمة ديالك' : 'Votre prix de livraison';
  String get cashCollection =>
      isDarija ? 'فيها جمع الفلوس' : "Avec collecte d'argent";

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS
  // ══════════════════════════════════════════════════════════════════════════
  String get statusPending => isDarija ? 'كتوجد' : 'En préparation';
  String get statusConfirmed => isDarija ? 'تأكدات' : 'Confirmée';
  String get statusReadyForPickup => isDarija ? 'جاهزة للنقل' : 'Prête pour ramassage';
  String get statusShipped => isDarija ? 'في الطريق' : 'En route';
  String get statusDelivered => isDarija ? 'وصلات' : 'Livré';
  String get statusCancelled => isDarija ? 'ملغية' : 'Annulée';
  String get statusVerified => isDarija ? 'خالصة صافية' : 'Validé / Payé';
  String get statusRejected => isDarija ? 'مرفوضة' : 'Rejetée';

  // ══════════════════════════════════════════════════════════════════════════
  // INVENTORY ADMIN
  // ══════════════════════════════════════════════════════════════════════════
  String get bulkUpdate =>
      isDarija ? 'بدل كولشي دقة وحدة' : 'Mise à jour en masse';
  String get previewPrice =>
      isDarija ? 'شوف الثمن الجديد' : 'Aperçu du nouveau prix';

  // ══════════════════════════════════════════════════════════════════════════
  // COMMON
  // ══════════════════════════════════════════════════════════════════════════
  String get cancel => isDarija ? 'الغي' : 'Annuler';
  String get save => isDarija ? 'حفظ' : 'Enregistrer';
  String get send => isDarija ? 'صيفط' : 'Envoyer';
  String get loading => isDarija ? 'كيتحمل...' : 'Chargement...';
  String get error => isDarija ? 'مشكل' : 'Erreur';
  String get success => isDarija ? 'مزيان' : 'Succès';
  String get retry => isDarija ? 'عاود' : 'Réessayer';

  /// Format a price with DH suffix (used universally per PROJECT_CONTEXT.md)
  String formatPrice(double amount) {
    return '${amount.toStringAsFixed(2)} DH';
  }

  /// Status label resolver
  String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'ready_for_pickup':
        return statusReadyForPickup;
      case 'shipped':
        return statusShipped;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      case 'verified':
        return statusVerified;
      case 'rejected':
        return statusRejected;
      default:
        return status;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
