"use client";

import React from "react";
import {
  ShoppingCart,
  BookOpen,
  Store,
  Package,
  UserCheck,
  Search,
  Mic,
  Trash2,
  Phone,
} from "lucide-react";
import {
  RetailerTab,
  CartItem,
  Order,
  Product,
  LangType,
} from "../types";

interface RetailerScreenProps {
  retailerTab: RetailerTab;
  setRetailerTab: (tab: RetailerTab) => void;
  offlineSimulated: boolean;
  setOfflineSimulated: (simulated: boolean) => void;
  cart: CartItem[];
  setCart: React.Dispatch<React.SetStateAction<CartItem[]>>;
  orders: Order[];
  setOrders: React.Dispatch<React.SetStateAction<Order[]>>;
  currentBalance: number;
  setCurrentBalance: React.Dispatch<React.SetStateAction<number>>;
  creditLimit: number;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  selectedBrand: string;
  setSelectedBrand: (brand: string) => void;
  selectedModel: string;
  setSelectedModel: (model: string) => void;
  isVoiceListening: boolean;
  setIsVoiceListening: (listening: boolean) => void;
  cartTotal: number;
  getItemUnitPrice: (item: CartItem) => number;
  filteredProducts: Product[];
  setShowPaymentModal: (show: boolean) => void;
  setSelectedOrderForReceipt: (order: Order | null) => void;
  setHandshakeModalOrder: (order: Order | null) => void;
  setLang: (lang: LangType) => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function RetailerScreen({
  retailerTab,
  setRetailerTab,
  offlineSimulated,
  setOfflineSimulated,
  cart,
  setCart,
  orders,
  setOrders,
  currentBalance,
  setCurrentBalance,
  creditLimit,
  searchQuery,
  setSearchQuery,
  selectedBrand,
  setSelectedBrand,
  selectedModel,
  setSelectedModel,
  isVoiceListening,
  setIsVoiceListening,
  cartTotal,
  getItemUnitPrice,
  filteredProducts,
  setShowPaymentModal,
  setSelectedOrderForReceipt,
  setHandshakeModalOrder,
  setLang,
  lang,
  cur,
}: RetailerScreenProps) {
  return (
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
  );
}
