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
  String get deliveryOnly =>
      isDarija ? 'توصيل فقط' : 'Livraison seule';
  String get driverMarketplace =>
      isDarija ? 'سوق التوصيل' : 'Livraisons disponibles';
  String get availableJobs =>
      isDarija ? 'الخدمات المتاحة' : 'Offres de livraison';
  String get noJobsAvailable =>
      isDarija ? 'ما كاين تا خدمة دابا' : 'Aucune livraison disponible';
  String get pickupFrom => isDarija ? 'من عند' : 'Ramassage';
  String get deliverTo => isDarija ? 'ل' : 'Livraison';
  String get placeBid => isDarija ? 'قدم عرض' : 'Proposer un prix';
  String get bidSheet => isDarija ? 'ورقة العرض' : "Fiche d'offre";
  String get estimatedTime =>
      isDarija ? 'الوقت التقريبي' : 'Temps estimé';
  String get driverMessage =>
      isDarija ? 'رسالة (اختياري)' : 'Message (optionnel)';
  String get submitBid =>
      isDarija ? 'صيفط العرض' : "Envoyer l'offre";
  String get bidSubmitted =>
      isDarija ? 'العرض تصيفط!' : 'Offre envoyée !';
  String get bidAlreadyPlaced =>
      isDarija ? 'عندك عرض فهاد الخدمة' : 'Offre déjà soumise';
  String get activeTrip =>
      isDarija ? 'المسار الحالي' : 'Trajet en cours';
  String get activeTrips =>
      isDarija ? 'المسارات النشطة' : 'Trajets actifs';
  String get routeDetails =>
      isDarija ? 'تفاصيل المسار' : 'Détails du trajet';
  String get startTrip => isDarija ? 'بدا المسار' : 'Démarrer le trajet';
  String get iArrived => isDarija ? 'وصلت!' : 'Je suis arrivé !';
  String get enterPin => isDarija ? 'دخل الكود' : 'Entrer le code PIN';
  String get askRetailerPin => isDarija
      ? 'طلب الكود من مول الحانوت (4 أرقام)'
      : 'Demandez le code PIN au commerçant (4 chiffres)';
  String get wrongPin =>
      isDarija ? 'الكود غالط، عاود' : 'Code incorrect, réessayez';
  String get verifyDelivery =>
      isDarija ? 'أكد التوصيل' : 'Confirmer la livraison';
  String get deliveryCompleted =>
      isDarija ? 'التوصيل تم بنجاح!' : 'Livraison terminée !';
  String get deliveryCompletedSubtitle => isDarija
      ? 'الكارني تحدّث تلقائيا'
      : 'Le carnet a été mis à jour automatiquement';
  String get codCollect =>
      isDarija ? 'فلوس خاصك تجمع' : 'Montant à collecter (COD)';
  String get statusAssigned =>
      isDarija ? 'مخصصة ليك' : 'Assigné';
  String get bidManager =>
      isDarija ? 'عروض الكورتيات' : 'Gestion des offres';
  String get driverBids =>
      isDarija ? 'العروض' : 'Offres des livreurs';
  String get noBidsYet =>
      isDarija ? 'مازال ما جا تا عرض' : 'Aucune offre pour le moment';
  String get confirmAcceptBid =>
      isDarija ? 'قبل العرض؟' : "Accepter l'offre ?";
  String get bidAccepted =>
      isDarija ? 'العرض تقبل! PIN تولّد' : 'Offre acceptée ! PIN généré';
  String get driverAssigned =>
      isDarija ? 'الكورتيا تعيّن' : 'Livreur assigné';
  String get locationName =>
      isDarija ? 'العنوان ديالك' : 'Adresse / Emplacement';
  String get locationNameHint => isDarija
      ? 'مثلا: درب عمر، رقم 42'
      : 'ex: Derb Omar, Magasin n°42';

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
  // SUPPLIER DASHBOARD
  // ══════════════════════════════════════════════════════════════════════════
  String get supplierDashboard =>
      isDarija ? 'لوحة التحكم' : 'Tableau de bord';
  String get supplierSpace =>
      isDarija ? 'المولي' : 'Espace Grossiste';
  String get overview => isDarija ? 'الملخص' : 'Aperçu';
  String get orders => isDarija ? 'الطلبيات' : 'Commandes';
  String get clients => isDarija ? 'الزبناء' : 'Clients';
  String get pendingOrders =>
      isDarija ? 'طلبيات كتسنا' : 'En attente';
  String get activeDeliveries =>
      isDarija ? 'توصيلات نشطة' : 'Livraisons actives';
  String get totalRevenue =>
      isDarija ? 'الدخل الكلي' : 'Revenu total';
  String get outstandingDebt =>
      isDarija ? 'الديون' : 'Créances';
  String get newOrders =>
      isDarija ? 'طلبيات جديدة' : 'Nouvelles commandes';
  String get quickAccess =>
      isDarija ? 'وصول سريع' : 'Accès rapide';
  String get inventory =>
      isDarija ? 'المخزون' : 'Inventaire';
  String get verification =>
      isDarija ? 'التحقق' : 'Vérification';
  String get addProduct =>
      isDarija ? 'زيد منتوج' : 'Ajouter produit';
  String get deliveries =>
      isDarija ? 'التوصيلات' : 'Livraisons';
  String get noOrdersYet =>
      isDarija ? 'مازال ما جات تا طلبية' : 'Aucune commande';
  String get noClientsYet =>
      isDarija ? 'مازال ما عندك تا زبون' : 'Aucun client';
  String get noPendingOrders =>
      isDarija ? 'ما كاين تا طلبية جديدة ✓' : 'Aucune commande en attente ✓';
  String get confirmAction =>
      isDarija ? 'قبل' : 'Confirmer';
  String get rejectAction =>
      isDarija ? 'رفض' : 'Refuser';
  String get rejectOrderConfirm =>
      isDarija ? 'واش بصح بغيتي ترفض هاد الطلبية?' : 'Voulez-vous vraiment refuser cette commande ?';
  String get orderConfirmedMsg =>
      isDarija ? 'الطلبية تأكدات ✓' : 'Commande confirmée ✓';
  String get orderRejectedMsg =>
      isDarija ? 'الطلبية ترفضات' : 'Commande refusée';
  String get readyForPickup =>
      isDarija ? 'جاهزة للنقل' : 'Prête pour ramassage';
  String get overCreditLimitBadge =>
      isDarija ? 'فات البلافو' : 'Hors limite';
  String viewAll(int count) =>
      isDarija ? 'شوف الكل ($count)' : 'Voir tout ($count)';

  // ══════════════════════════════════════════════════════════════════════════
  // VERIFICATION DESK
  // ══════════════════════════════════════════════════════════════════════════
  String get verificationTitle =>
      isDarija ? 'التحقق من الخلصات' : 'Vérification des paiements';
  String get noPendingPayments =>
      isDarija ? 'ما كاين تا خلصة كتسنا التأكيد ✓' : 'Aucun paiement en attente ✓';
  String get allPaymentsVerified =>
      isDarija ? 'كولشي مقبول' : 'Tous les paiements sont validés';
  String get approvePayment =>
      isDarija ? 'قبل — خالصة صافية' : 'Approuver';
  String get rejectPayment =>
      isDarija ? 'رفض' : 'Rejeter';
  String get paymentApproved =>
      isDarija ? 'الخلصة تأكدات ✓ الحساب تحدث' : 'Paiement validé ✓ Solde mis à jour';
  String get paymentRejected =>
      isDarija ? 'الخلصة ترفضات' : 'Paiement rejeté';
  String get rejectReason =>
      isDarija ? 'علاش كترفض هاد الخلصة؟ (اختياري)' : 'Motif du rejet (optionnel)';

  // ══════════════════════════════════════════════════════════════════════════
  // PAYMENT DECLARATION
  // ══════════════════════════════════════════════════════════════════════════
  String get selectPaymentMethod =>
      isDarija ? 'اختار الطريقة' : 'Mode de paiement';
  String get takeReceiptPhoto =>
      isDarija ? 'صور الورقة' : 'Prendre une photo du reçu';
  String get referenceCodeLabel =>
      isDarija ? 'الرقم السري' : 'Code de transaction';
  String get referenceCodeHint =>
      isDarija ? 'الرقم لي فالورقة' : 'Réf. sur le reçu';
  String get amountPaid =>
      isDarija ? 'شحال صيفطتي' : 'Montant versé';
  String get amountRequired =>
      isDarija ? 'دخل المبلغ' : 'Montant requis';
  String get invalidAmount =>
      isDarija ? 'مبلغ غير صحيح' : 'Montant invalide';
  String get sendToSupplier =>
      isDarija ? 'صيفط لمول السلعة' : 'Envoyer au Grossiste';
  String get declarationSent =>
      isDarija ? 'تصيفطات بنجاح!' : 'Déclaration envoyée !';
  String get balanceUpdatedAfterValidation =>
      isDarija ? 'الحساب غادي يتحدث ملي المولي يأكد' : 'Le solde sera mis à jour après validation du fournisseur';
  String get notifySupplierWhatsApp =>
      isDarija ? 'صيفط للمولي فواتساب' : 'Notifier le grossiste (WhatsApp)';
  String get receiptPhotoHint =>
      isDarija ? 'خلي الرقم السري بان مزيان' : 'Assurez-vous que le numéro de réf. est visible';
  String get simulateOcr =>
      isDarija ? 'سيمولي OCR (ديمو)' : 'Simuler OCR (démo)';

  // ══════════════════════════════════════════════════════════════════════════
  // SUPPLIER — Clients (Carnet)
  // ══════════════════════════════════════════════════════════════════════════
  String get clientsCarnet => isDarija ? 'الزبناء (الكارني)' : 'Clients (Carnet)';
  String get addRetailer =>
      isDarija ? 'زيد مول حانوت' : 'Ajouter un détaillant';
  String get inviteRetailerSubtitle => isDarija
      ? 'فالإنتاج، غادي يتوصل الدتايلان بالدعوة'
      : 'En production, le détaillant recevra une invitation par WhatsApp';
  String get retailerPhone =>
      isDarija ? 'رقم الدتايلان' : 'Téléphone du détaillant';
  String get retailerAddedSuccess => isDarija
      ? 'الدعوة غادي تصيفط (ديمو)'
      : 'Invitation envoyée (démo)';

  // ══════════════════════════════════════════════════════════════════════════
  // DRIVER — WhatsApp confirmation
  // ══════════════════════════════════════════════════════════════════════════
  String get contactRetailerWhatsApp =>
      isDarija ? 'تواصل مع الدتايلان · واتساب' : 'Contacter le détaillant · WhatsApp';

  // ══════════════════════════════════════════════════════════════════════════
  // RETAILER ORDERS LIST
  // ══════════════════════════════════════════════════════════════════════════
  String get myOrders =>
      isDarija ? 'الطلبيات ديالي' : 'Mes Commandes';
  String get allFilter => isDarija ? 'الكل' : 'Tout';
  String get viewDetails =>
      isDarija ? 'شوف التفاصيل ←' : 'Voir détails →';
  String get noOrders =>
      isDarija ? 'مازال ما كاين تا طلبية' : 'Aucune commande';

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

  // ══════════════════════════════════════════════════════════════════════════
  // CART & ORDER
  // ══════════════════════════════════════════════════════════════════════════
  String get cart => isDarija ? 'لياني' : 'Panier';
  String get items => isDarija ? 'منتوجات' : 'articles';
  String get pieces => isDarija ? 'قطع' : 'pièces';
  String get clearCart => isDarija ? 'فرّغ لياني' : 'Vider le panier';
  String get clearCartConfirm => isDarija
      ? 'بصح بغيتي تفرغ لياني؟'
      : 'Voulez-vous vraiment vider le panier ?';
  String get emptyCart => isDarija ? 'لياني خاوي' : 'Panier vide';
  String get emptyCartSubtitle => isDarija
      ? 'زيد شي منتوجات من الكاطالوغ'
      : 'Ajoutez des produits depuis le catalogue';
  String get backToCatalog => isDarija ? 'رجع للكاطالوغ' : 'Retour au catalogue';
  String get orderFor => isDarija ? 'طلبية عند' : 'Commande pour';
  String get orderNotes => isDarija
      ? 'ملاحظات للمولي (اختياري)'
      : 'Notes pour le grossiste (optionnel)';
  String get orderTotal => isDarija ? 'المجموع' : 'Total commande';
  String get lineTotal => isDarija ? 'المجموع الفرعي' : 'Sous-total';
  String get orderConfirmed => isDarija ? 'الطلبية تصيفطات!' : 'Commande envoyée !';
  String get orderConfirmedSubtitle => isDarija
      ? 'المولي غادي يتوصل بالطلبية'
      : 'Votre grossiste va recevoir la commande';
  String get orderNumber => isDarija ? 'رقم الطلبية' : 'N° commande';
  String get shareOnWhatsApp => isDarija ? 'صيفط فواتساب' : 'Partager sur WhatsApp';
  String get addedToCart => isDarija ? 'تزاد فلياني' : 'Ajouté au panier';
  String get viewCart => isDarija ? 'شوف لياني' : 'Voir le panier';
  String get newOrder => isDarija ? 'طلبية جديدة' : 'Nouvelle Commande';
  String get estimatedTotal => isDarija ? 'المجموع التقريبي:' : 'Total estimé :';
  String get remainingCredit => isDarija ? 'بلافو لي باقي' : 'Crédit restant';
  String get overCreditLimit => isDarija
      ? '⚠️ هاد الطلبية غادي تفوت البلافو ديالك!'
      : '⚠️ Cette commande dépassera votre limite de crédit !';

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════════════════════
  String get phoneNumber => isDarija ? 'رقم الهاتف' : 'Numéro de téléphone';
  String get phoneHint => isDarija ? '6XXXXXXXX' : '6XXXXXXXX';
  String get sendCode => isDarija ? 'صيفط الكود' : 'Envoyer le code';
  String get loginSubtitle => isDarija
      ? 'غادي نصيفطو ليك رسالة فيها الكود'
      : 'Un code de vérification sera envoyé par SMS';
  String get loginDisclaimer => isDarija
      ? 'كتقبل الشروط ديالنا ملي كتسجل'
      : 'En continuant, vous acceptez nos conditions';

  // OTP
  String get otpTitle => isDarija ? 'دخل الكود' : 'Vérification';
  String otpSubtitle(String phone) => isDarija
      ? 'دخل الكود لي صيفطنا لـ $phone'
      : 'Entrez le code envoyé au $phone';
  String get verifyCode => isDarija ? 'تأكد' : 'Vérifier';
  String get resendCode => isDarija ? 'عاود صيفط الكود' : 'Renvoyer le code';
  String resendCountdown(int seconds) => isDarija
      ? 'عاود صيفط بعد $secondsث'
      : 'Renvoyer dans ${seconds}s';
  String get changeNumber => isDarija ? 'بدل الرقم' : 'Modifier le numéro';

  // Role Selection
  String get chooseRole => isDarija ? 'شكون نتا؟' : 'Choisissez votre rôle';
  String get chooseRoleSubtitle => isDarija
      ? 'اختار الدور ديالك باش نعرفو شنو كدير'
      : 'Sélectionnez votre profil pour commencer';
  String get roleSupplier => isDarija ? 'المولي' : 'Grossiste';
  String get roleRetailer => isDarija ? 'مول الحانوت' : 'Détaillant';
  String get roleDriver => isDarija ? 'كورتيا' : 'Livreur';
  String get roleSupplierDesc => isDarija
      ? 'كتبيع بالجملة'
      : 'Vente en gros';
  String get roleRetailerDesc => isDarija
      ? 'كتشري من عند المولي'
      : 'Achat auprès des grossistes';
  String get roleDriverDesc => isDarija
      ? 'كتوصل السلعة'
      : 'Livraison de marchandises';
  String get shopNameLabel => isDarija ? 'سمية الحانوت' : 'Nom du commerce';
  String get shopNameHint => isDarija ? 'مثلا: حانوت النجاح' : 'ex: Boutique Al Najah';
  String get cityLabel => isDarija ? 'المدينة' : 'Ville';
  String get cityHint => isDarija ? 'مثلا: الدار البيضاء' : 'ex: Casablanca';
  String get createAccount => isDarija ? 'كمل التسجيل' : 'Créer mon compte';

  // Pending Verification
  String get pendingTitle => isDarija
      ? 'الحساب كيتسنا التأكيد'
      : 'Compte en attente de vérification';
  String get pendingSubtitle => isDarija
      ? 'المولي خاصو يأكد الحساب ديالك قبل ما تقدر تشري'
      : 'Le grossiste doit valider votre compte avant de pouvoir commander';
  String get contactSupplier => isDarija
      ? 'تواصل مع المولي'
      : 'Contacter le grossiste';
  String get backToDashboard => isDarija
      ? 'رجع للصفحة الرئيسية'
      : "Retour à l'accueil";

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
