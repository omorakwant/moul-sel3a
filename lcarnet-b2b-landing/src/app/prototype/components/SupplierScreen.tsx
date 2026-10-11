"use client";

import React from "react";
import {
  Layers,
  Package,
  BookOpen,
  CheckCircle2,
  Truck,
  UserCheck,
} from "lucide-react";
import {
  SupplierTab,
  Product,
  Client,
  PendingVerification,
  DeliveryBid,
  LangType,
} from "../types";

interface SupplierScreenProps {
  supplierTab: SupplierTab;
  setSupplierTab: (tab: SupplierTab) => void;
  products: Product[];
  setProducts: React.Dispatch<React.SetStateAction<Product[]>>;
  clients: Client[];
  setClients: React.Dispatch<React.SetStateAction<Client[]>>;
  pendingVerifications: PendingVerification[];
  setPendingVerifications: React.Dispatch<React.SetStateAction<PendingVerification[]>>;
  deliveryBids: DeliveryBid[];
  setDeliveryBids: React.Dispatch<React.SetStateAction<DeliveryBid[]>>;
  setShowBulkPriceModal: (show: boolean) => void;
  setShowAddProductModal: (show: boolean) => void;
  setShowAddRetailerModal: (show: boolean) => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function SupplierScreen({
  supplierTab,
  setSupplierTab,
  products,
  setProducts,
  clients,
  setClients,
  pendingVerifications,
  setPendingVerifications,
  deliveryBids,
  setDeliveryBids,
  setShowBulkPriceModal,
  setShowAddProductModal,
  setShowAddRetailerModal,
  lang,
  cur,
}: SupplierScreenProps) {
  return (
    <div className="w-full max-w-5xl rounded-3xl border border-white/15 bg-[#1C1917] p-4 sm:p-6 shadow-2xl flex flex-col md:flex-row gap-6 min-h-[700px]">
      {/* Sidebar */}
      <div
        className={`w-full md:w-60 border-b md:border-b-0 pb-4 md:pb-0 flex flex-col justify-between ${
          lang === "ar" ? "md:border-l md:pl-4 border-white/10" : "md:border-r md:pr-4 border-white/10"
        }`}
      >
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
        <div className="rounded-2xl border border-white/10 bg-black/40 p-3 mt-4 text-xs space-y-1">
          <span className="text-[10px] text-white/40 uppercase font-bold">{cur.totalReceivables}</span>
          <p className="font-black text-white text-base">
            {clients.reduce((s, c) => s + c.balance, 0).toLocaleString()} MAD
          </p>
          <p className="text-[10px] text-emerald-400 font-bold">{cur.partnerHanoutsCount}</p>
        </div>
      </div>

      {/* Main Content Pane */}
      <div className="flex-1 overflow-y-auto">
        {/* TAB 1: DASHBOARD */}
        {supplierTab === "dashboard" && (
          <div className="space-y-6">
            <div>
              <h2 className="text-lg font-extrabold text-white">{cur.warehouseOverview}</h2>
              <p className="text-xs text-white/50">{cur.warehouseFlow}</p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                <span className="text-white/40 text-xs">{cur.ordersToday}</span>
                <p className="text-2xl font-black text-white mt-1">18</p>
                <span className="text-emerald-400 text-[10px] font-bold">{cur.ordersShippedTrend}</span>
              </div>
              <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                <span className="text-white/40 text-xs">{cur.pendingVerifCount}</span>
                <p className="text-2xl font-black text-[#FF6B00] mt-1">{pendingVerifications.length}</p>
                <span className="text-white/40 text-[10px]">{cur.pendingVerifSub}</span>
              </div>
              <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                <span className="text-white/40 text-xs">{cur.kourtiaLiveBidsCount}</span>
                <p className="text-2xl font-black text-white mt-1">{deliveryBids.length}</p>
                <span className="text-white/40 text-[10px]">{cur.kourtiaLiveBidsSub}</span>
              </div>
            </div>

            {/* Quick Live Feed */}
            <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3">
              <h4 className="font-bold text-xs uppercase text-white/60">{cur.urgentActionsSupplier}</h4>
              <div className="space-y-2 text-xs">
                {pendingVerifications.map((pv) => (
                  <div key={pv.id} className="flex justify-between items-center bg-white/5 p-2.5 rounded-xl border border-white/5">
                    <div>
                      <p className="font-bold text-white">
                        {lang === "ar" && pv.clientAr ? pv.clientAr : pv.client} • {pv.amount} DH
                      </p>
                      <p className="text-[10px] text-white/40">{pv.method} • {pv.ref}</p>
                    </div>
                    <button
                      onClick={() => setSupplierTab("verifications")}
                      className="rounded-lg bg-[#FF6B00] px-3 py-1 font-bold text-black text-[11px]"
                    >
                      {cur.reviewBtn}
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* TAB 2: INVENTORY & TIERED PRICING */}
        {supplierTab === "inventory" && (
          <div className="space-y-4">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2">
              <div>
                <h2 className="text-lg font-extrabold text-white">{cur.inventoryTiersTitle}</h2>
                <p className="text-xs text-white/50">{cur.inventoryTiersSub}</p>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setShowBulkPriceModal(true)}
                  className="rounded-xl border border-[#FF6B00]/40 bg-[#FF6B00]/10 px-3 py-1.5 text-xs font-bold text-[#FF6B00] hover:bg-[#FF6B00]/20"
                >
                  {cur.bulkPriceAdjustBtn}
                </button>
                <button
                  onClick={() => setShowAddProductModal(true)}
                  className="rounded-xl bg-[#FF6B00] px-3 py-1.5 text-xs font-bold text-black hover:bg-[#ff8533]"
                >
                  {cur.addProductBtn}
                </button>
              </div>
            </div>

            <div className="space-y-2 text-xs">
              {products.map((p) => (
                <div key={p.id} className="rounded-2xl border border-white/10 bg-black/40 p-3.5 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                  <div>
                    <div className="flex items-center gap-2">
                      <p className="font-bold text-white">{lang === "ar" && p.nameAr ? p.nameAr : p.name}</p>
                      <span className="text-[10px] text-white/40">• {p.brand}</span>
                    </div>
                    <p className="text-[10px] text-emerald-400 font-medium mt-0.5">
                      {cur.stockQtyPrefix} {p.stock} {cur.stockQtySuffix}
                    </p>
                  </div>

                  <div className="flex items-center gap-4 text-center">
                    <div className="rounded-xl bg-white/5 px-2.5 py-1">
                      <span className="text-[9px] text-white/40 block">{cur.tier1Range}</span>
                      <span className="font-bold text-white">{p.t1} DH</span>
                    </div>
                    <div className="rounded-xl bg-white/5 px-2.5 py-1">
                      <span className="text-[9px] text-white/40 block">{cur.tier2Range}</span>
                      <span className="font-bold text-[#FF6B00]">{p.t2} DH</span>
                    </div>
                    <div className="rounded-xl bg-white/5 px-2.5 py-1">
                      <span className="text-[9px] text-white/40 block">{cur.tier3Range}</span>
                      <span className="font-bold text-emerald-400">{p.t3} DH</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* TAB 3: CLIENTS & CARNET LIMITS */}
        {supplierTab === "clients" && (
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <div>
                <h2 className="text-lg font-extrabold text-white">{cur.clientsCarnetTitle}</h2>
                <p className="text-xs text-white/50">{cur.clientsCarnetSub}</p>
              </div>
              <button
                onClick={() => setShowAddRetailerModal(true)}
                className="rounded-xl bg-[#FF6B00] px-3 py-1.5 text-xs font-bold text-black"
              >
                {cur.addRetailerBtn}
              </button>
            </div>

            <div className="space-y-2 text-xs">
              {clients.map((c) => {
                const ratio = Math.min(100, Math.round((c.balance / c.limit) * 100));
                return (
                  <div key={c.id} className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-2">
                    <div className="flex justify-between items-start">
                      <div>
                        <h4 className="font-bold text-white text-sm">
                          {lang === "ar" && c.nameAr ? c.nameAr : c.name}
                        </h4>
                        <p className="text-[11px] text-white/40">
                          {lang === "ar" && c.cityAr ? c.cityAr : c.city} • {c.phone}
                        </p>
                      </div>
                      <div className="text-right">
                        <span className="text-sm font-black text-white">{c.balance.toFixed(2)} DH</span>
                        <p className="text-[10px] text-white/40">{cur.ceilingPrefix} {c.limit.toLocaleString()} DH</p>
                      </div>
                    </div>

                    <div className="space-y-1">
                      <div className="flex justify-between text-[10px] text-white/40">
                        <span>{cur.creditUtilization}</span>
                        <span>{ratio}%</span>
                      </div>
                      <div className="h-1.5 w-full rounded-full bg-white/10 overflow-hidden">
                        <div
                          className={`h-full ${ratio > 80 ? "bg-red-500" : ratio > 50 ? "bg-amber-500" : "bg-emerald-500"}`}
                          style={{ width: `${ratio}%` }}
                        />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* TAB 4: VERIFICATIONS (Wafacash / CashPlus Proofs) */}
        {supplierTab === "verifications" && (
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-extrabold text-white">{cur.verifTabTitle}</h2>
              <p className="text-xs text-white/50">{cur.verifTabSub}</p>
            </div>

            {pendingVerifications.length === 0 ? (
              <div className="rounded-2xl border border-white/10 bg-black/40 p-8 text-center text-white/40 text-xs">
                {cur.noPendingPayments}
              </div>
            ) : (
              <div className="space-y-3 text-xs">
                {pendingVerifications.map((pv) => (
                  <div key={pv.id} className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3">
                    <div className="flex justify-between items-start">
                      <div>
                        <span className="rounded-full bg-white/10 px-2 py-0.5 text-[10px] font-bold text-white/70 uppercase">
                          {pv.method}
                        </span>
                        <h4 className="font-extrabold text-white text-base mt-1">
                          {pv.amount.toFixed(2)} MAD
                        </h4>
                        <p className="text-[11px] text-white/50">
                          {lang === "ar" && pv.clientAr ? pv.clientAr : pv.client} • {lang === "ar" && pv.dateAr ? pv.dateAr : pv.date}
                        </p>
                      </div>
                      <div className="text-right">
                        <span className="text-[10px] text-white/40">{cur.referenceSlipLabel}</span>
                        <p className="font-mono font-bold text-[#FF6B00] text-xs">{pv.ref}</p>
                      </div>
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
                          alert(
                            lang === "ar"
                              ? "تم رفض الخلصة وإشعار مول الحانوت."
                              : "Versement rejeté. Notification de litige envoyée au commerçant."
                          );
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

        {/* TAB 5: BIDS (KOURTIA LOGISTICS MARKETPLACE) */}
        {supplierTab === "bids" && (
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-extrabold text-white">{cur.kourtiaOffersTitle}</h2>
              <p className="text-xs text-white/50">{cur.kourtiaOffersSub}</p>
            </div>

            {deliveryBids.map((bid) => (
              <div key={bid.id} className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3 text-xs">
                <div className="flex justify-between items-start">
                  <div>
                    <span className="font-extrabold text-white text-sm">
                      {lang === "ar" && bid.driverAr ? bid.driverAr : bid.driver}
                    </span>
                    <p className="text-[10px] text-white/40">{bid.phone}</p>
                    <p className="text-[11px] text-[#FF6B00] font-medium mt-1">
                      📍 {lang === "ar" && bid.missionAr ? bid.missionAr : bid.mission}
                    </p>
                  </div>
                  <div className="text-right">
                    <span className="text-lg font-black text-emerald-400">{bid.amount} DH</span>
                    <p className="text-[10px] text-white/40">
                      ⏱ {lang === "ar" && bid.timeAr ? bid.timeAr : bid.time}
                    </p>
                  </div>
                </div>

                <button
                  onClick={() => {
                    setDeliveryBids((prev) => prev.filter((b) => b.id !== bid.id));
                    alert(
                      lang === "ar"
                        ? `تم تأكيد الكورتي ${bid.driver} لنقل السلعة مقابل ${bid.amount} درهم !`
                        : `Transporteur ${bid.driver} assigné pour ${bid.amount} DH !`
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
  );
}
