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
  brand: string;
  quantity: number;
  priceTiers: Record<string, number>;
}

export function PrototypeApp() {
  const searchParams = useSearchParams();
  const initialRole = (searchParams.get("role")?.toLowerCase() as RoleType) || "retailer";
  const [currentRole, setCurrentRole] = useState<RoleType>(
    ["retailer", "supplier", "driver"].includes(initialRole) ? initialRole : "retailer"
  );
  const [lang, setLang] = useState<LangType>("fr");
  const [offlineSimulated, setOfflineSimulated] = useState(false);

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
      brand: "Generic",
      quantity: 10,
      priceTiers: { "1": 15.0, "10": 12.0, "50": 10.0 },
    },
    {
      id: "prod-002",
      name: "Verre Trempé Samsung A54 (9H)",
      brand: "GlassPro",
      quantity: 20,
      priceTiers: { "1": 25.0, "10": 20.0, "50": 16.0 },
    },
  ]);

  // Orders State
  const [orders, setOrders] = useState([
    {
      id: "CMD-2026-84",
      date: "Aujourd'hui, 09:30",
      total: 1850.0,
      status: "in_transit", // in_transit | delivered | partial
      driverName: "Kourtia Hassan (+212 6 98 00 00 01)",
      pin: "4829",
      items: [
        { name: "Coque Silicone iPhone 13/14", ordered: 20, received: 20, price: 12.0 },
        { name: "Chargeur Rapide USB-C 20W", ordered: 15, received: 15, price: 38.0 },
      ],
    },
    {
      id: "CMD-2026-72",
      date: "Hier, 16:15",
      total: 2900.75,
      status: "delivered",
      driverName: "Livreur Omar",
      pin: "1192",
      items: [
        { name: "Écouteurs Bluetooth TWS", ordered: 25, received: 25, price: 72.0 },
        { name: "Câble Data USB-C vers Lightning", ordered: 40, received: 40, price: 18.0 },
      ],
    },
  ]);

  // Partial Receipt Modal
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
  const [newRetailerToast, setNewRetailerToast] = useState(false);

  const [products, setProducts] = useState([
    {
      id: "prod-001",
      name: "Coque Silicone iPhone 13/14",
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
    { id: "c1", name: "Hanout Moulay", city: "Rabat (Souk Al Had)", phone: "+212 6 61 00 00 01", balance: 4250.75, limit: 15000 },
    { id: "c2", name: "Téléphonie Fès", city: "Fès (Médina)", phone: "+212 6 61 00 00 02", balance: 1200.0, limit: 8000 },
    { id: "c3", name: "Hanout Bab Marrakech", city: "Casablanca", phone: "+212 6 61 00 00 03", balance: 8450.0, limit: 20000 },
    { id: "c4", name: "SmartPhone Tanger", city: "Tanger (Boulevard)", phone: "+212 6 61 00 00 04", balance: 0.0, limit: 12000 },
  ]);

  const [pendingVerifications, setPendingVerifications] = useState([
    {
      id: "pv-001",
      client: "Hanout Moulay",
      method: "Wafacash",
      ref: "WF-2026-9814",
      amount: 1200.0,
      date: "Aujourd'hui, 11:20",
    },
    {
      id: "pv-002",
      client: "Téléphonie Fès",
      method: "CashPlus",
      ref: "CP-2026-4412",
      amount: 500.0,
      date: "Hier, 18:45",
    },
  ]);

  const [deliveryBids, setDeliveryBids] = useState([
    { id: "bid-1", driver: "Kourtia Hassan", phone: "+212 6 98 00 00 01", amount: 85, time: "2 heures", mission: "Derb Omar ➔ Souk Al Had, Rabat", status: "pending" },
    { id: "bid-2", driver: "Livreur Omar", phone: "+212 6 98 00 00 02", amount: 95, time: "3 heures", mission: "Derb Omar ➔ Souk Al Had, Rabat", status: "pending" },
  ]);

  // ── Driver State ──
  const [driverTab, setDriverTab] = useState<DriverTab>("active");
  const [driverCodCollected, setDriverCodCollected] = useState(false);
  const [driverOpenJobs, setDriverOpenJobs] = useState([
    { id: "job-1", from: "Garage Allal, Casa", to: "Médina, Fès", packages: "3 cartons (Écrans)", estFee: 140 },
    { id: "job-2", from: "Derb Ghallef, Casa", to: "Océan, Rabat", packages: "1 carton (Chargeurs)", estFee: 75 },
    { id: "job-3", from: "Derb Omar, Casa", to: "Gueliz, Marrakech", packages: "4 cartons", estFee: 180 },
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
      const matchBrand = selectedBrand === "Toutes" || p.brand === selectedBrand;
      const matchModel = selectedModel === "Tous les modèles" || p.compatibility.includes(selectedModel) || p.compatibility.includes("Tous les modèles");
      const matchSearch = searchQuery === "" || p.name.toLowerCase().includes(searchQuery.toLowerCase()) || p.brand.toLowerCase().includes(searchQuery.toLowerCase());
      return matchBrand && matchModel && matchSearch;
    });
  }, [products, selectedBrand, selectedModel, searchQuery]);

  return (
    <div className="flex min-h-screen flex-col bg-black text-white font-sans selection:bg-[#FF6B00] selection:text-black">
      {/* ── Top Bar ── */}
      <header className="sticky top-0 z-50 flex h-14 shrink-0 items-center justify-between border-b border-white/10 bg-black/95 px-3 sm:px-6 backdrop-blur-md">
        <div className="flex items-center gap-3">
          <Link
            href="/"
            className="flex items-center gap-1.5 rounded-lg border border-white/15 bg-white/[0.04] px-2.5 py-1.5 text-xs font-semibold text-white/90 transition hover:border-[#FF6B00]/60 hover:text-[#FF6B00]"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">Retour au site</span>
          </Link>

          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#FF6B00] text-xs font-black text-black shadow-[0_0_16px_rgba(255,107,0,0.5)]">
              ل
            </div>
            <span className="text-sm font-bold tracking-tight">
              L&apos;Carnet <span className="text-[#FF6B00]">B2B</span>
              <span className="ml-2 hidden rounded-full border border-white/15 bg-white/5 px-2 py-0.5 text-[10px] font-medium text-white/60 md:inline">
                Live Prototype v1.0
              </span>
            </span>
          </div>
        </div>

        {/* ── Role Selector ── */}
        <div className="flex items-center gap-1 sm:gap-2">
          <span className="mr-1 hidden text-xs font-medium text-white/45 lg:inline">
            Tester un rôle :
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
            <span className="hidden sm:inline">Détaillant (Hanout)</span>
            <span className="sm:hidden">Hanout</span>
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
            <span className="hidden sm:inline">Fournisseur (Grossiste)</span>
            <span className="sm:hidden">Grossiste</span>
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
            <span className="hidden sm:inline">Transporteur (Kourtia)</span>
            <span className="sm:hidden">Kourtia</span>
          </button>

          {/* Lang Toggle */}
          <button
            onClick={() => setLang(lang === "fr" ? "ar" : "fr")}
            className="ml-2 flex items-center gap-1 rounded-lg border border-white/15 bg-white/5 px-2 py-1.5 text-xs font-bold text-white hover:border-white/30"
            title="Changer la langue (FR / Darija)"
          >
            <Globe className="h-3 w-3 text-[#FF6B00]" />
            <span>{lang.toUpperCase()}</span>
          </button>
        </div>
      </header>

      {/* ── Offline Banner (Simulated) ── */}
      {offlineSimulated && (
        <div className="bg-amber-500/20 border-b border-amber-500/40 px-4 py-1.5 text-center text-xs font-bold text-amber-300 flex items-center justify-center gap-2">
          <WifiOff className="h-3.5 w-3.5" />
          <span>Mode Hors Ligne Simulé (Les actions sont mises en file d&apos;attente locale Hive)</span>
          <button
            onClick={() => setOfflineSimulated(false)}
            className="underline ml-2 hover:text-white"
          >
            Désactiver
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
                <p className="text-[11px] font-medium text-white/50">
                  {lang === "ar" ? "الحانوت النشط" : "Détaillant connecté"}
                </p>
                <h2
                  onClick={() => setOfflineSimulated(!offlineSimulated)}
                  className="text-base font-extrabold text-white cursor-pointer select-none"
                  title="Cliquez pour simuler le mode hors ligne"
                >
                  Hanout Moulay — Rabat
                </h2>
                <p className="text-[10px] text-white/40">Souk Al Had • +212 6 61 00 00 01</p>
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
                        {lang === "ar" ? "كارني السلعة (الكريدي)" : "Solde Carnet (Rolling Debt)"}
                      </span>
                      <span className="rounded bg-red-500/20 px-2 py-0.5 text-[10px] font-bold text-red-400">
                        {lang === "ar" ? "واجب الأداء" : "Dette active"}
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
                        <span>Plafond autorisé: {creditLimit.toLocaleString()} DH</span>
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
                        {lang === "ar" ? "خلّص دابا (WhatsApp)" : "Déclarer un versement"}
                      </button>
                      <button
                        onClick={() => setRetailerTab("catalog")}
                        className="rounded-xl border border-white/20 bg-white/10 px-3 py-2 text-xs font-bold text-white hover:bg-white/20"
                      >
                        + Commander
                      </button>
                    </div>
                  </div>

                  {/* Supplier Card */}
                  <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5">
                    <p className="text-[11px] font-bold text-white/50 uppercase tracking-wider mb-2">
                      Fournisseurs partenaires
                    </p>
                    <div className="rounded-xl border border-white/5 bg-white/[0.02] p-3">
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-bold text-sm text-white">Accessoires Pro Casablanca</p>
                          <p className="text-[11px] text-white/50">Derb Omar • +212 5 22 00 00 00</p>
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
                          Voir catalogue
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
                      Historique du Carnet (Derniers mouvements)
                    </p>
                    <div className="space-y-2 text-xs">
                      <div className="flex justify-between p-2 rounded-lg bg-white/[0.02] border border-white/5">
                        <div>
                          <p className="font-bold text-white">Commande CMD-2026-84</p>
                          <p className="text-[10px] text-white/40">10 févr. • Kourtia Hassan</p>
                        </div>
                        <span className="font-bold text-red-400">+1 850,00 DH</span>
                      </div>
                      <div className="flex justify-between p-2 rounded-lg bg-white/[0.02] border border-white/5">
                        <div>
                          <p className="font-bold text-white">Versement Wafacash</p>
                          <p className="text-[10px] text-white/40">5 févr. • Réf: WF-20250205</p>
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
                      <Search className="absolute left-3 top-2.5 h-3.5 w-3.5 text-white/40" />
                      <input
                        type="text"
                        placeholder="Rechercher écouteurs, coques, câbles..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="h-9 w-full rounded-xl border border-white/15 bg-white/5 pl-8 pr-3 text-xs text-white placeholder:text-white/40 outline-none focus:border-[#FF6B00]"
                      />
                    </div>
                    <button
                      onClick={() => {
                        setIsVoiceListening(true);
                        setTimeout(() => {
                          setSearchQuery("Écran OLED iPhone");
                          setIsVoiceListening(false);
                        }, 1200);
                      }}
                      className={`flex h-9 w-9 items-center justify-center rounded-xl border transition ${
                        isVoiceListening
                          ? "border-[#FF6B00] bg-[#FF6B00] text-black animate-pulse"
                          : "border-white/15 bg-white/5 text-white/70 hover:text-white"
                      }`}
                      title="Recherche Vocale (Darija / Français)"
                    >
                      <Mic className="h-4 w-4" />
                    </button>
                  </div>
                  {isVoiceListening && (
                    <p className="text-[10px] text-center text-[#FF6B00] font-bold animate-pulse">
                      🎤 Écoute en cours (Darija / Français)... Parlez maintenant
                    </p>
                  )}

                  {/* Compatibility Model Filter */}
                  <div>
                    <select
                      value={selectedModel}
                      onChange={(e) => setSelectedModel(e.target.value)}
                      className="h-8 w-full rounded-lg border border-white/15 bg-black px-2 text-xs font-semibold text-white/80 outline-none"
                    >
                      <option value="Tous les modèles">📱 Tous les modèles (Compatibilité)</option>
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
                        onClick={() => setSelectedBrand(b)}
                        className={`rounded-lg px-2.5 py-1 font-bold whitespace-nowrap transition ${
                          selectedBrand === b
                            ? "bg-[#FF6B00] text-black"
                            : "bg-white/5 text-white/60 hover:text-white"
                        }`}
                      >
                        {b}
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
                            <h4 className="font-bold text-xs text-white">{p.name}</h4>
                          </div>
                          <span className="rounded bg-emerald-500/10 px-1.5 py-0.5 text-[9px] font-bold text-emerald-400">
                            En stock ({p.stock})
                          </span>
                        </div>

                        {/* Tiered Price Table */}
                        <div className="mt-2 grid grid-cols-3 gap-1 rounded-xl bg-white/[0.03] p-1.5 text-center text-[10px]">
                          <div>
                            <p className="text-white/40">1 - 9 pcs</p>
                            <p className="font-extrabold text-white">{p.t1} DH</p>
                          </div>
                          <div className="border-x border-white/5">
                            <p className="text-white/40">10 - 49 pcs</p>
                            <p className="font-extrabold text-emerald-400">{p.t2} DH</p>
                          </div>
                          <div>
                            <p className="text-white/40">50+ pcs</p>
                            <p className="font-extrabold text-[#FF6B00]">{p.t3} DH</p>
                          </div>
                        </div>

                        {/* Add to Cart Action */}
                        <div className="mt-3 flex items-center justify-between">
                          <span className="text-[10px] text-white/40">
                            Paliers appliqués automatiquement
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
                                    brand: p.brand,
                                    quantity: 10,
                                    priceTiers: { "1": p.t1, "10": p.t2, "50": p.t3 },
                                  },
                                ];
                              });
                            }}
                            className="rounded-xl bg-[#FF6B00] px-3 py-1.5 text-xs font-bold text-black transition hover:bg-[#ff8533]"
                          >
                            + Ajouter 10 pcs
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
                    Panier en cours (Paliers calculés au volume)
                  </h3>

                  {cart.length === 0 ? (
                    <div className="text-center py-12 text-white/40 text-xs">
                      Votre panier est vide. Visitez le catalogue pour ajouter des accessoires.
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
                                <p className="font-bold text-white">{item.name}</p>
                                <p className="text-[10px] text-[#FF6B00] font-semibold">
                                  {unitPrice} DH / unité (Palier actif)
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
                          <span>Sous-total articles:</span>
                          <span>{cartTotal.toFixed(2)} DH</span>
                        </div>
                        <div className="flex justify-between text-white/60">
                          <span>Estimation Kourtia (Livraison):</span>
                          <span>40.00 DH</span>
                        </div>
                        <div className="flex justify-between border-t border-white/10 pt-2 text-sm font-black text-white">
                          <span>Total ajouté au Carnet:</span>
                          <span className="text-[#FF6B00]">{(cartTotal + 40).toFixed(2)} DH</span>
                        </div>
                      </div>

                      <button
                        onClick={() => {
                          const newOrder = {
                            id: `CMD-2026-${Math.floor(100 + Math.random() * 900)}`,
                            date: "À l'instant",
                            total: cartTotal + 40,
                            status: "in_transit",
                            driverName: "Kourtia Hassan (+212 6 98 00 00 01)",
                            pin: "7492",
                            items: cart.map((c) => ({
                              name: c.name,
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
                        {lang === "ar" ? "تأكيد الطلبية (تسجيل فالكارني)" : "Valider la Commande (Ajouter au Carnet)"}
                      </button>
                    </div>
                  )}
                </div>
              )}

              {/* TAB 4: ORDERS */}
              {retailerTab === "orders" && (
                <div className="space-y-3">
                  <h3 className="text-xs font-bold text-white/50 uppercase tracking-wider">
                    Suivi des commandes & Réception
                  </h3>

                  {orders.map((ord) => (
                    <div
                      key={ord.id}
                      className="rounded-2xl border border-white/10 bg-black/40 p-3.5 space-y-2 text-xs"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-extrabold text-sm text-white">{ord.id}</p>
                          <p className="text-[10px] text-white/40">{ord.date}</p>
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
                            ? "Chauffeur en route"
                            : ord.status === "delivered"
                            ? "Livrée & Validée"
                            : "Réception partielle"}
                        </span>
                      </div>

                      <p className="text-[11px] text-white/70">
                        Total : <span className="font-bold text-[#FF6B00]">{ord.total.toFixed(2)} DH</span> • Livreur: {ord.driverName}
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
                            Valider PIN Handshake
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
                          Réception partielle
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
                        <h4 className="font-extrabold text-white text-sm">Hanout Moulay</h4>
                        <p className="text-[11px] text-white/50">Souk Al Had, Rabat • Téléphonie & Accessoires</p>
                        <p className="text-[10px] text-white/40">+212 6 61 00 00 01</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-2 pt-2 border-t border-white/5">
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">Plafond Crédit Autorisé</span>
                        <span className="font-black text-white text-sm">{creditLimit.toLocaleString()} DH</span>
                      </div>
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">Dette Tournante Active</span>
                        <span className="font-black text-[#FF6B00] text-sm">{currentBalance.toFixed(2)} DH</span>
                      </div>
                    </div>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5 space-y-3">
                    <p className="text-[10px] font-bold text-white/40 uppercase">Préférences & Synchronisation</p>
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="font-bold text-white">Langue de l&apos;application</p>
                        <p className="text-[10px] text-white/40">Darija Marocaine ou Français</p>
                      </div>
                      <button
                        onClick={() => setLang(lang === "fr" ? "ar" : "fr")}
                        className="rounded-lg border border-white/15 bg-white/5 px-2.5 py-1 text-xs font-bold text-white"
                      >
                        {lang === "fr" ? "Français 🇫🇷" : "الدارجة 🇲🇦"}
                      </button>
                    </div>

                    <div className="flex items-center justify-between border-t border-white/5 pt-2">
                      <div>
                        <p className="font-bold text-white">Simulateur Mode Hors-Ligne</p>
                        <p className="text-[10px] text-white/40">File d&apos;attente locale Hive / SQLite</p>
                      </div>
                      <button
                        onClick={() => setOfflineSimulated(!offlineSimulated)}
                        className={`rounded-lg px-2.5 py-1 text-xs font-bold ${
                          offlineSimulated ? "bg-amber-500 text-black" : "bg-white/10 text-white"
                        }`}
                      >
                        {offlineSimulated ? "Actif" : "Désactivé"}
                      </button>
                    </div>

                    <div className="flex items-center justify-between border-t border-white/5 pt-2">
                      <div>
                        <p className="font-bold text-white">Base de Données Backend</p>
                        <p className="text-[10px] text-emerald-400 font-semibold">● Supabase PostgreSQL Connecté</p>
                      </div>
                      <span className="rounded bg-emerald-500/20 px-2 py-0.5 text-[10px] font-bold text-emerald-300">
                        En Ligne
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
                <span>Le Carnet</span>
              </button>
              <button
                onClick={() => setRetailerTab("catalog")}
                className={`flex flex-col items-center py-1 rounded-lg ${
                  retailerTab === "catalog" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <Store className="h-4 w-4 mb-0.5" />
                <span>Catalogue</span>
              </button>
              <button
                onClick={() => setRetailerTab("cart")}
                className={`flex flex-col items-center py-1 rounded-lg relative ${
                  retailerTab === "cart" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <ShoppingCart className="h-4 w-4 mb-0.5" />
                <span>Panier ({cart.length})</span>
              </button>
              <button
                onClick={() => setRetailerTab("orders")}
                className={`flex flex-col items-center py-1 rounded-lg ${
                  retailerTab === "orders" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <Package className="h-4 w-4 mb-0.5" />
                <span>Commandes</span>
              </button>
              <button
                onClick={() => setRetailerTab("profile")}
                className={`flex flex-col items-center py-1 rounded-lg ${
                  retailerTab === "profile" ? "text-[#FF6B00]" : "text-white/40 hover:text-white"
                }`}
              >
                <UserCheck className="h-4 w-4 mb-0.5" />
                <span>Profil</span>
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
            <div className="w-full md:w-60 border-b md:border-b-0 md:border-r border-white/10 pb-4 md:pb-0 md:pr-4 flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 mb-6">
                  <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#FF6B00] text-sm font-black text-black">
                    A
                  </div>
                  <div>
                    <h3 className="font-extrabold text-sm text-white">Accessoires Pro</h3>
                    <p className="text-[10px] text-white/40">Derb Omar, Entrepôt n°12</p>
                  </div>
                </div>

                <nav className="space-y-1 text-xs font-bold">
                  {[
                    { id: "dashboard", label: "Tableau de Bord", icon: Layers },
                    { id: "inventory", label: "Inventaire & Paliers", icon: Package },
                    { id: "clients", label: "Clients (Carnet)", icon: BookOpen },
                    { id: "verifications", label: "Vérification Paiements", icon: CheckCircle2, badge: pendingVerifications.length },
                    { id: "bids", label: "Appels d'offres Kourtia", icon: Truck, badge: deliveryBids.length },
                    { id: "profile", label: "Profil Entrepôt", icon: UserCheck },
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
                <p className="text-[10px] text-white/50 uppercase font-bold">Créances totales</p>
                <p className="text-xl font-black text-[#FF6B00] mt-0.5">148 900 MAD</p>
                <p className="text-[10px] text-white/40 mt-1">14 Hanouts partenaires</p>
              </div>
            </div>

            {/* Supplier Tab Content */}
            <div className="flex-1 overflow-y-auto">
              {/* TAB 1: DASHBOARD */}
              {supplierTab === "dashboard" && (
                <div className="space-y-6">
                  <div>
                    <h2 className="text-xl font-extrabold text-white">Vue d&apos;ensemble du dépôt</h2>
                    <p className="text-xs text-white/50">Flux temps réel Derb Omar • Casablanca</p>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                      <p className="text-xs text-white/50">Commandes du jour</p>
                      <p className="text-2xl font-black text-white mt-1">18</p>
                      <p className="text-[11px] text-emerald-400 mt-1">↑ +4 expédiées</p>
                    </div>
                    <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                      <p className="text-xs text-white/50">En attente de vérification</p>
                      <p className="text-2xl font-black text-[#FF6B00] mt-1">{pendingVerifications.length}</p>
                      <p className="text-[11px] text-white/40 mt-1">Versements Wafacash/CashPlus</p>
                    </div>
                    <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                      <p className="text-xs text-white/50">Chauffeurs en route</p>
                      <p className="text-2xl font-black text-amber-400 mt-1">6 courses</p>
                      <p className="text-[11px] text-white/40 mt-1">Casa, Rabat, Fès</p>
                    </div>
                  </div>

                  {/* Quick Actions */}
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={() => setShowBulkPriceModal(true)}
                      className="rounded-xl border border-[#FF6B00]/40 bg-[#FF6B00]/10 px-4 py-2.5 text-xs font-bold text-[#FF6B00] hover:bg-[#FF6B00] hover:text-black transition"
                    >
                      ⚡ Ajustement global des prix (+% ou DH)
                    </button>
                    <button
                      onClick={() => setShowAddProductModal(true)}
                      className="rounded-xl bg-white/10 px-4 py-2.5 text-xs font-bold text-white hover:bg-white/20 transition"
                    >
                      + Nouveau produit
                    </button>
                  </div>
                </div>
              )}

              {/* TAB 2: INVENTORY */}
              {supplierTab === "inventory" && (
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <div>
                      <h2 className="text-lg font-extrabold text-white">Inventaire & Paliers de gros</h2>
                      <p className="text-xs text-white/50">{products.length} références actives</p>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => setShowBulkPriceModal(true)}
                        className="rounded-xl bg-[#FF6B00] px-3 py-2 text-xs font-bold text-black"
                      >
                        Ajuster les prix en masse
                      </button>
                      <button
                        onClick={() => setShowAddProductModal(true)}
                        className="rounded-xl bg-white/10 px-3 py-2 text-xs font-bold text-white hover:bg-white/20"
                      >
                        + Ajouter
                      </button>
                    </div>
                  </div>

                  <div className="overflow-x-auto rounded-2xl border border-white/10">
                    <table className="w-full text-left text-xs">
                      <thead className="border-b border-white/10 bg-white/[0.03] text-white/60">
                        <tr>
                          <th className="p-3">Désignation</th>
                          <th className="p-3">Stock</th>
                          <th className="p-3">1-9 pcs</th>
                          <th className="p-3">10-49 pcs</th>
                          <th className="p-3">50+ pcs</th>
                          <th className="p-3 text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-white/5">
                        {products.map((p) => (
                          <tr key={p.id} className="hover:bg-white/[0.02]">
                            <td className="p-3">
                              <p className="font-bold text-white">{p.name}</p>
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
                                Modifier
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
                      <h2 className="text-lg font-extrabold text-white">Clients & Carnet de Crédit</h2>
                      <p className="text-xs text-white/50">Suivi des dettes rolling par hanout</p>
                    </div>
                    <button
                      onClick={() => setShowAddRetailerModal(true)}
                      className="rounded-xl bg-[#FF6B00] px-3 py-2 text-xs font-bold text-black"
                    >
                      + Ajouter un détaillant
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
                            <p className="font-extrabold text-sm text-white">{c.name}</p>
                            <p className="text-[10px] text-white/40">{c.city} • {c.phone}</p>
                          </div>
                          <span className="rounded bg-white/5 px-2 py-0.5 text-[10px] font-bold text-white/60">
                            Plafond: {c.limit.toLocaleString()} DH
                          </span>
                        </div>

                        <div className="flex justify-between items-baseline pt-2 border-t border-white/5">
                          <span className="text-white/60">Dette en cours :</span>
                          <span className="text-base font-black text-[#FF6B00]">
                            {c.balance.toLocaleString("fr-FR", { minimumFractionDigits: 2 })} MAD
                          </span>
                        </div>

                        <div className="flex gap-2 pt-1">
                          <button
                            onClick={() => {
                              alert("Rappel WhatsApp envoyé au commerçant avec le relevé de compte.");
                            }}
                            className="flex-1 rounded-xl bg-white/10 py-1.5 font-bold text-white hover:bg-white/20"
                          >
                            Relance WhatsApp
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
                    <h2 className="text-lg font-extrabold text-white">Vérification des Règlements</h2>
                    <p className="text-xs text-white/50">Preuves de paiement déclarées par les commerçants</p>
                  </div>

                  {pendingVerifications.length === 0 ? (
                    <div className="text-center py-12 text-white/40 text-xs">
                      Aucun versement en attente de vérification.
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
                              <p className="font-extrabold text-sm text-white">{pv.client}</p>
                              <p className="text-[10px] text-white/40">
                                Méthode: <strong className="text-white uppercase">{pv.method}</strong> • Réf: {pv.ref}
                              </p>
                              <p className="text-[10px] text-white/40">{pv.date}</p>
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
                                alert(`Versement de ${pv.amount} DH validé ! Le carnet du client a été débité.`);
                              }}
                              className="flex-1 rounded-xl bg-emerald-500 py-2 font-bold text-black hover:bg-emerald-400 transition"
                            >
                              ✓ Valider le versement (Déduire de la dette)
                            </button>
                            <button
                              onClick={() => {
                                setPendingVerifications((prev) => prev.filter((p) => p.id !== pv.id));
                                alert("Versement rejeté. Notification de litige envoyée au commerçant.");
                              }}
                              className="rounded-xl border border-red-500/40 bg-red-500/10 px-4 py-2 font-bold text-red-400 hover:bg-red-500/20"
                            >
                              Rejeter
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
                    <h2 className="text-lg font-extrabold text-white">Appels d&apos;offres Transporteurs (Bids)</h2>
                    <p className="text-xs text-white/50">Offres soumises par les livreurs indépendants</p>
                  </div>

                  {deliveryBids.map((bid) => (
                    <div
                      key={bid.id}
                      className="rounded-2xl border border-white/10 bg-black/40 p-4 text-xs space-y-3"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-extrabold text-sm text-white">{bid.driver}</p>
                          <p className="text-[10px] text-white/40">Trajet : {bid.mission}</p>
                          <p className="text-[10px] text-white/40">Délai estimé : {bid.time}</p>
                        </div>
                        <span className="text-base font-black text-[#FF6B00]">
                          {bid.amount} MAD
                        </span>
                      </div>

                      <button
                        onClick={() => {
                          setDeliveryBids((prev) => prev.filter((b) => b.id !== bid.id));
                          alert(`Offre acceptée ! Code PIN de livraison généré pour ${bid.driver} : 4829`);
                        }}
                        className="w-full rounded-xl bg-[#FF6B00] py-2 font-bold text-black hover:bg-[#ff8533]"
                      >
                        Accepter l&apos;offre & Générer le PIN de livraison
                      </button>
                    </div>
                  ))}
                </div>
              )}

              {/* TAB 6: SUPPLIER PROFILE */}
              {supplierTab === "profile" && (
                <div className="space-y-4 text-xs">
                  <div>
                    <h2 className="text-lg font-extrabold text-white">Profil & Paramètres de l&apos;Entrepôt</h2>
                    <p className="text-xs text-white/50">Gestion du compte grossiste Derb Omar</p>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <div>
                        <label className="text-white/40 block mb-1">Raison Sociale :</label>
                        <p className="font-extrabold text-sm text-white">Accessoires Pro SARL</p>
                      </div>
                      <div>
                        <label className="text-white/40 block mb-1">Zone Géographique :</label>
                        <p className="font-extrabold text-sm text-white">Derb Omar, Entrepôt n°12, Casablanca</p>
                      </div>
                      <div>
                        <label className="text-white/40 block mb-1">Identifiant Fiscal / RC :</label>
                        <p className="font-extrabold text-sm text-white">RC Casa 491823 • IF 482910</p>
                      </div>
                      <div>
                        <label className="text-white/40 block mb-1">Ligne WhatsApp Commandes :</label>
                        <p className="font-extrabold text-sm text-[#FF6B00]">+212 5 22 00 00 00</p>
                      </div>
                    </div>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-2">
                    <h4 className="font-bold text-white text-sm">Politique de Crédit & Carnet B2B</h4>
                    <p className="text-white/60">
                      Les plafonds de crédit sont assignés individuellement par détaillant affilié. Les encaissements Wafacash et CashPlus débloquent automatiquement le disponible après validation au guichet.
                    </p>
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
                <p className="text-[11px] font-medium text-white/50">Livreur partenaire (Kourtia)</p>
                <h2 className="text-base font-extrabold text-white">Kourtia Hassan</h2>
                <p className="text-[10px] text-white/40">Casablanca–Rabat • Moto / Triporteur</p>
              </div>
              <span className="rounded-full border border-[#FF6B00]/40 bg-[#FF6B00]/10 px-2.5 py-1 text-[10px] font-bold text-[#FF6B00]">
                En tournée
              </span>
            </div>

            {/* TAB CONTENT */}
            <div className="flex-1 py-3 overflow-y-auto space-y-4">
              {driverTab === "active" && (
                <div className="space-y-4">
                  {/* Active Job Card */}
                  <div className="rounded-2xl border border-[#FF6B00]/40 bg-gradient-to-br from-[#FF6B00]/20 via-black to-black p-4">
                    <span className="text-[10px] font-black uppercase tracking-wider text-[#FF6B00]">
                      Course en cours • CMD-2026-84
                    </span>
                    <h3 className="mt-1 text-base font-extrabold text-white">Derb Omar ➔ Souk Al Had, Rabat</h3>
                    <p className="text-xs text-white/60">Destinataire : Hanout Moulay (24 colis d&apos;accessoires)</p>

                    {/* Big PIN Display */}
                    <div className="mt-4 rounded-xl border border-white/15 bg-black/60 p-3 text-center">
                      <p className="text-[11px] font-bold text-white/50 uppercase">Code PIN à montrer au commerçant</p>
                      <p className="text-4xl font-black tracking-widest text-[#FF6B00] mt-1">4829</p>
                      <p className="text-[10px] text-white/40 mt-1">
                        Le commerçant saisit ce PIN sur son app pour déclencher la confirmation physique.
                      </p>
                    </div>

                    {/* COD / Frais */}
                    <div className="mt-3 flex items-center justify-between text-xs pt-2 border-t border-white/10">
                      <span className="text-white/60">Rémunération transport :</span>
                      <span className="font-bold text-emerald-400">85,00 MAD</span>
                    </div>

                    <div className="mt-3 flex gap-2">
                      <a
                        href="tel:+212661000001"
                        className="flex-1 rounded-xl bg-white/10 py-2 text-center text-xs font-bold text-white hover:bg-white/20"
                      >
                        📞 Appeler Hanout
                      </a>
                      <button
                        onClick={() => {
                          setDriverCodCollected(!driverCodCollected);
                        }}
                        className={`flex-1 rounded-xl py-2 text-xs font-bold transition ${
                          driverCodCollected ? "bg-emerald-500 text-black" : "bg-white/10 text-white"
                        }`}
                      >
                        {driverCodCollected ? "✓ Frais encaissés" : "Encaisser 85 DH"}
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {driverTab === "marketplace" && (
                <div className="space-y-3">
                  <h3 className="text-xs font-bold text-white/50 uppercase tracking-wider">
                    Bourse des courses (Missions ouvertes)
                  </h3>

                  {driverOpenJobs.map((job) => (
                    <div
                      key={job.id}
                      className="rounded-2xl border border-white/10 bg-black/40 p-3.5 text-xs space-y-2.5"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <p className="font-extrabold text-sm text-white">{job.from} ➔ {job.to}</p>
                          <p className="text-[10px] text-white/40">{job.packages}</p>
                        </div>
                        <span className="text-sm font-black text-[#FF6B00]">~{job.estFee} DH</span>
                      </div>

                      <div className="flex items-center gap-2">
                        <input
                          type="number"
                          placeholder="Votre tarif (DH)"
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
                          {driverBidSuccess === job.id ? "✓ Offre soumise" : "Proposer mon tarif"}
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
                        <h4 className="font-extrabold text-white text-sm">Kourtia Hassan</h4>
                        <p className="text-[11px] text-white/50">Livreur Indépendant • Casablanca–Rabat</p>
                        <p className="text-[10px] text-emerald-400 font-bold">★ 4.9/5 (142 livraisons)</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-2 pt-2 border-t border-white/5">
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">Courses Terminées</span>
                        <span className="font-black text-white text-sm">142</span>
                      </div>
                      <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                        <span className="text-[10px] text-white/40 block">Gains Déposés</span>
                        <span className="font-black text-emerald-400 text-sm">4 280 DH</span>
                      </div>
                    </div>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-2">
                    <h5 className="font-bold text-white">Véhicule & Logistique</h5>
                    <p className="text-white/60">
                      Triporteur & Moto 150cc • Assurance marchandises valide • Flotte logistique Derb Omar.
                    </p>
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
                Course (PIN)
              </button>
              <button
                onClick={() => setDriverTab("marketplace")}
                className={`py-2 rounded-lg ${
                  driverTab === "marketplace" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
                }`}
              >
                Bourse
              </button>
              <button
                onClick={() => setDriverTab("profile")}
                className={`py-2 rounded-lg ${
                  driverTab === "profile" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
                }`}
              >
                Profil
              </button>
            </div>
          </div>
        )}
      </main>

      {/* ══════════════════════════════════════════════════════════════════════
          MODALS & OVERLAYS
         ══════════════════════════════════════════════════════════════════════ */}

      {/* 1. Retailer Payment Declaration Modal */}
      {showPaymentModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4">
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <h3 className="font-extrabold text-sm text-white">Déclarer un versement au grossiste</h3>
              <button onClick={() => setShowPaymentModal(false)} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="space-y-3 text-xs">
              <div>
                <label className="text-white/60 block mb-1">Méthode de transfert :</label>
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
                <label className="text-white/60 block mb-1">Montant versé (MAD) :</label>
                <input
                  type="number"
                  value={paymentAmount}
                  onChange={(e) => setPaymentAmount(e.target.value)}
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 font-bold text-white outline-none focus:border-[#FF6B00]"
                />
              </div>

              <div>
                <label className="text-white/60 block mb-1">Référence du reçu :</label>
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
                  alert("Simulation OCR (Démo) : Montant et référence extraits de la photo du reçu !");
                }}
                className="w-full rounded-xl border border-dashed border-[#FF6B00]/60 bg-[#FF6B00]/5 py-2 font-bold text-[#FF6B00] text-[11px]"
              >
                📸 Simuler OCR (Scanner le reçu démo)
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
                      method: paymentMethod,
                      ref: paymentRef,
                      amount: amt,
                      date: "À l'instant",
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
                Confirmer & Notifier WhatsApp
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
                  <h3 className="font-extrabold text-sm text-white">Réception Partielle (Screen 10)</h3>
                  <p className="text-[10px] text-white/40">Bon de commande {selectedOrderForReceipt.id}</p>
                </div>
                <button onClick={() => setSelectedOrderForReceipt(null)} className="text-white/40 hover:text-white">
                  <X className="h-4 w-4" />
                </button>
              </div>

              <p className="text-white/60">
                Ajustez les quantités reçues en cas de casse ou d&apos;articles manquants. La dette au Carnet sera recalculée :
              </p>

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
                        <span className="truncate pr-2">{it.name}</span>
                        <span className="text-[#FF6B00] shrink-0">{it.price} DH/u</span>
                      </div>
                      {isModified && (
                        <p className="text-[10px] text-amber-400 font-bold mb-1">
                          ⚠️ Quantité ajustée : {it.ordered} ➔ {currQty} pcs
                        </p>
                      )}
                      <div className="flex justify-between items-center">
                        <span className="text-white/50 text-[11px]">Commandé : {it.ordered} pcs</span>
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
                  <span>Total initial de la commande :</span>
                  <span>{selectedOrderForReceipt.total.toFixed(2)} DH</span>
                </div>
                <div className="flex justify-between font-extrabold text-white text-sm">
                  <span>Nouveau total après inventaire :</span>
                  <span className="text-emerald-400">{calcTotal.toFixed(2)} DH</span>
                </div>
                {diff > 0 && (
                  <p className="text-[10px] text-amber-300 font-bold pt-1 border-t border-white/5">
                    📉 Déduction immédiate de {diff.toFixed(2)} DH sur votre Carnet
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
                    `Réception partielle validée ! ${
                      diff > 0 ? diff.toFixed(2) + " DH ont été déduits de votre solde." : ""
                    }`
                  );
                }}
                className="w-full rounded-xl bg-emerald-500 py-2.5 font-bold text-black hover:bg-emerald-400"
              >
                Confirmer l&apos;Ajustement & Mettre à jour le Carnet
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
                    <h3 className="font-extrabold text-sm text-white">Validation PIN Handshake</h3>
                    <p className="text-[10px] text-white/40">Certifier la remise physique</p>
                  </div>
                  <button onClick={() => setHandshakeModalOrder(null)} className="text-white/40 hover:text-white">
                    <X className="h-4 w-4" />
                  </button>
                </div>

                <p className="text-white/60">
                  Le livreur vous présente son code PIN de tournée. Saisissez-le pour certifier la réception physique en direct :
                </p>

                <div className="my-4 text-center">
                  <input
                    type="text"
                    maxLength={4}
                    placeholder="PIN"
                    value={handshakePinInput}
                    onChange={(e) => setHandshakePinInput(e.target.value)}
                    className="h-12 w-32 rounded-2xl border-2 border-white/20 bg-white/5 text-center text-xl font-black tracking-widest text-[#FF6B00] outline-none focus:border-[#FF6B00]"
                  />
                  <p className="text-[10px] text-white/40 mt-1">Code démo du chauffeur: {handshakeModalOrder.pin}</p>
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
                      alert(`Code PIN incorrect. Le code valide est ${handshakeModalOrder.pin}`);
                    }
                  }}
                  className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black hover:bg-[#ff8533]"
                >
                  Vérifier le Handshake
                </button>
              </>
            ) : (
              /* SCREEN 11: FULL HANDSHAKE CONFIRMATION VIEW */
              <div className="space-y-4 text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-400">
                  <CheckCircle2 className="h-10 w-10 text-emerald-400" />
                </div>

                <div>
                  <h3 className="text-lg font-extrabold text-white">
                    {lang === "ar" ? "تم تأكيد الإستلام بنجاح!" : "Réception Confirmée !"}
                  </h3>
                  <p className="text-[11px] text-white/50">
                    {lang === "ar" ? "السلعة وصلات والحساب تقيد فالكارني" : "Présence physique certifiée par code PIN"}
                  </p>
                </div>

                <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5 text-left space-y-2 text-xs">
                  <div className="flex justify-between text-white/60">
                    <span>Bon de Livraison :</span>
                    <span className="font-bold text-white">BON-{handshakeModalOrder.id}</span>
                  </div>
                  <div className="flex justify-between text-white/60">
                    <span>Articles vérifiés :</span>
                    <span className="font-bold text-emerald-400">
                      {handshakeModalOrder.items?.reduce((s: number, i: any) => s + (i.received || i.ordered), 0)} unités
                    </span>
                  </div>
                  <div className="flex justify-between text-white/60">
                    <span>Anomalies signalées :</span>
                    <span className="font-bold text-white/80">0 anomalie</span>
                  </div>
                  <div className="border-t border-white/5 pt-1.5 flex justify-between font-bold text-sm">
                    <span className="text-white">Montant validé :</span>
                    <span className="text-[#FF6B00]">{handshakeModalOrder.total.toFixed(2)} DH</span>
                  </div>
                </div>

                <div className="rounded-2xl border border-white/10 bg-black/40 p-3 text-left space-y-1 text-xs">
                  <p className="text-[10px] uppercase font-bold text-white/40">Parties Présentes</p>
                  <p className="text-white/80 font-medium">🚚 Livreur : {handshakeModalOrder.driverName}</p>
                  <p className="text-white/80 font-medium">🏪 Commerçant : Hanout Moulay (Rabat)</p>
                </div>

                <a
                  href={`https://wa.me/212661000001?text=${encodeURIComponent(
                    lang === "ar"
                      ? `السلام عليكم، تم استلام الطلبية BON-${handshakeModalOrder.id} بنجاح. المبلغ: ${handshakeModalOrder.total.toFixed(2)} درهم.`
                      : `Bonjour, confirmation de réception pour le bon BON-${handshakeModalOrder.id}. Montant total: ${handshakeModalOrder.total.toFixed(2)} DH. Remise physique validée.`
                  )}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-center gap-2 w-full rounded-xl bg-[#25D366] py-2.5 font-bold text-white hover:bg-[#20ba59] transition"
                >
                  <Phone className="h-4 w-4" />
                  <span>{lang === "ar" ? "بارطاجي فواتساب" : "Partager sur WhatsApp"}</span>
                </a>

                <button
                  onClick={() => {
                    setHandshakeModalOrder(null);
                    setHandshakeSuccess(false);
                    setHandshakePinInput("");
                  }}
                  className="w-full rounded-xl border border-white/15 bg-white/5 py-2 font-bold text-white hover:bg-white/10"
                >
                  Fermer & Terminer
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
                <h3 className="font-extrabold text-sm text-white">Ajustement Global des Prix (Grossiste)</h3>
                <p className="text-[10px] text-white/40">Applique une variation à l&apos;ensemble du catalogue</p>
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
                Pourcentage (%)
              </button>
              <button
                onClick={() => setBulkAdjustmentType("fixed")}
                className={`flex-1 rounded-xl py-2 font-bold ${
                  bulkAdjustmentType === "fixed" ? "bg-[#FF6B00] text-black" : "bg-white/5 text-white/60"
                }`}
              >
                Montant fixe (DH)
              </button>
            </div>

            <div>
              <label className="text-white/60 block mb-1">
                Valeur de l&apos;ajustement ({bulkAdjustmentType === "percentage" ? "%" : "DH"}) :
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
              <p className="text-[10px] font-bold text-white/50 uppercase mb-2">Aperçu direct (Paliers 10-49 pcs) :</p>
              <div className="space-y-1.5">
                {products.slice(0, 3).map((p) => {
                  const newPrice =
                    bulkAdjustmentType === "percentage"
                      ? +(p.t2 * (1 + bulkAdjustmentValue / 100)).toFixed(2)
                      : +(p.t2 + bulkAdjustmentValue).toFixed(2);
                  return (
                    <div key={p.id} className="flex justify-between items-center text-[11px]">
                      <span className="text-white/70 truncate max-w-[200px]">{p.name}</span>
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
                alert(`Prix du catalogue mis à jour de ${bulkAdjustmentValue}${bulkAdjustmentType === "percentage" ? "%" : " DH"} !`);
              }}
              className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black"
            >
              Appliquer à tout le catalogue
            </button>
          </div>
        </div>
      )}

      {/* 5. Add Retailer Modal */}
      {showAddRetailerModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <h3 className="font-extrabold text-sm text-white">Ajouter un Détaillant au Carnet</h3>
              <button onClick={() => setShowAddRetailerModal(false)} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div>
              <label className="text-white/60 block mb-1">Numéro de téléphone du commerçant :</label>
              <input
                type="text"
                value={newRetailerPhone}
                onChange={(e) => setNewRetailerPhone(e.target.value)}
                className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
              />
            </div>

            <div>
              <label className="text-white/60 block mb-1">Plafond de crédit initial (MAD) :</label>
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
                    city: "Maroc",
                    phone: newRetailerPhone,
                    balance: 0.0,
                    limit: parseFloat(newRetailerLimit) || 10000,
                  },
                ]);
                setShowAddRetailerModal(false);
                alert("Invitation WhatsApp envoyée au commerçant ! Dès confirmation, le carnet sera actif.");
              }}
              className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black"
            >
              Envoyer l&apos;invitation WhatsApp
            </button>
          </div>
        </div>
      )}

      {/* 6. Add Product Modal */}
      {showAddProductModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
          <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-3 text-xs">
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <h3 className="font-extrabold text-sm text-white">Ajouter un Nouveau Produit</h3>
              <button onClick={() => setShowAddProductModal(false)} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div>
              <label className="text-white/60 block mb-1">Nom du produit :</label>
              <input
                type="text"
                id="new-prod-name"
                defaultValue="Batterie iPhone 12 Pro (Haute Capacité)"
                className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
              />
            </div>

            <div className="grid grid-cols-3 gap-2">
              <div>
                <label className="text-white/60 block mb-1 text-[10px]">1-9 pcs (DH)</label>
                <input
                  type="number"
                  id="new-prod-t1"
                  defaultValue="95"
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
                />
              </div>
              <div>
                <label className="text-white/60 block mb-1 text-[10px]">10-49 pcs</label>
                <input
                  type="number"
                  id="new-prod-t2"
                  defaultValue="80"
                  className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
                />
              </div>
              <div>
                <label className="text-white/60 block mb-1 text-[10px]">50+ pcs</label>
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
                alert("Nouveau produit ajouté au catalogue grossiste avec succès !");
              }}
              className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black mt-2"
            >
              Enregistrer dans l&apos;inventaire
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
