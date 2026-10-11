"use client";

import { useState, useMemo, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import {
  ArrowLeft,
  BookOpen,
  Store,
  Truck,
  CheckCircle2,
  Clock,
  ShieldCheck,
  Send,
  Plus,
  RefreshCw,
  ExternalLink,
  ChevronRight,
  TrendingDown,
  Phone,
  Layers,
  Search,
  Mic,
  ShoppingCart,
  Trash2,
  X,
  Sliders,
  DollarSign,
  AlertCircle,
  FileText,
  UserCheck,
  Package,
  MapPin,
  Check,
  Globe,
  WifiOff,
} from "lucide-react";

// ── Types ──
type RoleType = "retailer" | "supplier" | "driver";
type RetailerTab = "ledger" | "catalog" | "cart" | "orders" | "profile";
type SupplierTab = "dashboard" | "inventory" | "clients" | "verifications" | "bids" | "profile";
type DriverTab = "active" | "marketplace" | "profile";
type LangType = "fr" | "ar";

interface CartItem {
  id: string;
  name: string;
  nameAr?: string;
  brand: string;
  quantity: number;
  priceTiers: Record<string, number>;
}

interface OrderItem {
  name: string;
  nameAr?: string;
  ordered: number;
  received: number;
  price: number;
}

interface Order {
  id: string;
  date: string;
  dateAr: string;
  total: number;
  status: string;
  driverName: string;
  driverNameAr: string;
  pin: string;
  items: OrderItem[];
}

// ── Translations Dictionary (French & Moroccan Darija) ──
const t: Record<LangType, Record<string, string>> = {
  fr: {
    backToSite: "Retour au site",
    versionBadge: "Live Prototype v1.0",
    testRoleLabel: "Tester un rôle :",
    roleRetailer: "Détaillant (Hanout)",
    roleRetailerShort: "Hanout",
    roleSupplier: "Fournisseur (Grossiste)",
    roleSupplierShort: "Grossiste",
    roleDriver: "Transporteur (Kourtia)",
    roleDriverShort: "Kourtia",
    langToggleTitle: "Passer en Darija / العربية",
    langButtonText: "🇲🇦 الدارجة (AR)",
    offlineBannerText: "Mode Hors Ligne Simulé (Les actions sont mises en file d'attente locale Hive)",
    offlineDisable: "Désactiver",

    // Retailer Screen
    retailerStatus: "Détaillant connecté",
    retailerName: "Hanout Moulay — Rabat",
    hanoutName: "Hanout Moulay — Rabat",
    retailerAddress: "Souk Al Had • +212 6 61 00 00 01",
    hanoutAddress: "Souk Al Had • +212 6 61 00 00 01",
    carnetBalance: "Solde Carnet (Rolling Debt)",
    activeDebt: "Dette active",
    creditLimitPrefix: "Plafond autorisé :",
    declarePaymentBtn: "Déclarer un versement",
    orderBtn: "+ Commander",
    partnerSuppliers: "Fournisseurs partenaires",
    supplierProName: "Accessoires Pro Casablanca",
    supplierProAddress: "Derb Omar • +212 5 22 00 00 00",
    viewCatalogBtn: "Voir catalogue",
    ledgerHistory: "Historique du Carnet (Derniers mouvements)",
    carnetHistory: "Historique du Carnet (Derniers mouvements)",
    orderItemLabel: "Commande CMD-2026-84",
    orderItemSub: "10 févr. • Kourtia Hassan",
    paymentWafacashLabel: "Versement Wafacash",
    paymentWafacashSub: "5 févr. • Réf: WF-20250205",

    // Catalog
    searchPlaceholder: "Rechercher écouteurs, coques, câbles...",
    voiceListening: "🎤 Écoute en cours (Darija / Français)... Parlez maintenant",
    allModelsOption: "📱 Tous les modèles (Compatibilité)",
    allBrandsPill: "Toutes",
    inStock: "En stock",
    tiersNotice: "Paliers appliqués automatiquement",
    add10pcs: "+ Ajouter 10 pcs",
    tier1: "1 - 9 pcs",
    tier2: "10 - 49 pcs",
    tier3: "50+ pcs",

    // Cart
    cartTitle: "Panier en cours (Paliers calculés au volume)",
    cartEmpty: "Votre panier est vide. Visitez le catalogue pour ajouter des accessoires.",
    unitActiveTier: "DH / unité (Palier actif)",
    tierActiveUnit: "DH / unité (Palier actif)",
    subtotalArticles: "Sous-total articles :",
    kourtiaDeliveryFee: "Estimation Kourtia (Livraison) :",
    totalAddedCarnet: "Total ajouté au Carnet :",
    confirmOrderAction: "Valider la Commande (Ajouter au Carnet)",
    checkoutBtn: "Valider la Commande (Ajouter au Carnet)",

    // Orders
    ordersTitle: "Suivi des commandes & Réception",
    inTransitBadge: "Chauffeur en route",
    deliveredBadge: "Livrée & Validée",
    partialBadge: "Réception partielle",
    totalLabel: "Total :",
    driverLabel: "Livreur :",
    validateHandshakePinBtn: "Valider PIN Handshake",
    partialReceiptBtn: "Réception partielle",

    // Retailer Profile
    profileHanoutTitle: "Profil Hanout",
    profileHanoutSub: "Souk Al Had, Rabat • Téléphonie & Accessoires",
    creditLimitMetric: "Plafond Crédit Autorisé",
    activeDebtMetric: "Dette Tournante Active",
    prefTitle: "Préférences & Synchronisation",
    appLangLabel: "Langue de l'application",
    appLangSub: "Darija Marocaine ou Français",
    offlineSimulatorLabel: "Simulateur Mode Hors-Ligne",
    offlineSimulatorSub: "File d'attente locale Hive / SQLite",
    offlineActive: "Actif",
    offlineDisabled: "Désactivé",
    dbBackendLabel: "Base de Données Backend",
    supabaseStatus: "● Supabase PostgreSQL Connecté",
    onlineBadge: "En Ligne",

    // Retailer Navigation
    navCarnet: "Le Carnet",
    navCatalog: "Catalogue",
    navCart: "Panier",
    navOrders: "Commandes",
    navProfile: "Profil",

    // Supplier Screen
    supplierBrand: "Accessoires Pro",
    supplierAddress: "Derb Omar, Entrepôt n°12",
    navDashboard: "Tableau de Bord",
    navInventory: "Inventaire & Paliers",
    navClients: "Clients (Carnet)",
    navVerifications: "Vérification Paiements",
    navBids: "Appels d'offres Kourtia",
    navSupplierProfile: "Profil Entrepôt",
    totalReceivables: "Créances totales",
    partnerHanoutsCount: "14 Hanouts partenaires",
    warehouseOverview: "Vue d'ensemble du dépôt",
    warehouseFlow: "Flux temps réel Derb Omar • Casablanca",
    ordersToday: "Commandes du jour",
    ordersShippedTrend: "↑ +4 expédiées",
    pendingVerifCount: "En attente de vérification",
    pendingVerifSub: "Versements Wafacash/CashPlus",
    couriersInTransit: "Chauffeurs en route",
    couriersInTransitSub: "Casa, Rabat, Fès",
    bulkPriceQuickBtn: "⚡ Ajustement global des prix (+% ou DH)",
    newProductQuickBtn: "+ Nouveau produit",
    inventoryTitle: "Inventaire & Paliers de gros",
    inventoryActiveCount: "références actives",
    bulkPriceActionBtn: "Ajuster les prix en masse",
    addProductActionBtn: "+ Ajouter",
    colProduct: "Désignation",
    colStock: "Stock",
    colT1: "1-9 pcs",
    colT2: "10-49 pcs",
    colT3: "50+ pcs",
    colActions: "Actions",
    editBtn: "Modifier",
    clientsTitle: "Clients & Carnet de Crédit",
    clientsSub: "Suivi des dettes rolling par hanout",
    addRetailerActionBtn: "+ Ajouter un détaillant",
    debtCurrent: "Dette en cours :",
    whatsappReminderBtn: "Relance WhatsApp",
    verificationsTitle: "Vérification des Règlements",
    verificationsSub: "Preuves de paiement déclarées par les commerçants",
    noPendingVerif: "Aucun versement en attente de vérification.",
    methodLabel: "Méthode :",
    refLabel: "Réf :",
    approvePaymentBtn: "✓ Valider le versement (Déduire de la dette)",
    rejectPaymentBtn: "Rejeter",
    bidsTitle: "Appels d'offres Transporteurs (Bids)",
    bidsSub: "Offres soumises par les livreurs indépendants",
    tripLabel: "Trajet :",
    estimatedTimeLabel: "Délai estimé :",
    acceptBidBtn: "Accepter l'offre & Générer le PIN de livraison",
    profileWarehouseTitle: "Profil & Paramètres de l'Entrepôt",
    profileWarehouseSub: "Gestion du compte grossiste Derb Omar",
    companyLabel: "Raison Sociale :",
    companyVal: "Accessoires Pro SARL",
    geoZoneLabel: "Zone Géographique :",
    geoZoneVal: "Derb Omar, Entrepôt n°12, Casablanca",
    taxIdLabel: "Identifiant Fiscal / RC :",
    taxIdVal: "RC Casa 491823 • IF 482910",
    whatsappLineLabel: "Ligne WhatsApp Commandes :",
    creditPolicyTitle: "Politique de Crédit & Carnet B2B",
    creditPolicyDesc: "Les plafonds de crédit sont assignés individuellement par détaillant affilié. Les encaissements Wafacash et CashPlus débloquent automatiquement le disponible après validation au guichet.",

    // Driver Screen
    driverPartner: "Livreur partenaire (Kourtia)",
    driverName: "Kourtia Hassan",
    driverVehicleSub: "Casablanca–Rabat • Moto / Triporteur",
    inTourBadge: "En tournée",
    activeTripLabel: "Course en cours • CMD-2026-84",
    activeTripRoute: "Derb Omar ➔ Souk Al Had, Rabat",
    activeTripDest: "Destinataire : Hanout Moulay (24 colis d'accessoires)",
    pinToShow: "Code PIN à montrer au commerçant",
    pinHint: "Le commerçant saisit ce PIN sur son app pour déclencher la confirmation physique.",
    driverRewardLabel: "Rémunération transport :",
    callHanoutBtn: "📞 Appeler Hanout",
    collectCashBtn: "Encaisser 85 DH",
    cashCollectedBtn: "✓ Frais encaissés",
    marketplaceTitle: "Bourse des courses (Missions ouvertes)",
    yourRatePlaceholder: "Votre tarif (DH)",
    proposeBidBtn: "Proposer mon tarif",
    bidSubmittedSuccess: "✓ Offre soumise",
    completedTrips: "Courses Terminées",
    earningsDeposited: "Gains Déposés",
    vehicleLogistics: "Véhicule & Logistique",
    vehicleDesc: "Triporteur & Moto 150cc • Assurance marchandises valide • Flotte logistique Derb Omar.",
    navActiveTrip: "Course (PIN)",
    navMarketplace: "Bourse",
    navDriverProfile: "Profil",

    // Modals
    modalPaymentTitle: "Déclarer un versement au grossiste",
    transferMethodLabel: "Méthode de transfert :",
    amountMADLabel: "Montant versé (MAD) :",
    receiptRefLabel: "Référence du reçu :",
    ocrSimulateBtn: "📸 Simuler OCR (Scanner le reçu démo)",
    confirmAndNotifyWhatsApp: "Confirmer & Notifier WhatsApp",
    modalPartialTitle: "Réception Partielle (Screen 10)",
    modalPartialBon: "Bon de commande",
    modalPartialHint: "Ajustez les quantités reçues en cas de casse ou d'articles manquants. La dette au Carnet sera recalculée :",
    orderedLabel: "Commandé :",
    qtyAdjustedAlert: "⚠️ Quantité ajustée :",
    initialTotalOrder: "Total initial de la commande :",
    newTotalAfterAudit: "Nouveau total après inventaire :",
    deductionNoticePrefix: "📉 Déduction immédiate de",
    deductionNoticeSuffix: "sur votre Carnet",
    confirmAdjustmentAction: "Confirmer l'Ajustement & Mettre à jour le Carnet",
    modalHandshakeTitle: "Validation PIN Handshake",
    modalHandshakeSub: "Certifier la remise physique",
    modalHandshakeHint: "Le livreur vous présente son code PIN de tournée. Saisissez-le pour certifier la réception physique en direct :",
    demoPinCode: "Code démo du chauffeur :",
    verifyHandshakeBtn: "Vérifier le Handshake",
    handshakeSuccessTitle: "Réception Confirmée !",
    handshakeSuccessSub: "Présence physique certifiée par code PIN",
    deliverySlipLabel: "Bon de Livraison :",
    articlesVerifiedLabel: "Articles vérifiés :",
    anomaliesLabel: "Anomalies signalées :",
    zeroAnomalies: "0 anomalie",
    amountValidatedLabel: "Montant validé :",
    partiesPresent: "Parties Présentes",
    driverParty: "🚚 Livreur :",
    retailerParty: "🏪 Commerçant : Hanout Moulay (Rabat)",
    shareWhatsAppBtn: "Partager sur WhatsApp",
    closeAndFinishBtn: "Fermer & Terminer",
    modalBulkTitle: "Ajustement Global des Prix (Grossiste)",
    modalBulkSub: "Applique une variation à l'ensemble du catalogue",
    percentageMode: "Pourcentage (%)",
    fixedMode: "Montant fixe (DH)",
    adjustmentValueLabel: "Valeur de l'ajustement",
    livePreviewLabel: "Aperçu direct (Paliers 10-49 pcs) :",
    applyToCatalogBtn: "Appliquer à tout le catalogue",
    modalAddRetailerTitle: "Ajouter un Détaillant au Carnet",
    retailerPhoneLabel: "Numéro de téléphone du commerçant :",
    initialCreditLimitLabel: "Plafond de crédit initial (MAD) :",
    sendWhatsAppInviteBtn: "Envoyer l'invitation WhatsApp",
    modalAddProductTitle: "Ajouter un Nouveau Produit",
    productNameLabel: "Nom du produit :",
    saveToInventoryBtn: "Enregistrer dans l'inventaire",
  },
  ar: {
    backToSite: "الرجوع للموقع",
    versionBadge: "نسخة تجريبية حية v1.0",
    testRoleLabel: "جرّب حساب :",
    roleRetailer: "مول الحانوت (دّيطاي)",
    roleRetailerShort: "الحانوت",
    roleSupplier: "مول السلعة (المولي)",
    roleSupplierShort: "المولي",
    roleDriver: "الكورتي (النقال)",
    roleDriverShort: "الكورتي",
    langToggleTitle: "Passer en Français",
    langButtonText: "🇫🇷 Français (FR)",
    offlineBannerText: "وضع بلا كونيكسيون مفعل (العمليات كيتسجلو فالميموار المحلية Hive)",
    offlineDisable: "حبس",

    // Retailer Screen
    retailerStatus: "الحانوت النشط",
    retailerName: "حانوت مولاي — الرباط",
    hanoutName: "حانوت مولاي — الرباط",
    retailerAddress: "سوق الأحد • +212 6 61 00 00 01",
    hanoutAddress: "سوق الأحد • +212 6 61 00 00 01",
    carnetBalance: "كارني السلعة (الكريدي)",
    activeDebt: "واجب الأداء",
    creditLimitPrefix: "بلافو مسموح به :",
    declarePaymentBtn: "خلصت شوية (واتساب)",
    orderBtn: "+ طلب سلعة",
    partnerSuppliers: "المالين السلعة ديالي",
    supplierProName: "أكسسوار برو كازا",
    supplierProAddress: "درب عمر • +212 5 22 00 00 00",
    viewCatalogBtn: "شوف الكاطالوج",
    ledgerHistory: "تاريخ الكارني (آخر الحركات)",
    carnetHistory: "تاريخ الكارني (آخر الحركات)",
    orderItemLabel: "طلبية CMD-2026-84",
    orderItemSub: "10 فبرا • كورتي حسن",
    paymentWafacashLabel: "خلصة وفاكاش",
    paymentWafacashSub: "5 فبرا • توصيل: WF-20250205",

    // Catalog
    searchPlaceholder: "قلب على ليزيكوتور، بوشيطات، كابلات...",
    voiceListening: "🎤 كنسمعو دابا (بالدارجة المغربية)... هضر دابا",
    allModelsOption: "📱 كاع الموديلات (التوافق)",
    allBrandsPill: "الكل",
    inStock: "كاين فالمخزن",
    tiersNotice: "الثمن كينقص تلقائياً مع الكمية",
    add10pcs: "+ زيد 10 قطع",
    tier1: "1 - 9 قطع",
    tier2: "10 - 49 قطعة",
    tier3: "50+ قطعة",

    // Cart
    cartTitle: "لياني دالسلعة (حساب الجملة تلقائي)",
    cartEmpty: "لياني خاوي. دور ف الكاطالوج باش تزيد السلعة.",
    unitActiveTier: "درهم / حبة (بالية نشطة)",
    tierActiveUnit: "درهم / حبة (بالية نشطة)",
    subtotalArticles: "مجموع السلعة :",
    kourtiaDeliveryFee: "تقدير التوصيل (الكورتي) :",
    totalAddedCarnet: "المجموع لي كيتزاد فالكارني :",
    confirmOrderAction: "كونفرمي الطلبية (تسجيل فالكارني)",
    checkoutBtn: "كونفرمي الطلبية (تسجيل فالكارني)",

    // Orders
    ordersTitle: "تتبع الطلبيات والاستلام",
    inTransitBadge: "الكورتي فالطريق",
    deliveredBadge: "وصلات ومأكدة",
    partialBadge: "استلام جزئي",
    totalLabel: "المجموع :",
    driverLabel: "الكورتي :",
    validateHandshakePinBtn: "أكد كود الاستلام (PIN)",
    partialReceiptBtn: "استلام جزئي (نقص التالف)",

    // Retailer Profile
    profileHanoutTitle: "بروفيل مول الحانوت",
    profileHanoutSub: "سوق الأحد، الرباط • تيليفونات وأكسسوارات",
    creditLimitMetric: "بلافو مسموح به",
    activeDebtMetric: "الحساب لي عليك دابا",
    prefTitle: "الإعدادات والتزامن",
    appLangLabel: "لغة التطبيق",
    appLangSub: "الدارجة المغربية أو الفرنسية",
    offlineSimulatorLabel: "وضع بلا كونيكسيون (أوفلاين)",
    offlineSimulatorSub: "الحفظ فالميموار المحلية Hive / SQLite",
    offlineActive: "مفعل",
    offlineDisabled: "معطل",
    dbBackendLabel: "قاعدة بيانات سوبابيز",
    supabaseStatus: "● متصل بـ Supabase PostgreSQL",
    onlineBadge: "أونلاين",

    // Retailer Navigation
    navCarnet: "الكارني",
    navCatalog: "الكاطالوج",
    navCart: "لياني",
    navOrders: "الطلبيات",
    navProfile: "حسابي",

    // Supplier Screen
    supplierBrand: "أكسسوار برو",
    supplierAddress: "درب عمر، مستودع رقم 12",
    navDashboard: "لوحة التحكم",
    navInventory: "المخزون والأثمنة",
    navClients: "الزبناء (الكارني)",
    navVerifications: "التحقق من الخلصات",
    navBids: "عروض الكورتيات",
    navSupplierProfile: "معلومات المخزن",
    totalReceivables: "مجموع الكريديات (الديون)",
    partnerHanoutsCount: "14 حانوت شريك",
    warehouseOverview: "نظرة عامة على المخزن",
    warehouseFlow: "حركة السلعة مباشرة • درب عمر، كازا",
    ordersToday: "طلبيات اليوم",
    ordersShippedTrend: "↑ +4 تصيفطو",
    pendingVerifCount: "خلصات كتسنا التحقق",
    pendingVerifSub: "خلصات وفاكاش وكاش بلوس",
    couriersInTransit: "كورتيات فالطريق",
    couriersInTransitSub: "كازا، الرباط، فاس",
    bulkPriceQuickBtn: "⚡ تبديل الأثمنة بالجملة (+% أو درهم)",
    newProductQuickBtn: "+ منتوج جديد",
    inventoryTitle: "المخزون وأثمنة الجملة",
    inventoryActiveCount: "منتوج نشط",
    bulkPriceActionBtn: "بدل الأثمنة دقة وحدة",
    addProductActionBtn: "+ زيد منتوج",
    colProduct: "المنتوج",
    colStock: "المخزون",
    colT1: "1-9 قطع",
    colT2: "10-49 قطعة",
    colT3: "50+ قطعة",
    colActions: "إجراءات",
    editBtn: "بدل",
    clientsTitle: "الزبناء وكارني الكريدي",
    clientsSub: "تتبع الكريديات لكل حانوت",
    addRetailerActionBtn: "+ زيد مول الحانوت",
    debtCurrent: "الكريدي الحالي :",
    whatsappReminderBtn: "تذكير بالواتساب",
    verificationsTitle: "التحقق من الخلصات",
    verificationsSub: "تواصيل دالخلصة لي صيفطو موالين الحوانت",
    noPendingVerif: "ما كاين تا خلصة كتسنا التحقق دابا.",
    methodLabel: "الطريقة :",
    refLabel: "الرقم :",
    approvePaymentBtn: "✓ قبل الخلصة (نقص من الكريدي)",
    rejectPaymentBtn: "رفض",
    bidsTitle: "عروض الكورتيات (Bids)",
    bidsSub: "الأثمنة لي مقترحين الكورتيات المستقلين",
    tripLabel: "المسار :",
    estimatedTimeLabel: "الوقت التقريبي :",
    acceptBidBtn: "قبل العرض وولّد كود PIN",
    profileWarehouseTitle: "معلومات المخزن وإعداداته",
    profileWarehouseSub: "إدارة حساب المولي بدرب عمر",
    companyLabel: "اسم الشركة :",
    companyVal: "أكسسوار برو ش.م.م",
    geoZoneLabel: "الموقع الجغرافي :",
    geoZoneVal: "درب عمر، مستودع رقم 12، كازا",
    taxIdLabel: "السجل التجاري والضريبة :",
    taxIdVal: "RC Casa 491823 • IF 482910",
    whatsappLineLabel: "نمرة الواتساب للطلبيات :",
    creditPolicyTitle: "سياسة الكريدي والكارني B2B",
    creditPolicyDesc: "البلافو كيتحدد لكل حانوت بوحدو. الخلصات ديال وفاكاش وكاش بلوس كتنقص الكريدي مباشرة بعد التأكيد.",

    // Driver Screen
    driverPartner: "كورتي شريك (نقال)",
    driverName: "كورتي حسن",
    driverVehicleSub: "كازا–الرباط • موطور / تريبورتور",
    inTourBadge: "فالطريق دابا",
    activeTripLabel: "الخدمة الحالية • CMD-2026-84",
    activeTripRoute: "درب عمر ➔ سوق الأحد، الرباط",
    activeTripDest: "المستلم : حانوت مولاي (24 كرتونة دالسلعة)",
    pinToShow: "كود PIN لي تورّي لمول الحانوت",
    pinHint: "مول الحانوت كيدخل هاد الكود فتطبيقه باش يتأكد الاستلام.",
    driverRewardLabel: "أجرة النقل ديالك :",
    callHanoutBtn: "📞 عيّط لمول الحانوت",
    collectCashBtn: "جمع 85 درهم",
    cashCollectedBtn: "✓ الفلوس تجمعو",
    marketplaceTitle: "سوق التوصيل (الخدمات المتاحة)",
    yourRatePlaceholder: "الثمن ديالك (درهم)",
    proposeBidBtn: "صيفط الثمن ديالي",
    bidSubmittedSuccess: "✓ العرض تصيفط",
    completedTrips: "الخدمات المكتملة",
    earningsDeposited: "الأرباح لي شديتي",
    vehicleLogistics: "المركبة واللوجستيك",
    vehicleDesc: "تريبورتور وموطور 150cc • تأمين السلعة ساري • أسطول درب عمر المعتمد.",
    navActiveTrip: "الخدمة (PIN)",
    navMarketplace: "سوق الخدمات",
    navDriverProfile: "حسابي",

    // Modals
    modalPaymentTitle: "صرح بخلصة للمولي",
    transferMethodLabel: "طريقة التحويل :",
    amountMADLabel: "المبلغ لي خلصتي (درهم) :",
    receiptRefLabel: "رقم الورقة / التوصيل :",
    ocrSimulateBtn: "📸 صور التوصيل وسكانيه (سيمولاسيون)",
    confirmAndNotifyWhatsApp: "أكد وصيفط مساج فواتساب",
    modalPartialTitle: "استلام جزئي (نقص التالف)",
    modalPartialBon: "توصيل الطلبية",
    modalPartialHint: "نقص السلعة لي فيها عيب ولا ناقصة باش الكارني ينقص تلقائياً :",
    orderedLabel: "الكمية المطلوبة :",
    qtyAdjustedAlert: "⚠️ الكمية المعدلة :",
    initialTotalOrder: "المجموع الأولي للطلبية :",
    newTotalAfterAudit: "المجموع الجديد بعد المراقبة :",
    deductionNoticePrefix: "📉 غادي ينقص",
    deductionNoticeSuffix: "من الكارني ديالك دابا",
    confirmAdjustmentAction: "أكد الاستلام وحيّن الكارني",
    modalHandshakeTitle: "تأكيد كود الاستلام (PIN)",
    modalHandshakeSub: "تأكيد الاستلام الفعلي",
    modalHandshakeHint: "الكورتي عندو كود فالتيليفون، دخلو هنا باش تأكد الاستلام الفعلي :",
    demoPinCode: "الكود التجريبي ديال الكورتي :",
    verifyHandshakeBtn: "تحقق من الكود",
    handshakeSuccessTitle: "تم تأكيد الاستلام بنجاح!",
    handshakeSuccessSub: "السلعة وصلات والحساب تقيد فالكارني",
    deliverySlipLabel: "توصيل الاستلام :",
    articlesVerifiedLabel: "السلعة المراقبة :",
    anomaliesLabel: "العيوب المسجلة :",
    zeroAnomalies: "0 عيب",
    amountValidatedLabel: "المبلغ المقيد فالكارني :",
    partiesPresent: "الأطراف الحاضرة",
    driverParty: "🚚 الكورتي :",
    retailerParty: "🏪 مول الحانوت : حانوت مولاي (الرباط)",
    shareWhatsAppBtn: "بارطاجي فواتساب",
    closeAndFinishBtn: "سد وخروج",
    modalBulkTitle: "تبديل الأثمنة بالجملة (المولي)",
    modalBulkSub: "كيطبق التغيير على الكاطالوج كامل دقة وحدة",
    percentageMode: "نسبة مئوية (%)",
    fixedMode: "مبلغ درهم (DH)",
    adjustmentValueLabel: "قيمة التغيير",
    livePreviewLabel: "نظرة مباشرة على الأثمنة (بالية 10-49 قطعة) :",
    applyToCatalogBtn: "طبق على الكاطالوج كامل",
    modalAddRetailerTitle: "زيد مول الحانوت للكارني",
    retailerPhoneLabel: "نمرة التيليفون ديال مول الحانوت :",
    initialCreditLimitLabel: "البلافو الأولي دالكريدي (درهم) :",
    sendWhatsAppInviteBtn: "صيفط دعوة بالواتساب",
    modalAddProductTitle: "زيد منتوج جديد",
    productNameLabel: "اسم المنتوج :",
    saveToInventoryBtn: "سجل فالمخزن",
  },
};

export function PrototypeApp() {
  const searchParams = useSearchParams();
  const initialRole = (searchParams.get("role")?.toLowerCase() as RoleType) || "retailer";
  const [currentRole, setCurrentRole] = useState<RoleType>(
    ["retailer", "supplier", "driver"].includes(initialRole) ? initialRole : "retailer"
  );
  
  // URL lang or default to French
  const urlLang = searchParams.get("lang")?.toLowerCase() || searchParams.get("locale")?.toLowerCase();
  const [lang, setLang] = useState<LangType>(urlLang === "ar" ? "ar" : "fr");
  const [offlineSimulated, setOfflineSimulated] = useState(false);

  const cur: Record<string, string> = t[lang];

  // ── Retailer State ──
  const [retailerTab, setRetailerTab] = useState<RetailerTab>("ledger");
  const [selectedBrand, setSelectedBrand] = useState("Toutes");
  const [selectedModel, setSelectedModel] = useState("Tous les modèles");
  const [searchQuery, setSearchQuery] = useState("");
  const [isVoiceListening, setIsVoiceListening] = useState(false);
  const [currentBalance, setCurrentBalance] = useState(4250.75);
  const [creditLimit] = useState(15000.0);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [paymentAmount, setPaymentAmount] = useState("1200");
  const [paymentMethod, setPaymentMethod] = useState("wafacash");
  const [paymentRef, setPaymentRef] = useState("WF-2026-9814");
  const [paymentSuccessToast, setPaymentSuccessToast] = useState(false);

  // Cart State
  const [cart, setCart] = useState<CartItem[]>([
    {
      id: "prod-001",
      name: "Coque Silicone iPhone 13/14",
      nameAr: "بوشيطة سيليكون ايفون 13/14",
      brand: "Generic",
      quantity: 10,
      priceTiers: { "1": 15.0, "10": 12.0, "50": 10.0 },
    },
    {
      id: "prod-002",
      name: "Verre Trempé Samsung A54 (9H)",
      nameAr: "زجاج واقي سامسونغ A54 (9H)",
      brand: "GlassPro",
      quantity: 20,
      priceTiers: { "1": 25.0, "10": 20.0, "50": 16.0 },
    },
  ]);

  // Orders State
  const [orders, setOrders] = useState<Order[]>([
    {
      id: "CMD-2026-84",
      date: "Aujourd'hui, 09:30",
      dateAr: "اليوم، 09:30",
      total: 1850.0,
      status: "in_transit",
      driverName: "Kourtia Hassan (+212 6 98 00 00 01)",
      driverNameAr: "كورتي حسن (+212 6 98 00 00 01)",
      pin: "4829",
      items: [
        { name: "Coque Silicone iPhone 13/14", nameAr: "بوشيطة سيليكون ايفون 13/14", ordered: 20, received: 20, price: 12.0 },
        { name: "Chargeur Rapide USB-C 20W", nameAr: "شارجور سريع تايب-سي 20W", ordered: 15, received: 15, price: 38.0 },
      ],
    },
    {
      id: "CMD-2026-72",
      date: "Hier, 16:15",
      dateAr: "البارح، 16:15",
      total: 2900.75,
      status: "delivered",
      driverName: "Livreur Omar",
      driverNameAr: "عمر كورتي",
      pin: "1192",
      items: [
        { name: "Écouteurs Bluetooth TWS", nameAr: "ليزيكوتور بلوتوث TWS", ordered: 25, received: 25, price: 72.0 },
        { name: "Câble Data USB-C vers Lightning", nameAr: "كابل داتا تايب-سي لايتنينغ", ordered: 40, received: 40, price: 18.0 },
      ],
    },
  ]);

  // Partial Receipt Modal State
  const [selectedOrderForReceipt, setSelectedOrderForReceipt] = useState<any | null>(null);
  const [receivedQtys, setReceivedQtys] = useState<Record<string, number>>({});
  const [handshakePinInput, setHandshakePinInput] = useState("");
  const [handshakeModalOrder, setHandshakeModalOrder] = useState<any | null>(null);
  const [handshakeSuccess, setHandshakeSuccess] = useState(false);

  // ── Supplier State ──
  const [supplierTab, setSupplierTab] = useState<SupplierTab>("dashboard");
  const [showBulkPriceModal, setShowBulkPriceModal] = useState(false);
  const [bulkAdjustmentType, setBulkAdjustmentType] = useState<"percentage" | "fixed">("percentage");
  const [bulkAdjustmentValue, setBulkAdjustmentValue] = useState<number>(10);
  const [showAddProductModal, setShowAddProductModal] = useState(false);
  const [showAddRetailerModal, setShowAddRetailerModal] = useState(false);
  const [newRetailerPhone, setNewRetailerPhone] = useState("+212 6 ");
  const [newRetailerLimit, setNewRetailerLimit] = useState("10000");

  const [products, setProducts] = useState([
    {
      id: "prod-001",
      name: "Coque Silicone iPhone 13/14",
      nameAr: "بوشيطة سيليكون ايفون 13/14",
      brand: "Generic",
      stock: 200,
      t1: 15.0,
      t2: 12.0,
      t3: 10.0,
      status: "Actif",
      compatibility: ["iPhone 13", "iPhone 14"],
    },
    {
      id: "prod-002",
      name: "Verre Trempé Samsung A54 (9H)",
      nameAr: "زجاج واقي سامسونغ A54 (9H)",
      brand: "GlassPro",
      stock: 150,
      t1: 25.0,
      t2: 20.0,
      t3: 16.0,
      status: "Actif",
      compatibility: ["Samsung A54", "Samsung A34"],
    },
    {
      id: "prod-003",
      name: "Chargeur Rapide USB-C 20W",
      nameAr: "شارجور سريع تايب-سي 20 واط",
      brand: "PowerMax",
      stock: 80,
      t1: 45.0,
      t2: 38.0,
      t3: 32.0,
      status: "Actif",
      compatibility: ["iPhone 13", "iPhone 14", "Samsung A54"],
    },
    {
      id: "prod-004",
      name: "Câble Data USB-C vers Lightning",
      nameAr: "كابل داتا تايب-سي لايتنينغ",
      brand: "CablePlus",
      stock: 300,
      t1: 22.0,
      t2: 18.0,
      t3: 14.0,
      status: "Actif",
      compatibility: ["iPhone 11", "iPhone 12", "iPhone 13", "iPhone 14"],
    },
    {
      id: "prod-005",
      name: "Écouteurs Bluetooth TWS",
      nameAr: "ليزيكوتور بلوتوث TWS",
      brand: "SoundBox",
      stock: 60,
      t1: 85.0,
      t2: 72.0,
      t3: 60.0,
      status: "Actif",
      compatibility: ["Tous les modèles"],
    },
  ]);

  const [clients, setClients] = useState([
    { id: "c1", name: "Hanout Moulay", nameAr: "حانوت مولاي", city: "Rabat (Souk Al Had)", cityAr: "الرباط (سوق الأحد)", phone: "+212 6 61 00 00 01", balance: 4250.75, limit: 15000 },
    { id: "c2", name: "Téléphonie Fès", nameAr: "تيليفونات فاس", city: "Fès (Médina)", cityAr: "فاس (المدينة)", phone: "+212 6 61 00 00 02", balance: 1200.0, limit: 8000 },
    { id: "c3", name: "Hanout Bab Marrakech", nameAr: "حانوت باب مراكش", city: "Casablanca", cityAr: "الدار البيضاء", phone: "+212 6 61 00 00 03", balance: 8450.0, limit: 20000 },
    { id: "c4", name: "SmartPhone Tanger", nameAr: "سمارتفون طنجة", city: "Tanger (Boulevard)", cityAr: "طنجة (البولفار)", phone: "+212 6 61 00 00 04", balance: 0.0, limit: 12000 },
  ]);

  const [pendingVerifications, setPendingVerifications] = useState([
    {
      id: "pv-001",
      client: "Hanout Moulay",
      clientAr: "حانوت مولاي",
      method: "Wafacash",
      ref: "WF-2026-9814",
      amount: 1200.0,
      date: "Aujourd'hui, 11:20",
      dateAr: "اليوم، 11:20",
    },
    {
      id: "pv-002",
      client: "Téléphonie Fès",
      clientAr: "تيليفونات فاس",
      method: "CashPlus",
      ref: "CP-2026-4412",
      amount: 500.0,
      date: "Hier, 18:45",
      dateAr: "البارح، 18:45",
    },
  ]);

  const [deliveryBids, setDeliveryBids] = useState([
    { id: "bid-1", driver: "Kourtia Hassan", driverAr: "كورتي حسن", phone: "+212 6 98 00 00 01", amount: 85, time: "2 heures", timeAr: "ساعتين", mission: "Derb Omar ➔ Souk Al Had, Rabat", missionAr: "درب عمر ➔ سوق الأحد، الرباط", status: "pending" },
    { id: "bid-2", driver: "Livreur Omar", driverAr: "عمر كورتي", phone: "+212 6 98 00 00 02", amount: 95, time: "3 heures", timeAr: "3 سوايع", mission: "Derb Omar ➔ Souk Al Had, Rabat", missionAr: "درب عمر ➔ سوق الأحد، الرباط", status: "pending" },
  ]);

  // ── Driver State ──
  const [driverTab, setDriverTab] = useState<DriverTab>("active");
  const [driverCodCollected, setDriverCodCollected] = useState(false);
  const [driverOpenJobs, setDriverOpenJobs] = useState([
    { id: "job-1", from: "Garage Allal, Casa", to: "Médina, Fès", fromAr: "كراج علال، كازا", toAr: "المدينة القديمة، فاس", packages: "3 cartons (Écrans)", packagesAr: "3 كراطن (إكرانات)", estFee: 140 },
    { id: "job-2", from: "Derb Ghallef, Casa", to: "Océan, Rabat", fromAr: "درب غلف، كازا", toAr: "المحيط، الرباط", packages: "1 carton (Chargeurs)", packagesAr: "1 كرطونة (شارجورات)", estFee: 75 },
    { id: "job-3", from: "Derb Omar, Casa", to: "Gueliz, Marrakech", fromAr: "درب عمر، كازا", toAr: "كيليز، مراكش", packages: "4 cartons", packagesAr: "4 كراطن", estFee: 180 },
  ]);
  const [driverBidInput, setDriverBidInput] = useState<Record<string, string>>({});
  const [driverBidSuccess, setDriverBidSuccess] = useState<string | null>(null);

  // ── Helper: Calculate Cart Price ──
  const getItemUnitPrice = (item: CartItem) => {
    if (item.quantity >= 50 && item.priceTiers["50"]) return item.priceTiers["50"];
    if (item.quantity >= 10 && item.priceTiers["10"]) return item.priceTiers["10"];
    return item.priceTiers["1"] || 0;
  };

  const cartTotal = useMemo(() => {
    return cart.reduce((sum, item) => sum + getItemUnitPrice(item) * item.quantity, 0);
  }, [cart]);

  // ── Filtered Catalog ──
  const filteredProducts = useMemo(() => {
    return products.filter((p) => {
      const matchBrand = selectedBrand === "Toutes" || selectedBrand === "الكل" || p.brand === selectedBrand;
      const matchModel = selectedModel === "Tous les modèles" || selectedModel === "📱 كاع الموديلات (التوافق)" || p.compatibility.includes(selectedModel) || p.compatibility.includes("Tous les modèles");
      const matchSearch =
        searchQuery === "" ||
        p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (p.nameAr && p.nameAr.includes(searchQuery)) ||
        p.brand.toLowerCase().includes(searchQuery.toLowerCase());
      return matchBrand && matchModel && matchSearch;
    });
  }, [products, selectedBrand, selectedModel, searchQuery]);

  return (
    <div
      dir={lang === "ar" ? "rtl" : "ltr"}
      className={`flex min-h-screen flex-col bg-black text-white selection:bg-[#FF6B00] selection:text-black ${
        lang === "ar" ? "font-sans font-medium" : "font-sans"
      }`}
    >
      {/* ── Top Bar ── */}
      <header className="sticky top-0 z-50 flex h-14 shrink-0 items-center justify-between border-b border-white/10 bg-black/95 px-3 sm:px-6 backdrop-blur-md">
        <div className="flex items-center gap-3">
          <Link
            href="/"
            className="flex items-center gap-1.5 rounded-lg border border-white/15 bg-white/[0.04] px-2.5 py-1.5 text-xs font-semibold text-white/90 transition hover:border-[#FF6B00]/60 hover:text-[#FF6B00]"
          >
            <ArrowLeft className={`h-3.5 w-3.5 ${lang === "ar" ? "rotate-180" : ""}`} />
            <span className="hidden sm:inline">{cur.backToSite}</span>
          </Link>

          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#FF6B00] text-xs font-black text-black shadow-[0_0_16px_rgba(255,107,0,0.5)]">
              ل
            </div>
            <span className="text-sm font-bold tracking-tight">
              {lang === "ar" ? "لكارني " : "L'Carnet "}
              <span className="text-[#FF6B00]">B2B</span>
              <span className="mx-2 hidden rounded-full border border-white/15 bg-white/5 px-2 py-0.5 text-[10px] font-medium text-white/60 md:inline">
                {cur.versionBadge}
              </span>
            </span>
          </div>
        </div>

        {/* ── Role Selector & Language Toggle ── */}
        <div className="flex items-center gap-1 sm:gap-2">
          <span className="mx-1 hidden text-xs font-medium text-white/45 lg:inline">
            {cur.testRoleLabel}
          </span>
          <button
            onClick={() => setCurrentRole("retailer")}
            className={`flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-bold transition ${
              currentRole === "retailer"
                ? "bg-[#FF6B00] text-black shadow-[0_0_16px_rgba(255,107,0,0.4)]"
                : "border border-white/10 bg-white/[0.03] text-white/70 hover:border-white/20 hover:text-white"
            }`}
          >
            <BookOpen className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">{cur.roleRetailer}</span>
            <span className="sm:hidden">{cur.roleRetailerShort}</span>
          </button>

          <button
            onClick={() => setCurrentRole("supplier")}
            className={`flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-bold transition ${
              currentRole === "supplier"
                ? "bg-[#FF6B00] text-black shadow-[0_0_16px_rgba(255,107,0,0.4)]"
                : "border border-white/10 bg-white/[0.03] text-white/70 hover:border-white/20 hover:text-white"
            }`}
          >
            <Store className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">{cur.roleSupplier}</span>
            <span className="sm:hidden">{cur.roleSupplierShort}</span>
          </button>

          <button
            onClick={() => setCurrentRole("driver")}
            className={`flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-bold transition ${
              currentRole === "driver"
                ? "bg-[#FF6B00] text-black shadow-[0_0_16px_rgba(255,107,0,0.4)]"
                : "border border-white/10 bg-white/[0.03] text-white/70 hover:border-white/20 hover:text-white"
            }`}
          >
            <Truck className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">{cur.roleDriver}</span>
            <span className="sm:hidden">{cur.roleDriverShort}</span>
          </button>

          {/* Lang Toggle — switches cleanly between FR & AR (Darija) */}
          <button
            onClick={() => setLang(lang === "fr" ? "ar" : "fr")}
            className={`mx-1 flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs font-black transition ${
              lang === "ar"
                ? "border-[#FF6B00] bg-[#FF6B00] text-black shadow-[0_0_12px_rgba(255,107,0,0.5)]"
                : "border-white/20 bg-white/10 text-white hover:border-[#FF6B00]"
            }`}
            title={cur.langToggleTitle}
          >
            <Globe className="h-3.5 w-3.5" />
            <span>{cur.langButtonText}</span>
          </button>
        </div>
      </header>

      {/* ── Offline Banner (Simulated) ── */}
      {offlineSimulated && (
        <div className="bg-amber-500/20 border-b border-amber-500/40 px-4 py-1.5 text-center text-xs font-bold text-amber-300 flex items-center justify-center gap-2">
          <WifiOff className="h-3.5 w-3.5" />
          <span>{cur.offlineBannerText}</span>
          <button
            onClick={() => setOfflineSimulated(false)}
            className="underline mx-2 hover:text-white"
          >
            {cur.offlineDisable}
          </button>
        </div>
      )}

      {/* ── Workspace ── */}
      <main className="flex-1 bg-[#121110] p-2 sm:p-6 flex flex-col items-center justify-start">
        {/* ══════════════════════════════════════════════════════════════════════
            1. RETAILER FLOW (HANOUT MOULAY) — 430px Mobile Frame
           ══════════════════════════════════════════════════════════════════════ */}
        {currentRole === "retailer" && (
          <div className="w-full max-w-[430px] rounded-3xl border border-white/15 bg-[#1C1917] p-4 shadow-2xl flex flex-col min-h-[720px]">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <div>
                <p className="text-[11px] font-medium text-white/50">{cur.retailerStatus}</p>
                <h2
                  onClick={() => setOfflineSimulated(!offlineSimulated)}
                  className="text-base font-extrabold text-white cursor-pointer select-none"
                  title="Cliquez pour simuler le mode hors ligne"
                >
                  {cur.hanoutName}
                </h2>
                <p className="text-[10px] text-white/40">{cur.hanoutAddress}</p>
              </div>

              {/* Cart Button */}
              <button
                onClick={() => setRetailerTab("cart")}
                className="relative rounded-xl border border-white/15 bg-white/5 p-2 text-white hover:bg-white/10"
              >
                <ShoppingCart className="h-4 w-4" />
                {cart.length > 0 && (
                  <span className="absolute -top-1.5 -right-1.5 flex h-4 w-4 items-center justify-center rounded-full bg-[#FF6B00] text-[9px] font-black text-black">
                    {cart.length}
                  </span>
                )}
              </button>
            </div>

            {/* TAB CONTENT */}
            <div className="flex-1 py-3 overflow-y-auto">
              {/* TAB 1: LEDGER (CARNET & BALANCE) */}
              {retailerTab === "ledger" && (
                <div className="space-y-4">
                  {/* Balance Card */}
                  <div className="rounded-2xl border border-[#FF6B00]/40 bg-gradient-to-br from-[#FF6B00]/20 via-black to-black p-4">
                    <div className="flex items-center justify-between">
                      <span className="text-[11px] font-black uppercase tracking-wider text-[#FF6B00]">
                        {cur.carnetBalance}
                      </span>
                      <span className="rounded bg-red-500/20 px-2 py-0.5 text-[10px] font-bold text-red-400">
                        {cur.activeDebt}
                      </span>
                    </div>

                    <div className="mt-2 flex items-baseline gap-1.5">
                      <span className="text-3xl font-black text-white">
                        {currentBalance.toLocaleString("fr-FR", { minimumFractionDigits: 2 })}
                      </span>
                      <span className="text-sm font-bold text-[#FF6B00]">MAD</span>
                    </div>

                    {/* Progress Bar */}
                    <div className="mt-3">
                      <div className="flex justify-between text-[10px] text-white/60 mb-1">
                        <span>{cur.creditLimitPrefix} {creditLimit.toLocaleString()} DH</span>
                        <span>{Math.round((currentBalance / creditLimit) * 100)}%</span>
                      </div>
                      <div className="h-1.5 w-full rounded-full bg-white/10 overflow-hidden">
                        <div
                          className="h-full bg-gradient-to-r from-emerald-500 to-[#FF6B00]"
                          style={{ width: `${(currentBalance / creditLimit) * 100}%` }}
                        />
                      </div>
                    </div>

                    {/* Quick Action Buttons */}
                    <div className="mt-4 flex gap-2">
                      <button
                        onClick={() => setShowPaymentModal(true)}
                        className="flex-1 rounded-xl bg-[#FF6B00] py-2 text-xs font-bold text-black transition hover:bg-[#ff8533]"
                      >
                        {cur.declarePaymentBtn}
                      </button>
                      <button
                        onClick={() => setRetailerTab("catalog")}
                        className="rounded-xl border border-white/20 bg-white/10 px-3 py-2 text-xs font-bold text-white hover:bg-white/20"
                      >
                        {cur.orderBtn}
                      </button>
                    </div>
                  </div>

                  {/* Supplier Card */}
                  <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5">
                    <p className="text-[11px] font-bold text-white/50 uppercase tracking-wider mb-2">
                      {cur.partnerSuppliers}
                    </p>
                    <div className="rounded-xl border border-white/5 bg-white/[0.02] p-3">
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-bold text-sm text-white">{cur.supplierProName}</p>
                          <p className="text-[11px] text-white/50">{cur.supplierProAddress}</p>
                        </div>
                        <span className="text-xs font-extrabold text-[#FF6B00]">
                          {currentBalance.toFixed(2)} DH
                        </span>
                      </div>
                      <div className="mt-3 flex gap-2">
                        <button
                          onClick={() => setRetailerTab("catalog")}
                          className="flex-1 rounded-lg bg-white/10 py-1.5 text-xs font-bold text-white hover:bg-white/20"
                        >
                          {cur.viewCatalogBtn}
                        </button>
                        <a
                          href="https://wa.me/212522000000"
                          target="_blank"
                          rel="noopener noreferrer"
                          className="flex items-center justify-center rounded-lg border border-white/15 bg-white/5 px-3 text-white hover:bg-white/10"
                        >
                          <Phone className="h-3.5 w-3.5" />
                        </a>
                      </div>
                    </div>
                  </div>

                  {/* Recent Ledger Entries */}
                  <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5">
                    <p className="text-[11px] font-bold text-white/50 uppercase tracking-wider mb-2">
                      {cur.carnetHistory}
                    </p>
                    <div className="space-y-2 text-xs">
                      <div className="flex justify-between p-2 rounded-lg bg-white/[0.02] border border-white/5">
                        <div>
                          <p className="font-bold text-white">{cur.orderItemLabel}</p>
                          <p className="text-[10px] text-white/40">{cur.orderItemSub}</p>
                        </div>
                        <span className="font-bold text-red-400">+1 850,00 DH</span>
                      </div>
                      <div className="flex justify-between p-2 rounded-lg bg-white/[0.02] border border-white/5">
                        <div>
                          <p className="font-bold text-white">{cur.paymentWafacashLabel}</p>
                          <p className="text-[10px] text-white/40">{cur.paymentWafacashSub}</p>
                        </div>
                        <span className="font-bold text-emerald-400">-500,00 DH</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* TAB 2: CATALOG */}
              {retailerTab === "catalog" && (
                <div className="space-y-3">
                  {/* Search Bar + Voice */}
                  <div className="relative flex items-center gap-1.5">
                    <div className="relative flex-1">
                      <Search className={`absolute top-2.5 h-3.5 w-3.5 text-white/40 ${lang === "ar" ? "right-3" : "left-3"}`} />
                      <input
                        type="text"
                        placeholder={cur.searchPlaceholder}
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className={`h-9 w-full rounded-xl border border-white/15 bg-white/5 text-xs text-white placeholder:text-white/40 outline-none focus:border-[#FF6B00] ${
                          lang === "ar" ? "pr-8 pl-3" : "pl-8 pr-3"
                        }`}
                      />
                    </div>
                    <button
                      onClick={() => {
                        setIsVoiceListening(true);
                        setTimeout(() => {
                          setSearchQuery(lang === "ar" ? "بوشيطة سيليكون" : "Écran OLED iPhone");
                          setIsVoiceListening(false);
                        }, 1200);
                      }}
                      className={`flex h-9 w-9 items-center justify-center rounded-xl border transition ${
                        isVoiceListening
                          ? "border-[#FF6B00] bg-[#FF6B00] text-black animate-pulse"
                          : "border-white/15 bg-white/5 text-white/70 hover:text-white"
                      }`}
                      title={cur.voiceListening}
                    >
                      <Mic className="h-4 w-4" />
                    </button>
                  </div>
                  {isVoiceListening && (
                    <p className="text-[10px] text-center text-[#FF6B00] font-bold animate-pulse">
                      {cur.voiceListening}
                    </p>
                  )}

                  {/* Compatibility Model Filter */}
                  <div>
                    <select
                      value={selectedModel}
                      onChange={(e) => setSelectedModel(e.target.value)}
                      className="h-8 w-full rounded-lg border border-white/15 bg-black px-2 text-xs font-semibold text-white/80 outline-none"
                    >
                      <option value="Tous les modèles">{cur.allModelsOption}</option>
                      <option value="iPhone 13">iPhone 13</option>
                      <option value="iPhone 14">iPhone 14</option>
                      <option value="Samsung A54">Samsung A54</option>
                    </select>
                  </div>

                  {/* Brand Filter Pills */}
                  <div className="flex gap-1.5 overflow-x-auto pb-1 text-[11px] scrollbar-none">
                    {["Toutes", "Generic", "GlassPro", "PowerMax", "CablePlus", "SoundBox"].map((b) => (
                      <button
                        key={b}
                        onClick={() => setSelectedBrand(b === "Toutes" && lang === "ar" ? "الكل" : b)}
                        className={`rounded-lg px-2.5 py-1 font-bold whitespace-nowrap transition ${
                          selectedBrand === b || (b === "Toutes" && selectedBrand === "الكل")
                            ? "bg-[#FF6B00] text-black"
                            : "bg-white/5 text-white/60 hover:text-white"
                        }`}
                      >
                        {b === "Toutes" && lang === "ar" ? "الكل" : b}
                      </button>
                    ))}
                  </div>

                  {/* Products Grid */}
                  <div className="space-y-2.5">
                    {filteredProducts.map((p) => (
                      <div
                        key={p.id}
                        className="rounded-2xl border border-white/10 bg-black/40 p-3 hover:border-white/20 transition"
                      >
                        <div className="flex justify-between items-start">
                          <div>
                            <span className="text-[9px] font-bold uppercase tracking-wider text-[#FF6B00]">
                              {p.brand}
                            </span>
                            <h4 className="font-bold text-xs text-white">
                              {lang === "ar" && p.nameAr ? p.nameAr : p.name}
                            </h4>
                          </div>
                          <span className="rounded bg-emerald-500/10 px-1.5 py-0.5 text-[9px] font-bold text-emerald-400">
                            {cur.inStock} ({p.stock})
                          </span>
                        </div>

                        {/* Tiered Price Table */}
                        <div className="mt-2 grid grid-cols-3 gap-1 rounded-xl bg-white/[0.03] p-1.5 text-center text-[10px]">
                          <div>
                            <p className="text-white/40">{cur.tier1}</p>
                            <p className="font-extrabold text-white">{p.t1} DH</p>
                          </div>
                          <div className="border-x border-white/5">
                            <p className="text-white/40">{cur.tier2}</p>
                            <p className="font-extrabold text-emerald-400">{p.t2} DH</p>
                          </div>
                          <div>
                            <p className="text-white/40">{cur.tier3}</p>
                            <p className="font-extrabold text-[#FF6B00]">{p.t3} DH</p>
                          </div>
                        </div>

                        {/* Add to Cart Action */}
                        <div className="mt-3 flex items-center justify-between">
                          <span className="text-[10px] text-white/40">
                            {cur.tiersNotice}
                          </span>
                          <button
                            onClick={() => {
                              setCart((prev) => {
                                const exists = prev.find((i) => i.id === p.id);
                                if (exists) {
                                  return prev.map((i) => (i.id === p.id ? { ...i, quantity: i.quantity + 10 } : i));
                                }
                                return [
                                  ...prev,
                                  {
                                    id: p.id,
                                    name: p.name,
                                    nameAr: p.nameAr,
                                    brand: p.brand,
                                    quantity: 10,
                                    priceTiers: { "1": p.t1, "10": p.t2, "50": p.t3 },
                                  },
                                ];
                              });
                            }}
                            className="rounded-xl bg-[#FF6B00] px-3 py-1.5 text-xs font-bold text-black transition hover:bg-[#ff8533]"
                          >
                            {cur.add10pcs}
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* TAB 3: CART & CHECKOUT */}
              {retailerTab === "cart" && (
                <div className="space-y-4">
                  <h3 className="text-xs font-bold text-white/50 uppercase tracking-wider">
                    {cur.cartTitle}
                  </h3>

                  {cart.length === 0 ? (
                    <div className="text-center py-12 text-white/40 text-xs">
                      {cur.cartEmpty}
                    </div>
                  ) : (
                    <div className="space-y-3">
                      {cart.map((item) => {
                        const unitPrice = getItemUnitPrice(item);
                        return (
                          <div
                            key={item.id}
                            className="rounded-2xl border border-white/10 bg-black/40 p-3 text-xs"
                          >
                            <div className="flex justify-between items-start">
                              <div>
                                <p className="font-bold text-white">
                                  {lang === "ar" && item.nameAr ? item.nameAr : item.name}
                                </p>
                                <p className="text-[10px] text-[#FF6B00] font-semibold">
                                  {unitPrice} {cur.unitActiveTier}
                                </p>
                              </div>
                              <button
                                onClick={() => setCart((prev) => prev.filter((i) => i.id !== item.id))}
                                className="text-white/40 hover:text-red-400"
                              >
                                <Trash2 className="h-3.5 w-3.5" />
                              </button>
                            </div>

                            <div className="mt-3 flex items-center justify-between">
                              <div className="flex items-center gap-2">
                                <button
                                  onClick={() =>
                                    setCart((prev) =>
                                      prev.map((i) =>
                                        i.id === item.id ? { ...i, quantity: Math.max(1, i.quantity - 5) } : i
                                      )
                                    )
                                  }
                                  className="h-7 w-7 rounded-lg bg-white/10 font-bold hover:bg-white/20"
                                >
                                  -
                                </button>
                                <span className="w-8 text-center font-bold text-sm">{item.quantity}</span>
                                <button
                                  onClick={() =>
                                    setCart((prev) =>
                                      prev.map((i) =>
                                        i.id === item.id ? { ...i, quantity: i.quantity + 5 } : i
                                      )
                                    )
                                  }
                                  className="h-7 w-7 rounded-lg bg-white/10 font-bold hover:bg-white/20"
                                >
                                  +
                                </button>
                              </div>

                              <span className="font-black text-sm text-white">
                                {(unitPrice * item.quantity).toFixed(2)} DH
                              </span>
                            </div>
                          </div>
                        );
                      })}

                      {/* Order Summary */}
                      <div className="rounded-2xl border border-white/15 bg-white/[0.02] p-3 text-xs space-y-1.5">
                        <div className="flex justify-between text-white/60">
                          <span>{cur.subtotalArticles}</span>
                          <span>{cartTotal.toFixed(2)} DH</span>
                        </div>
                        <div className="flex justify-between text-white/60">
                          <span>{cur.kourtiaDeliveryFee}</span>
                          <span>40.00 DH</span>
                        </div>
                        <div className="flex justify-between border-t border-white/10 pt-2 text-sm font-black text-white">
                          <span>{cur.totalAddedCarnet}</span>
                          <span className="text-[#FF6B00]">{(cartTotal + 40).toFixed(2)} DH</span>
                        </div>
                      </div>

                      <button
                        onClick={() => {
                          const newOrder: Order = {
                            id: `CMD-2026-${Math.floor(100 + Math.random() * 900)}`,
                            date: "À l'instant",
                            dateAr: "دابا",
                            total: cartTotal + 40,
                            status: "in_transit",
                            driverName: "Kourtia Hassan (+212 6 98 00 00 01)",
                            driverNameAr: "كورتي حسن (+212 6 98 00 00 01)",
                            pin: "7492",
                            items: cart.map((c) => ({
                              name: c.name,
                              nameAr: c.nameAr || c.name,
                              ordered: c.quantity,
                              received: c.quantity,
                              price: getItemUnitPrice(c),
                            })),
                          };
                          setOrders([newOrder, ...orders]);
                          setCurrentBalance((prev) => prev + cartTotal + 40);
                          setCart([]);
                          setRetailerTab("orders");
                        }}
                        className="w-full rounded-2xl bg-[#FF6B00] py-3 text-sm font-black text-black shadow-[0_0_24px_rgba(255,107,0,0.4)] transition hover:bg-[#ff8533]"
                      >
                        {cur.checkoutBtn}
                      </button>
                    </div>
                  )}
                </div>
              )}

              {/* TAB 4: ORDERS */}
              {retailerTab === "orders" && (
                <div className="space-y-3">
                  <h3 className="text-xs font-bold text-white/50 uppercase tracking-wider">
                    {cur.ordersTitle}
                  </h3>

                  {orders.map((ord) => (
                    <div
                      key={ord.id}
                      className="rounded-2xl border border-white/10 bg-black/40 p-3.5 space-y-2 text-xs"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-extrabold text-sm text-white">{ord.id}</p>
                          <p className="text-[10px] text-white/40">
                            {lang === "ar" && ord.dateAr ? ord.dateAr : ord.date}
                          </p>
                        </div>
                        <span
                          className={`rounded-full px-2 py-0.5 text-[9px] font-black uppercase ${
                            ord.status === "in_transit"
                              ? "bg-amber-500/20 text-amber-300"
                              : ord.status === "delivered"
                              ? "bg-emerald-500/20 text-emerald-400"
                              : "bg-blue-500/20 text-blue-400"
                          }`}
                        >
                          {ord.status === "in_transit"
                            ? cur.inTransitBadge
                            : ord.status === "delivered"
                            ? cur.deliveredBadge
                            : cur.partialBadge}
                        </span>
                      </div>

                      <p className="text-[11px] text-white/70">
                        {cur.totalLabel} <span className="font-bold text-[#FF6B00]">{ord.total.toFixed(2)} DH</span> • {cur.driverLabel} {lang === "ar" && ord.driverNameAr ? ord.driverNameAr : ord.driverName}
                      </p>

                      {/* Order Actions */}
                      <div className="flex gap-2 pt-1 border-t border-white/5">
                        {ord.status === "in_transit" && (
                          <button
                            onClick={() => {
                              setHandshakeModalOrder(ord);
                              setHandshakeSuccess(false);
                            }}
                            className="flex-1 rounded-xl bg-[#FF6B00] py-2 text-xs font-bold text-black"
                          >
                            {cur.validateHandshakePinBtn}
                          </button>
                        )}
                        <button
                          onClick={() => {
                            setSelectedOrderForReceipt(ord);
                            const q: Record<string, number> = {};
                            ord.items.forEach((it: any) => (q[it.name] = it.received));
                            setReceivedQtys(q);
                          }}
                          className="rounded-xl border border-white/15 bg-white/5 px-3 py-2 text-xs font-bold text-white hover:bg-white/10"
                        >
                          {cur.partialReceiptBtn}
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* TAB 5: PROFILE & PARAMÈTRES */}
              {retailerTab === "profile" && (
                <div className="space-y-4 text-xs">
                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3">
                    <div className="flex items-center gap-3">
                      <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#FF6B00]/20 text-[#FF6B00] font-black text-lg">
                        HM
                      </div>
                      <div>
                        <h4 className="font-extrabold text-white text-sm">{cur.hanoutName}</h4>
                        <p className="text-[11px] text-white/50">{cur.profileHanoutSub}</p>
                        <p className="text-[10px] text-white/40">+212 6 61 00 00 01</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-2 pt-2 border-t border-white/5">
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">{cur.creditLimitMetric}</span>
                        <span className="font-black text-white text-sm">{creditLimit.toLocaleString()} DH</span>
                      </div>
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">{cur.activeDebtMetric}</span>
                        <span className="font-black text-[#FF6B00] text-sm">{currentBalance.toFixed(2)} DH</span>
                      </div>
                    </div>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5 space-y-3">
                    <p className="text-[10px] font-bold text-white/40 uppercase">{cur.prefTitle}</p>
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="font-bold text-white">{cur.appLangLabel}</p>
                        <p className="text-[10px] text-white/40">{cur.appLangSub}</p>
                      </div>
                      <button
                        onClick={() => setLang(lang === "fr" ? "ar" : "fr")}
                        className="rounded-lg border border-white/15 bg-white/5 px-2.5 py-1 text-xs font-bold text-white hover:border-[#FF6B00]"
                      >
                        {lang === "fr" ? "🇫🇷 Français" : "🇲🇦 الدارجة"}
                      </button>
                    </div>

                    <div className="flex items-center justify-between border-t border-white/5 pt-2">
                      <div>
                        <p className="font-bold text-white">{cur.offlineSimulatorLabel}</p>
                        <p className="text-[10px] text-white/40">{cur.offlineSimulatorSub}</p>
                      </div>
                      <button
                        onClick={() => setOfflineSimulated(!offlineSimulated)}
                        className={`rounded-lg px-2.5 py-1 text-xs font-bold ${
                          offlineSimulated ? "bg-amber-500 text-black" : "bg-white/10 text-white"
                        }`}
                      >
                        {offlineSimulated ? cur.offlineActive : cur.offlineDisabled}
                      </button>
                    </div>

                    <div className="flex items-center justify-between border-t border-white/5 pt-2">
                      <div>
                        <p className="font-bold text-white">{cur.dbBackendLabel}</p>
                        <p className="text-[10px] text-emerald-400 font-semibold">{cur.supabaseStatus}</p>
                      </div>
                      <span className="rounded bg-emerald-500/20 px-2 py-0.5 text-[10px] font-bold text-emerald-300">
                        {cur.onlineBadge}
                      </span>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Bottom Navigation */}
            <div className="border-t border-white/10 pt-2 grid grid-cols-5 gap-1 text-[10px] font-bold text-center">
              <button
                onClick={() => setRetailerTab("ledger")}
                className={`flex flex-col items-center py-1 rounded-lg ${
                  retailerTab === "ledger" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <BookOpen className="h-4 w-4 mb-0.5" />
                <span>{cur.navCarnet}</span>
              </button>
              <button
                onClick={() => setRetailerTab("catalog")}
                className={`flex flex-col items-center py-1 rounded-lg ${
                  retailerTab === "catalog" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <Store className="h-4 w-4 mb-0.5" />
                <span>{cur.navCatalog}</span>
              </button>
              <button
                onClick={() => setRetailerTab("cart")}
                className={`flex flex-col items-center py-1 rounded-lg relative ${
                  retailerTab === "cart" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <ShoppingCart className="h-4 w-4 mb-0.5" />
                <span>{cur.navCart} ({cart.length})</span>
              </button>
              <button
                onClick={() => setRetailerTab("orders")}
                className={`flex flex-col items-center py-1 rounded-lg ${
                  retailerTab === "orders" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <Package className="h-4 w-4 mb-0.5" />
                <span>{cur.navOrders}</span>
              </button>
              <button
                onClick={() => setRetailerTab("profile")}
                className={`flex flex-col items-center py-1 rounded-lg ${
                  retailerTab === "profile" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <UserCheck className="h-4 w-4 mb-0.5" />
                <span>{cur.navProfile}</span>
              </button>
            </div>
          </div>
        )}

        {/* ══════════════════════════════════════════════════════════════════════
            2. SUPPLIER FLOW (ACCESSOIRES PRO) — Desktop Sidebar Web Shell
           ══════════════════════════════════════════════════════════════════════ */}
        {currentRole === "supplier" && (
          <div className="w-full max-w-5xl rounded-3xl border border-white/15 bg-[#1C1917] p-4 sm:p-6 shadow-2xl flex flex-col md:flex-row gap-6 min-h-[700px]">
            {/* Sidebar */}
            <div className={`w-full md:w-60 border-b md:border-b-0 pb-4 md:pb-0 flex flex-col justify-between ${
              lang === "ar" ? "md:border-l md:pl-4 border-white/10" : "md:border-r md:pr-4 border-white/10"
            }`}>
              <div>
                <div className="flex items-center gap-2 mb-6">
                  <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#FF6B00] text-sm font-black text-black">
                    A
                  </div>
                  <div>
                    <h3 className="font-extrabold text-sm text-white">{cur.supplierBrand}</h3>
                    <p className="text-[10px] text-white/40">{cur.supplierAddress}</p>
                  </div>
                </div>

                <nav className="space-y-1 text-xs font-bold">
                  {[
                    { id: "dashboard", label: cur.navDashboard, icon: Layers },
                    { id: "inventory", label: cur.navInventory, icon: Package },
                    { id: "clients", label: cur.navClients, icon: BookOpen },
                    { id: "verifications", label: cur.navVerifications, icon: CheckCircle2, badge: pendingVerifications.length },
                    { id: "bids", label: cur.navBids, icon: Truck, badge: deliveryBids.length },
                    { id: "profile", label: cur.navSupplierProfile, icon: UserCheck },
                  ].map((tab) => {
                    const Icon = tab.icon;
                    return (
                      <button
                        key={tab.id}
                        onClick={() => setSupplierTab(tab.id as SupplierTab)}
                        className={`flex w-full items-center justify-between rounded-xl px-3 py-2.5 transition ${
                          supplierTab === tab.id
                            ? "bg-[#FF6B00] text-black"
                            : "text-white/70 hover:bg-white/5 hover:text-white"
                        }`}
                      >
                        <span className="flex items-center gap-2">
                          <Icon className="h-4 w-4" />
                          {tab.label}
                        </span>
                        {tab.badge && tab.badge > 0 && (
                          <span
                            className={`rounded-full px-1.5 py-0.5 text-[9px] font-black ${
                              supplierTab === tab.id ? "bg-black text-[#FF6B00]" : "bg-[#FF6B00] text-black"
                            }`}
                          >
                            {tab.badge}
                          </span>
                        )}
                      </button>
                    );
                  })}
                </nav>
              </div>

              {/* Total Balance Overview */}
              <div className="mt-6 rounded-2xl border border-white/10 bg-black/40 p-3 text-xs">
                <p className="text-[10px] text-white/50 uppercase font-bold">{cur.totalReceivables}</p>
                <p className="text-xl font-black text-[#FF6B00] mt-0.5">148 900 MAD</p>
                <p className="text-[10px] text-white/40 mt-1">{cur.partnerHanoutsCount}</p>
              </div>
            </div>

            {/* Supplier Tab Content */}
            <div className="flex-1 overflow-y-auto">
              {/* TAB 1: DASHBOARD */}
              {supplierTab === "dashboard" && (
                <div className="space-y-6">
                  <div>
                    <h2 className="text-xl font-extrabold text-white">{cur.warehouseOverview}</h2>
                    <p className="text-xs text-white/50">{cur.warehouseFlow}</p>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                      <p className="text-xs text-white/50">{cur.ordersToday}</p>
                      <p className="text-2xl font-black text-white mt-1">18</p>
                      <p className="text-[11px] text-emerald-400 mt-1">{cur.ordersShippedTrend}</p>
                    </div>
                    <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                      <p className="text-xs text-white/50">{cur.pendingVerifCount}</p>
                      <p className="text-2xl font-black text-[#FF6B00] mt-1">{pendingVerifications.length}</p>
                      <p className="text-[11px] text-white/40 mt-1">{cur.pendingVerifSub}</p>
                    </div>
                    <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                      <p className="text-xs text-white/50">{cur.couriersInTransit}</p>
                      <p className="text-2xl font-black text-amber-400 mt-1">6 courses</p>
                      <p className="text-[11px] text-white/40 mt-1">{cur.couriersInTransitSub}</p>
                    </div>
                  </div>

                  {/* Quick Actions */}
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={() => setShowBulkPriceModal(true)}
                      className="rounded-xl border border-[#FF6B00]/40 bg-[#FF6B00]/10 px-4 py-2.5 text-xs font-bold text-[#FF6B00] hover:bg-[#FF6B00] hover:text-black transition"
                    >
                      {cur.bulkPriceQuickBtn}
                    </button>
                    <button
                      onClick={() => setShowAddProductModal(true)}
                      className="rounded-xl bg-white/10 px-4 py-2.5 text-xs font-bold text-white hover:bg-white/20 transition"
                    >
                      {cur.newProductQuickBtn}
                    </button>
                  </div>
                </div>
              )}

              {/* TAB 2: INVENTORY */}
              {supplierTab === "inventory" && (
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <div>
                      <h2 className="text-lg font-extrabold text-white">{cur.inventoryTitle}</h2>
                      <p className="text-xs text-white/50">{products.length} {cur.inventoryActiveCount}</p>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => setShowBulkPriceModal(true)}
                        className="rounded-xl bg-[#FF6B00] px-3 py-2 text-xs font-bold text-black"
                      >
                        {cur.bulkPriceActionBtn}
                      </button>
                      <button
                        onClick={() => setShowAddProductModal(true)}
                        className="rounded-xl bg-white/10 px-3 py-2 text-xs font-bold text-white hover:bg-white/20"
                      >
                        {cur.addProductActionBtn}
                      </button>
                    </div>
                  </div>

                  <div className="overflow-x-auto rounded-2xl border border-white/10">
                    <table className="w-full text-left text-xs">
                      <thead className="border-b border-white/10 bg-white/[0.03] text-white/60">
                        <tr>
                          <th className="p-3">{cur.colProduct}</th>
                          <th className="p-3">{cur.colStock}</th>
                          <th className="p-3">{cur.colT1}</th>
                          <th className="p-3">{cur.colT2}</th>
                          <th className="p-3">{cur.colT3}</th>
                          <th className="p-3 text-right">{cur.colActions}</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-white/5">
                        {products.map((p) => (
                          <tr key={p.id} className="hover:bg-white/[0.02]">
                            <td className="p-3">
                              <p className="font-bold text-white">{lang === "ar" && p.nameAr ? p.nameAr : p.name}</p>
                              <p className="text-[10px] text-white/40">{p.brand}</p>
                            </td>
                            <td className="p-3 text-white/70">{p.stock} pcs</td>
                            <td className="p-3 text-white">{p.t1} DH</td>
                            <td className="p-3 text-emerald-400 font-semibold">{p.t2} DH</td>
                            <td className="p-3 text-[#FF6B00] font-bold">{p.t3} DH</td>
                            <td className="p-3 text-right">
                              <button
                                onClick={() => {
                                  const newStock = prompt("Nouveau stock pour " + p.name, String(p.stock));
                                  if (newStock) {
                                    setProducts((prev) =>
                                      prev.map((i) => (i.id === p.id ? { ...i, stock: parseInt(newStock) || i.stock } : i))
                                    );
                                  }
                                }}
                                className="rounded-lg bg-white/5 px-2.5 py-1 text-[11px] font-bold text-white/70 hover:text-white"
                              >
                                {cur.editBtn}
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* TAB 3: CLIENTS (CARNET) */}
              {supplierTab === "clients" && (
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <div>
                      <h2 className="text-lg font-extrabold text-white">{cur.clientsTitle}</h2>
                      <p className="text-xs text-white/50">{cur.clientsSub}</p>
                    </div>
                    <button
                      onClick={() => setShowAddRetailerModal(true)}
                      className="rounded-xl bg-[#FF6B00] px-3 py-2 text-xs font-bold text-black"
                    >
                      {cur.addRetailerActionBtn}
                    </button>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {clients.map((c) => (
                      <div
                        key={c.id}
                        className="rounded-2xl border border-white/10 bg-black/40 p-4 text-xs space-y-2"
                      >
                        <div className="flex justify-between items-start">
                          <div>
                            <p className="font-extrabold text-sm text-white">
                              {lang === "ar" && c.nameAr ? c.nameAr : c.name}
                            </p>
                            <p className="text-[10px] text-white/40">
                              {lang === "ar" && c.cityAr ? c.cityAr : c.city} • {c.phone}
                            </p>
                          </div>
                          <span className="rounded bg-white/5 px-2 py-0.5 text-[10px] font-bold text-white/60">
                            {cur.creditLimitPrefix} {c.limit.toLocaleString()} DH
                          </span>
                        </div>

                        <div className="flex justify-between items-baseline pt-2 border-t border-white/5">
                          <span className="text-white/60">{cur.debtCurrent}</span>
                          <span className="text-base font-black text-[#FF6B00]">
                            {c.balance.toLocaleString("fr-FR", { minimumFractionDigits: 2 })} MAD
                          </span>
                        </div>

                        <div className="flex gap-2 pt-1">
                          <button
                            onClick={() => {
                              alert(lang === "ar" ? "تم إرسال تذكير بالواتساب لمول الحانوت مع كشف الحساب." : "Rappel WhatsApp envoyé au commerçant avec le relevé de compte.");
                            }}
                            className="flex-1 rounded-xl bg-white/10 py-1.5 font-bold text-white hover:bg-white/20"
                          >
                            {cur.whatsappReminderBtn}
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* TAB 4: VERIFICATIONS */}
              {supplierTab === "verifications" && (
                <div className="space-y-4">
                  <div>
                    <h2 className="text-lg font-extrabold text-white">{cur.verificationsTitle}</h2>
                    <p className="text-xs text-white/50">{cur.verificationsSub}</p>
                  </div>

                  {pendingVerifications.length === 0 ? (
                    <div className="text-center py-12 text-white/40 text-xs">
                      {cur.noPendingVerif}
                    </div>
                  ) : (
                    <div className="space-y-3">
                      {pendingVerifications.map((pv) => (
                        <div
                          key={pv.id}
                          className="rounded-2xl border border-white/10 bg-black/40 p-4 text-xs space-y-3"
                        >
                          <div className="flex justify-between items-start">
                            <div>
                              <p className="font-extrabold text-sm text-white">
                                {lang === "ar" && pv.clientAr ? pv.clientAr : pv.client}
                              </p>
                              <p className="text-[10px] text-white/40">
                                {cur.methodLabel} <strong className="text-white uppercase">{pv.method}</strong> • {cur.refLabel} {pv.ref}
                              </p>
                              <p className="text-[10px] text-white/40">
                                {lang === "ar" && pv.dateAr ? pv.dateAr : pv.date}
                              </p>
                            </div>
                            <span className="text-lg font-black text-emerald-400">
                              +{pv.amount.toFixed(2)} DH
                            </span>
                          </div>

                          <div className="flex gap-2">
                            <button
                              onClick={() => {
                                setPendingVerifications((prev) => prev.filter((p) => p.id !== pv.id));
                                setClients((prev) =>
                                  prev.map((c) => (c.name === pv.client ? { ...c, balance: Math.max(0, c.balance - pv.amount) } : c))
                                );
                                alert(
                                  lang === "ar"
                                    ? `تم قبول خلصة بقيمة ${pv.amount} درهم ! تم الخصم من حساب الزبون بنجاح.`
                                    : `Versement de ${pv.amount} DH validé ! Le carnet du client a été débité.`
                                );
                              }}
                              className="flex-1 rounded-xl bg-emerald-500 py-2 font-bold text-black hover:bg-emerald-400 transition"
                            >
                              {cur.approvePaymentBtn}
                            </button>
                            <button
                              onClick={() => {
                                setPendingVerifications((prev) => prev.filter((p) => p.id !== pv.id));
                                alert(lang === "ar" ? "تم رفض الخلصة وإشعار مول الحانوت." : "Versement rejeté. Notification de litige envoyée au commerçant.");
                              }}
                              className="rounded-xl border border-red-500/40 bg-red-500/10 px-4 py-2 font-bold text-red-400 hover:bg-red-500/20"
                            >
                              {cur.rejectPaymentBtn}
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* TAB 5: BIDS */}
              {supplierTab === "bids" && (
                <div className="space-y-4">
                  <div>
                    <h2 className="text-lg font-extrabold text-white">{cur.bidsTitle}</h2>
                    <p className="text-xs text-white/50">{cur.bidsSub}</p>
                  </div>

                  {deliveryBids.map((bid) => (
                    <div
                      key={bid.id}
                      className="rounded-2xl border border-white/10 bg-black/40 p-4 text-xs space-y-3"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-extrabold text-sm text-white">
                            {lang === "ar" && bid.driverAr ? bid.driverAr : bid.driver}
                          </p>
                          <p className="text-[10px] text-white/40">
                            {cur.tripLabel} {lang === "ar" && bid.missionAr ? bid.missionAr : bid.mission}
                          </p>
                          <p className="text-[10px] text-white/40">
                            {cur.estimatedTimeLabel} {lang === "ar" && bid.timeAr ? bid.timeAr : bid.time}
                          </p>
                        </div>
                        <span className="text-base font-black text-[#FF6B00]">
                          {bid.amount} MAD
                        </span>
                      </div>

                      <button
                        onClick={() => {
                          setDeliveryBids((prev) => prev.filter((b) => b.id !== bid.id));
                          alert(
                            lang === "ar"
                              ? `تم قبول العرض ! كود التوصيل PIN المخصص للكورتي: 4829`
                              : `Offre acceptée ! Code PIN de livraison généré pour ${bid.driver} : 4829`
                          );
                        }}
                        className="w-full rounded-xl bg-[#FF6B00] py-2 font-bold text-black hover:bg-[#ff8533]"
                      >
                        {cur.acceptBidBtn}
                      </button>
                    </div>
                  ))}
                </div>
              )}

              {/* TAB 6: SUPPLIER PROFILE */}
              {supplierTab === "profile" && (
                <div className="space-y-4 text-xs">
                  <div>
                    <h2 className="text-lg font-extrabold text-white">{cur.profileWarehouseTitle}</h2>
                    <p className="text-xs text-white/50">{cur.profileWarehouseSub}</p>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <div>
                        <label className="text-white/40 block mb-1">{cur.companyLabel}</label>
                        <p className="font-extrabold text-sm text-white">{cur.companyVal}</p>
                      </div>
                      <div>
                        <label className="text-white/40 block mb-1">{cur.geoZoneLabel}</label>
                        <p className="font-extrabold text-sm text-white">{cur.geoZoneVal}</p>
                      </div>
                      <div>
                        <label className="text-white/40 block mb-1">{cur.taxIdLabel}</label>
                        <p className="font-extrabold text-sm text-white">{cur.taxIdVal}</p>
                      </div>
                      <div>
                        <label className="text-white/40 block mb-1">{cur.whatsappLineLabel}</label>
                        <p className="font-extrabold text-sm text-[#FF6B00]">+212 5 22 00 00 00</p>
                      </div>
                    </div>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-2">
                    <h4 className="font-bold text-white text-sm">{cur.creditPolicyTitle}</h4>
                    <p className="text-white/60">{cur.creditPolicyDesc}</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* ══════════════════════════════════════════════════════════════════════
            3. DRIVER FLOW (KOURTIA HASSAN) — 430px Mobile Frame
           ══════════════════════════════════════════════════════════════════════ */}
        {currentRole === "driver" && (
          <div className="w-full max-w-[430px] rounded-3xl border border-white/15 bg-[#1C1917] p-4 shadow-2xl flex flex-col min-h-[700px]">
            {/* Driver Header */}
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <div>
                <p className="text-[11px] font-medium text-white/50">{cur.driverPartner}</p>
                <h2 className="text-base font-extrabold text-white">{cur.driverName}</h2>
                <p className="text-[10px] text-white/40">{cur.driverVehicleSub}</p>
              </div>
              <span className="rounded-full border border-[#FF6B00]/40 bg-[#FF6B00]/10 px-2.5 py-1 text-[10px] font-bold text-[#FF6B00]">
                {cur.inTourBadge}
              </span>
            </div>

            {/* TAB CONTENT */}
            <div className="flex-1 py-3 overflow-y-auto space-y-4">
              {driverTab === "active" && (
                <div className="space-y-4">
                  {/* Active Job Card */}
                  <div className="rounded-2xl border border-[#FF6B00]/40 bg-gradient-to-br from-[#FF6B00]/20 via-black to-black p-4">
                    <span className="text-[10px] font-black uppercase tracking-wider text-[#FF6B00]">
                      {cur.activeTripLabel}
                    </span>
                    <h3 className="mt-1 text-base font-extrabold text-white">{cur.activeTripRoute}</h3>
                    <p className="text-xs text-white/60">{cur.activeTripDest}</p>

                    {/* Big PIN Display */}
                    <div className="mt-4 rounded-xl border border-white/15 bg-black/60 p-3 text-center">
                      <p className="text-[11px] font-bold text-white/50 uppercase">{cur.pinToShow}</p>
                      <p className="text-4xl font-black tracking-widest text-[#FF6B00] mt-1">4829</p>
                      <p className="text-[10px] text-white/40 mt-1">{cur.pinHint}</p>
                    </div>

                    {/* COD / Frais */}
                    <div className="mt-3 flex items-center justify-between text-xs pt-2 border-t border-white/10">
                      <span className="text-white/60">{cur.driverRewardLabel}</span>
                      <span className="font-bold text-emerald-400">85,00 MAD</span>
                    </div>

                    <div className="mt-3 flex gap-2">
                      <a
                        href="tel:+212661000001"
                        className="flex-1 rounded-xl bg-white/10 py-2 text-center text-xs font-bold text-white hover:bg-white/20"
                      >
                        {cur.callHanoutBtn}
                      </a>
                      <button
                        onClick={() => {
                          setDriverCodCollected(!driverCodCollected);
                        }}
                        className={`flex-1 rounded-xl py-2 text-xs font-bold transition ${
                          driverCodCollected ? "bg-emerald-500 text-black" : "bg-white/10 text-white"
                        }`}
                      >
                        {driverCodCollected ? cur.cashCollectedBtn : cur.collectCashBtn}
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {driverTab === "marketplace" && (
                <div className="space-y-3">
                  <h3 className="text-xs font-bold text-white/50 uppercase tracking-wider">
                    {cur.marketplaceTitle}
                  </h3>

                  {driverOpenJobs.map((job) => (
                    <div
                      key={job.id}
                      className="rounded-2xl border border-white/10 bg-black/40 p-3.5 text-xs space-y-2.5"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-extrabold text-sm text-white">
                            {lang === "ar" ? `${job.fromAr} ➔ ${job.toAr}` : `${job.from} ➔ ${job.to}`}
                          </p>
                          <p className="text-[10px] text-white/40">
                            {lang === "ar" ? job.packagesAr : job.packages}
                          </p>
                        </div>
                        <span className="text-sm font-black text-[#FF6B00]">~{job.estFee} DH</span>
                      </div>

                      <div className="flex items-center gap-2">
                        <input
                          type="number"
                          placeholder={cur.yourRatePlaceholder}
                          value={driverBidInput[job.id] || ""}
                          onChange={(e) =>
                            setDriverBidInput({ ...driverBidInput, [job.id]: e.target.value })
                          }
                          className="h-8 w-28 rounded-lg border border-white/20 bg-white/5 px-2 text-xs text-white outline-none focus:border-[#FF6B00]"
                        />
                        <button
                          onClick={() => {
                            setDriverBidSuccess(job.id);
                            setTimeout(() => setDriverBidSuccess(null), 2500);
                          }}
                          className="flex-1 h-8 rounded-lg bg-[#FF6B00] font-bold text-black text-xs hover:bg-[#ff8533]"
                        >
                          {driverBidSuccess === job.id ? cur.bidSubmittedSuccess : cur.proposeBidBtn}
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {driverTab === "profile" && (
                <div className="space-y-4 text-xs">
                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3">
                    <div className="flex items-center gap-3">
                      <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#FF6B00]/20 text-[#FF6B00] font-black text-lg">
                        KH
                      </div>
                      <div>
                        <h4 className="font-extrabold text-white text-sm">{cur.driverName}</h4>
                        <p className="text-[11px] text-white/50">{cur.driverVehicleSub}</p>
                        <p className="text-[10px] text-emerald-400 font-bold">★ 4.9/5 (142 livraisons)</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-2 pt-2 border-t border-white/5">
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">{cur.completedTrips}</span>
                        <span className="font-black text-white text-sm">142</span>
                      </div>
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">{cur.earningsDeposited}</span>
                        <span className="font-black text-emerald-400 text-sm">4 280 DH</span>
                      </div>
                    </div>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-2">
                    <h5 className="font-bold text-white">{cur.vehicleLogistics}</h5>
                    <p className="text-white/60">{cur.vehicleDesc}</p>
                  </div>
                </div>
              )}
            </div>

            {/* Driver Navigation */}
            <div className="border-t border-white/10 pt-2 grid grid-cols-3 gap-1 text-[11px] font-bold text-center">
              <button
                onClick={() => setDriverTab("active")}
                className={`py-2 rounded-lg ${
                  driverTab === "active" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
                }`}
              >
                {cur.navActiveTrip}
              </button>
              <button
                onClick={() => setDriverTab("marketplace")}
                className={`py-2 rounded-lg ${
                  driverTab === "marketplace" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
                }`}
              >
                {cur.navMarketplace}
              </button>
              <button
                onClick={() => setDriverTab("profile")}
                className={`py-2 rounded-lg ${
                  driverTab === "profile" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
                }`}
              >
                {cur.navDriverProfile}
              </button>
            </div>
          </div>
        )}
      </main>

      {/* ══════════════════════════════════════════════════════════════════════
          MODALS & OVERLAYS (COMPLETELY BILINGUAL)
         ══════════════════════════════════════════════════════════════════════ */}

      {/* 1. Retailer Payment Declaration Modal */}
      {showPaymentModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4">
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <h3 className="font-extrabold text-sm text-white">{cur.modalPaymentTitle}</h3>
              <button onClick={() => setShowPaymentModal(false)} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="space-y-3 text-xs">
              <div>
                <label className="text-white/60 block mb-1">{cur.transferMethodLabel}</label>
                <div className="grid grid-cols-2 gap-1.5">
                  {["wafacash", "cashplus", "virement", "especes"].map((m) => (
                    <button
                      key={m}
                      onClick={() => setPaymentMethod(m)}
                      className={`rounded-xl py-2 font-bold uppercase transition text-[11px] ${
                        paymentMethod === m ? "bg-[#FF6B00] text-black" : "bg-white/5 text-white/60"
                      }`}
                    >
                      {m}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="text-white/60 block mb-1">{cur.amountMADLabel}</label>
                <input
                  type="number"
                  value={paymentAmount}
                  onChange={(e) => setPaymentAmount(e.target.value)}
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 font-bold text-white outline-none focus:border-[#FF6B00]"
                />
              </div>

              <div>
                <label className="text-white/60 block mb-1">{cur.receiptRefLabel}</label>
                <input
                  type="text"
                  value={paymentRef}
                  onChange={(e) => setPaymentRef(e.target.value)}
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
                />
              </div>

              {/* OCR Demo Simulator Button */}
              <button
                type="button"
                onClick={() => {
                  setPaymentAmount("1500");
                  setPaymentRef(`WF-${Math.floor(100000 + Math.random() * 900000)}`);
                  alert(lang === "ar" ? "سيمولاسيون OCR : تم قراءة المبلغ ورقم التوصيل من صورة التوصيل تلقائياً !" : "Simulation OCR (Démo) : Montant et référence extraits de la photo du reçu !");
                }}
                className="w-full rounded-xl border border-dashed border-[#FF6B00]/60 bg-[#FF6B00]/5 py-2 font-bold text-[#FF6B00] text-[11px]"
              >
                {cur.ocrSimulateBtn}
              </button>
            </div>

            <div className="pt-2 flex gap-2">
              <button
                onClick={() => {
                  const amt = parseFloat(paymentAmount) || 0;
                  setPendingVerifications([
                    {
                      id: "pv-" + Date.now(),
                      client: "Hanout Moulay",
                      clientAr: "حانوت مولاي",
                      method: paymentMethod,
                      ref: paymentRef,
                      amount: amt,
                      date: "À l'instant",
                      dateAr: "دابا",
                    },
                    ...pendingVerifications,
                  ]);
                  setCurrentBalance((prev) => Math.max(0, prev - amt));
                  setShowPaymentModal(false);
                  setPaymentSuccessToast(true);
                  setTimeout(() => setPaymentSuccessToast(false), 3000);
                }}
                className="flex-1 rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black text-xs"
              >
                {cur.confirmAndNotifyWhatsApp}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 2. Partial Receipt Adjustment Modal (Screen 10) */}
      {selectedOrderForReceipt && (() => {
        const currentItems = selectedOrderForReceipt.items.map((it: any) => ({
          ...it,
          received: receivedQtys[it.name] ?? it.ordered,
        }));
        const calcTotal = currentItems.reduce((s: number, i: any) => s + i.price * i.received, 0);
        const diff = selectedOrderForReceipt.total - calcTotal;

        return (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
              <div className="flex justify-between items-center border-b border-white/10 pb-3">
                <div>
                  <h3 className="font-extrabold text-sm text-white">{cur.modalPartialTitle}</h3>
                  <p className="text-[10px] text-white/40">{cur.modalPartialBon} {selectedOrderForReceipt.id}</p>
                </div>
                <button onClick={() => setSelectedOrderForReceipt(null)} className="text-white/40 hover:text-white">
                  <X className="h-4 w-4" />
                </button>
              </div>

              <p className="text-white/60">{cur.modalPartialHint}</p>

              <div className="space-y-3 max-h-60 overflow-y-auto pr-1">
                {selectedOrderForReceipt.items.map((it: any) => {
                  const currQty = receivedQtys[it.name] ?? it.ordered;
                  const isModified = currQty !== it.ordered;

                  return (
                    <div
                      key={it.name}
                      className={`rounded-xl border p-3 transition ${
                        isModified ? "border-amber-500/50 bg-amber-500/10" : "border-white/10 bg-black/40"
                      }`}
                    >
                      <div className="flex justify-between font-bold text-white mb-1.5">
                        <span className="truncate pr-2">
                          {lang === "ar" && it.nameAr ? it.nameAr : it.name}
                        </span>
                        <span className="text-[#FF6B00] shrink-0">{it.price} DH/u</span>
                      </div>
                      {isModified && (
                        <p className="text-[10px] text-amber-400 font-bold mb-1">
                          {cur.qtyAdjustedAlert} {it.ordered} ➔ {currQty} pcs
                        </p>
                      )}
                      <div className="flex justify-between items-center">
                        <span className="text-white/50 text-[11px]">{cur.orderedLabel} {it.ordered} pcs</span>
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() =>
                              setReceivedQtys({
                                ...receivedQtys,
                                [it.name]: Math.max(0, currQty - 1),
                              })
                            }
                            className="h-7 w-7 rounded-lg bg-white/10 font-bold hover:bg-white/20"
                          >
                            -
                          </button>
                          <span className="w-6 text-center font-bold text-white text-sm">{currQty}</span>
                          <button
                            onClick={() =>
                              setReceivedQtys({
                                ...receivedQtys,
                                [it.name]: currQty + 1,
                              })
                            }
                            className="h-7 w-7 rounded-lg bg-white/10 font-bold hover:bg-white/20"
                          >
                            +
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Live Totals & Diff */}
              <div className="rounded-xl border border-white/10 bg-black/60 p-3 space-y-1">
                <div className="flex justify-between text-white/50 text-[11px]">
                  <span>{cur.initialTotalOrder}</span>
                  <span>{selectedOrderForReceipt.total.toFixed(2)} DH</span>
                </div>
                <div className="flex justify-between font-extrabold text-white text-sm">
                  <span>{cur.newTotalAfterAudit}</span>
                  <span className="text-emerald-400">{calcTotal.toFixed(2)} DH</span>
                </div>
                {diff > 0 && (
                  <p className="text-[10px] text-amber-300 font-bold pt-1 border-t border-white/5">
                    {cur.deductionNoticePrefix} {diff.toFixed(2)} DH {cur.deductionNoticeSuffix}
                  </p>
                )}
              </div>

              <button
                onClick={() => {
                  if (diff > 0) {
                    setCurrentBalance((prev) => Math.max(0, prev - diff));
                  }
                  setOrders((prev) =>
                    prev.map((ord) =>
                      ord.id === selectedOrderForReceipt.id
                        ? { ...ord, items: currentItems, total: calcTotal, status: "partial" }
                        : ord
                    )
                  );
                  setSelectedOrderForReceipt(null);
                  alert(
                    lang === "ar"
                      ? `تم تأكيد الاستلام الجزئي ! ${diff > 0 ? diff.toFixed(2) + " درهم تنقصات من الكارني ديالك." : ""}`
                      : `Réception partielle validée ! ${diff > 0 ? diff.toFixed(2) + " DH ont été déduits de votre solde." : ""}`
                  );
                }}
                className="w-full rounded-xl bg-emerald-500 py-2.5 font-bold text-black hover:bg-emerald-400"
              >
                {cur.confirmAdjustmentAction}
              </button>
            </div>
          </div>
        );
      })()}

      {/* 3. Handshake PIN Validation Modal (Screen 11) */}
      {handshakeModalOrder && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
            {!handshakeSuccess ? (
              <>
                <div className="flex justify-between items-center border-b border-white/10 pb-3">
                  <div>
                    <h3 className="font-extrabold text-sm text-white">{cur.modalHandshakeTitle}</h3>
                    <p className="text-[10px] text-white/40">{cur.modalHandshakeSub}</p>
                  </div>
                  <button onClick={() => setHandshakeModalOrder(null)} className="text-white/40 hover:text-white">
                    <X className="h-4 w-4" />
                  </button>
                </div>

                <p className="text-white/60">{cur.modalHandshakeHint}</p>

                <div className="my-4 text-center">
                  <input
                    type="text"
                    maxLength={4}
                    placeholder="PIN"
                    value={handshakePinInput}
                    onChange={(e) => setHandshakePinInput(e.target.value)}
                    className="h-12 w-32 rounded-2xl border-2 border-white/20 bg-white/5 text-center text-xl font-black tracking-widest text-[#FF6B00] outline-none focus:border-[#FF6B00]"
                  />
                  <p className="text-[10px] text-white/40 mt-1">{cur.demoPinCode} {handshakeModalOrder.pin}</p>
                </div>

                <button
                  onClick={() => {
                    if (handshakePinInput === handshakeModalOrder.pin) {
                      setHandshakeSuccess(true);
                      setOrders((prev) =>
                        prev.map((o) =>
                          o.id === handshakeModalOrder.id ? { ...o, status: "delivered" } : o
                        )
                      );
                    } else {
                      alert(lang === "ar" ? `كود غالط، عاود. الكود الصحيح هو ${handshakeModalOrder.pin}` : `Code PIN incorrect. Le code valide est ${handshakeModalOrder.pin}`);
                    }
                  }}
                  className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black hover:bg-[#ff8533]"
                >
                  {cur.verifyHandshakeBtn}
                </button>
              </>
            ) : (
              /* SCREEN 11: FULL HANDSHAKE CONFIRMATION VIEW */
              <div className="space-y-4 text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-400">
                  <CheckCircle2 className="h-10 w-10 text-emerald-400" />
                </div>

                <div>
                  <h3 className="text-lg font-extrabold text-white">{cur.handshakeSuccessTitle}</h3>
                  <p className="text-[11px] text-white/50">{cur.handshakeSuccessSub}</p>
                </div>

                <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5 text-left space-y-2 text-xs">
                  <div className="flex justify-between text-white/60">
                    <span>{cur.deliverySlipLabel}</span>
                    <span className="font-bold text-white">BON-{handshakeModalOrder.id}</span>
                  </div>
                  <div className="flex justify-between text-white/60">
                    <span>{cur.articlesVerifiedLabel}</span>
                    <span className="font-bold text-emerald-400">
                      {handshakeModalOrder.items?.reduce((s: number, i: any) => s + (i.received || i.ordered), 0)} {lang === "ar" ? "قطع" : "unités"}
                    </span>
                  </div>
                  <div className="flex justify-between text-white/60">
                    <span>{cur.anomaliesLabel}</span>
                    <span className="font-bold text-white/80">{cur.zeroAnomalies}</span>
                  </div>
                  <div className="border-t border-white/5 pt-1.5 flex justify-between font-bold text-sm">
                    <span className="text-white">{cur.amountValidatedLabel}</span>
                    <span className="text-[#FF6B00]">{handshakeModalOrder.total.toFixed(2)} DH</span>
                  </div>
                </div>

                <div className="rounded-2xl border border-white/10 bg-black/40 p-3 text-left space-y-1 text-xs">
                  <p className="text-[10px] uppercase font-bold text-white/40">{cur.partiesPresent}</p>
                  <p className="text-white/80 font-medium">{cur.driverParty} {handshakeModalOrder.driverName}</p>
                  <p className="text-white/80 font-medium">{cur.retailerParty}</p>
                </div>

                <a
                  href={`https://wa.me/212661000001?text=${encodeURIComponent(
                    lang === "ar"
                      ? `السلام عليكم، تم استلام الطلبية BON-${handshakeModalOrder.id} بنجاح. المبلغ: ${handshakeModalOrder.total.toFixed(2)} درهم. الاستلام مأكد بالكود.`
                      : `Bonjour, confirmation de réception pour le bon BON-${handshakeModalOrder.id}. Montant total: ${handshakeModalOrder.total.toFixed(2)} DH. Remise physique validée.`
                  )}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-center gap-2 w-full rounded-xl bg-[#25D366] py-2.5 font-bold text-white hover:bg-[#20ba59] transition"
                >
                  <Phone className="h-4 w-4" />
                  <span>{cur.shareWhatsAppBtn}</span>
                </a>

                <button
                  onClick={() => {
                    setHandshakeModalOrder(null);
                    setHandshakeSuccess(false);
                    setHandshakePinInput("");
                  }}
                  className="w-full rounded-xl border border-white/15 bg-white/5 py-2 font-bold text-white hover:bg-white/10"
                >
                  {cur.closeAndFinishBtn}
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* 4. Bulk Price Adjustment Modal (Supplier) */}
      {showBulkPriceModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-md rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <div>
                <h3 className="font-extrabold text-sm text-white">{cur.modalBulkTitle}</h3>
                <p className="text-[10px] text-white/40">{cur.modalBulkSub}</p>
              </div>
              <button onClick={() => setShowBulkPriceModal(false)} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="flex gap-2">
              <button
                onClick={() => setBulkAdjustmentType("percentage")}
                className={`flex-1 rounded-xl py-2 font-bold ${
                  bulkAdjustmentType === "percentage" ? "bg-[#FF6B00] text-black" : "bg-white/5 text-white/60"
                }`}
              >
                {cur.percentageMode}
              </button>
              <button
                onClick={() => setBulkAdjustmentType("fixed")}
                className={`flex-1 rounded-xl py-2 font-bold ${
                  bulkAdjustmentType === "fixed" ? "bg-[#FF6B00] text-black" : "bg-white/5 text-white/60"
                }`}
              >
                {cur.fixedMode}
              </button>
            </div>

            <div>
              <label className="text-white/60 block mb-1">
                {cur.adjustmentValueLabel} ({bulkAdjustmentType === "percentage" ? "%" : "DH"}) :
              </label>
              <input
                type="number"
                value={bulkAdjustmentValue}
                onChange={(e) => setBulkAdjustmentValue(parseFloat(e.target.value) || 0)}
                className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 font-bold text-white outline-none focus:border-[#FF6B00]"
              />
            </div>

            {/* Preview Table */}
            <div className="rounded-xl border border-white/10 bg-black/40 p-2.5">
              <p className="text-[10px] font-bold text-white/50 uppercase mb-2">{cur.livePreviewLabel}</p>
              <div className="space-y-1.5">
                {products.slice(0, 3).map((p) => {
                  const newPrice =
                    bulkAdjustmentType === "percentage"
                      ? +(p.t2 * (1 + bulkAdjustmentValue / 100)).toFixed(2)
                      : +(p.t2 + bulkAdjustmentValue).toFixed(2);
                  return (
                    <div key={p.id} className="flex justify-between items-center text-[11px]">
                      <span className="text-white/70 truncate max-w-[200px]">
                        {lang === "ar" && p.nameAr ? p.nameAr : p.name}
                      </span>
                      <div>
                        <span className="text-white/40 line-through mr-2">{p.t2} DH</span>
                        <span className="font-bold text-[#FF6B00]">{newPrice} DH</span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            <button
              onClick={() => {
                setProducts((prev) =>
                  prev.map((p) => {
                    const calc = (oldP: number) =>
                      bulkAdjustmentType === "percentage"
                        ? +(oldP * (1 + bulkAdjustmentValue / 100)).toFixed(2)
                        : +(oldP + bulkAdjustmentValue).toFixed(2);
                    return { ...p, t1: calc(p.t1), t2: calc(p.t2), t3: calc(p.t3) };
                  })
                );
                setShowBulkPriceModal(false);
                alert(
                  lang === "ar"
                    ? `تم تحيين الأثمنة ف الكاطالوج كامل بـ ${bulkAdjustmentValue}${bulkAdjustmentType === "percentage" ? "%" : " درهم"} !`
                    : `Prix du catalogue mis à jour de ${bulkAdjustmentValue}${bulkAdjustmentType === "percentage" ? "%" : " DH"} !`
                );
              }}
              className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black"
            >
              {cur.applyToCatalogBtn}
            </button>
          </div>
        </div>
      )}

      {/* 5. Add Retailer Modal */}
      {showAddRetailerModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <h3 className="font-extrabold text-sm text-white">{cur.modalAddRetailerTitle}</h3>
              <button onClick={() => setShowAddRetailerModal(false)} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div>
              <label className="text-white/60 block mb-1">{cur.retailerPhoneLabel}</label>
              <input
                type="text"
                value={newRetailerPhone}
                onChange={(e) => setNewRetailerPhone(e.target.value)}
                className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
              />
            </div>

            <div>
              <label className="text-white/60 block mb-1">{cur.initialCreditLimitLabel}</label>
              <input
                type="number"
                value={newRetailerLimit}
                onChange={(e) => setNewRetailerLimit(e.target.value)}
                className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
              />
            </div>

            <button
              onClick={() => {
                setClients([
                  ...clients,
                  {
                    id: "c-" + Date.now(),
                    name: "Nouveau Hanout (" + newRetailerPhone.slice(-4) + ")",
                    nameAr: "حانوت جديد (" + newRetailerPhone.slice(-4) + ")",
                    city: "Maroc",
                    cityAr: "المغرب",
                    phone: newRetailerPhone,
                    balance: 0.0,
                    limit: parseFloat(newRetailerLimit) || 10000,
                  },
                ]);
                setShowAddRetailerModal(false);
                alert(lang === "ar" ? "تم إرسال دعوة بالواتساب لمول الحانوت ! الكارني غادي يتفعل مباشرة بعد التأكيد." : "Invitation WhatsApp envoyée au commerçant ! Dès confirmation, le carnet sera actif.");
              }}
              className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black"
            >
              {cur.sendWhatsAppInviteBtn}
            </button>
          </div>
        </div>
      )}

      {/* 6. Add Product Modal */}
      {showAddProductModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-3 text-xs">
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <h3 className="font-extrabold text-sm text-white">{cur.modalAddProductTitle}</h3>
              <button onClick={() => setShowAddProductModal(false)} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div>
              <label className="text-white/60 block mb-1">{cur.productNameLabel}</label>
              <input
                type="text"
                id="new-prod-name"
                defaultValue="Batterie iPhone 12 Pro (Haute Capacité)"
                className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
              />
            </div>

            <div className="grid grid-cols-3 gap-2">
              <div>
                <label className="text-white/60 block mb-1 text-[10px]">{cur.colT1} (DH)</label>
                <input
                  type="number"
                  id="new-prod-t1"
                  defaultValue="95"
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
                />
              </div>
              <div>
                <label className="text-white/60 block mb-1 text-[10px]">{cur.colT2}</label>
                <input
                  type="number"
                  id="new-prod-t2"
                  defaultValue="80"
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
                />
              </div>
              <div>
                <label className="text-white/60 block mb-1 text-[10px]">{cur.colT3}</label>
                <input
                  type="number"
                  id="new-prod-t3"
                  defaultValue="68"
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
                />
              </div>
            </div>

            <button
              onClick={() => {
                const nameEl = document.getElementById("new-prod-name") as HTMLInputElement;
                const t1El = document.getElementById("new-prod-t1") as HTMLInputElement;
                const t2El = document.getElementById("new-prod-t2") as HTMLInputElement;
                const t3El = document.getElementById("new-prod-t3") as HTMLInputElement;

                setProducts([
                  {
                    id: "prod-" + Date.now(),
                    name: nameEl?.value || "Nouvel Accessoire",
                    nameAr: nameEl?.value || "أكسسوار جديد",
                    brand: "Accessoires Pro",
                    stock: 100,
                    t1: parseFloat(t1El?.value) || 95,
                    t2: parseFloat(t2El?.value) || 80,
                    t3: parseFloat(t3El?.value) || 68,
                    status: "Actif",
                    compatibility: ["Tous les modèles"],
                  },
                  ...products,
                ]);
                setShowAddProductModal(false);
                alert(lang === "ar" ? "تمت إضافة المنتوج الجديد إلى كاطالوج المولي بنجاح !" : "Nouveau produit ajouté au catalogue grossiste avec succès !");
              }}
              className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black mt-2"
            >
              {cur.saveToInventoryBtn}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default function PrototypePage() {
  return (
    <Suspense
      fallback={
        <div className="flex h-screen items-center justify-center bg-black text-white">
          <div className="h-6 w-6 animate-spin rounded-full border-2 border-[#FF6B00] border-t-transparent" />
        </div>
      }
    >
      <PrototypeApp />
    </Suspense>
  );
}
