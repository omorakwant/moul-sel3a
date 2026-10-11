"use client";

import { useState, useMemo, Suspense } from "react";
import { useSearchParams } from "next/navigation";

// Types
import {
  RoleType,
  RetailerTab,
  SupplierTab,
  DriverTab,
  LangType,
  CartItem,
  Order,
  Product,
  Client,
  PendingVerification,
  DeliveryBid,
  DriverJob,
} from "./types";

// Translations & Mock Data
import { t } from "./translations";
import {
  initialCart,
  initialOrders,
  initialProducts,
  initialClients,
  initialPendingVerifications,
  initialDeliveryBids,
  initialDriverJobs,
} from "./mockData";

// Components
import { PrototypeHeader } from "./components/PrototypeHeader";
import { RetailerScreen } from "./components/RetailerScreen";
import { SupplierScreen } from "./components/SupplierScreen";
import { DriverScreen } from "./components/DriverScreen";

// Modals
import { PaymentModal } from "./components/modals/PaymentModal";
import { PartialReceiptModal } from "./components/modals/PartialReceiptModal";
import { HandshakePinModal } from "./components/modals/HandshakePinModal";
import { BulkPriceModal } from "./components/modals/BulkPriceModal";
import { AddRetailerModal } from "./components/modals/AddRetailerModal";
import { AddProductModal } from "./components/modals/AddProductModal";

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
  const [, setPaymentSuccessToast] = useState(false);

  // Cart & Orders State
  const [cart, setCart] = useState<CartItem[]>(initialCart);
  const [orders, setOrders] = useState<Order[]>(initialOrders);

  // Partial Receipt & Handshake Modal State
  const [selectedOrderForReceipt, setSelectedOrderForReceipt] = useState<Order | null>(null);
  const [receivedQtys, setReceivedQtys] = useState<Record<string, number>>({});
  const [handshakePinInput, setHandshakePinInput] = useState("");
  const [handshakeModalOrder, setHandshakeModalOrder] = useState<Order | null>(null);
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

  const [products, setProducts] = useState<Product[]>(initialProducts);
  const [clients, setClients] = useState<Client[]>(initialClients);
  const [pendingVerifications, setPendingVerifications] = useState<PendingVerification[]>(initialPendingVerifications);
  const [deliveryBids, setDeliveryBids] = useState<DeliveryBid[]>(initialDeliveryBids);

  // ── Driver State ──
  const [driverTab, setDriverTab] = useState<DriverTab>("active");
  const [driverCodCollected, setDriverCodCollected] = useState(false);
  const [driverOpenJobs] = useState<DriverJob[]>(initialDriverJobs);
  const [driverBidInput, setDriverBidInput] = useState<Record<string, string>>({});
  const [driverBidSuccess, setDriverBidSuccess] = useState<string | null>(null);

  // ── Helpers ──
  const getItemUnitPrice = (item: CartItem) => {
    if (item.quantity >= 50 && item.priceTiers["50"]) return item.priceTiers["50"];
    if (item.quantity >= 10 && item.priceTiers["10"]) return item.priceTiers["10"];
    return item.priceTiers["1"] || 0;
  };

  const cartTotal = useMemo(() => {
    return cart.reduce((sum, item) => sum + getItemUnitPrice(item) * item.quantity, 0);
  }, [cart]);

  const filteredProducts = useMemo(() => {
    return products.filter((p) => {
      const matchBrand = selectedBrand === "Toutes" || selectedBrand === "الكل" || p.brand === selectedBrand;
      const matchModel =
        selectedModel === "Tous les modèles" ||
        selectedModel === "📱 كاع الموديلات (التوافق)" ||
        p.compatibility.includes(selectedModel) ||
        p.compatibility.includes("Tous les modèles");
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
      {/* ── Top Header Bar & Offline Indicator ── */}
      <PrototypeHeader
        lang={lang}
        setLang={setLang}
        currentRole={currentRole}
        setCurrentRole={setCurrentRole}
        offlineSimulated={offlineSimulated}
        setOfflineSimulated={setOfflineSimulated}
        cur={cur}
      />

      {/* ── Main Workspace ── */}
      <main className="flex-1 bg-[#121110] p-2 sm:p-6 flex flex-col items-center justify-start">
        {currentRole === "retailer" && (
          <RetailerScreen
            retailerTab={retailerTab}
            setRetailerTab={setRetailerTab}
            offlineSimulated={offlineSimulated}
            setOfflineSimulated={setOfflineSimulated}
            cart={cart}
            setCart={setCart}
            orders={orders}
            setOrders={setOrders}
            currentBalance={currentBalance}
            setCurrentBalance={setCurrentBalance}
            creditLimit={creditLimit}
            searchQuery={searchQuery}
            setSearchQuery={setSearchQuery}
            selectedBrand={selectedBrand}
            setSelectedBrand={setSelectedBrand}
            selectedModel={selectedModel}
            setSelectedModel={setSelectedModel}
            isVoiceListening={isVoiceListening}
            setIsVoiceListening={setIsVoiceListening}
            cartTotal={cartTotal}
            getItemUnitPrice={getItemUnitPrice}
            filteredProducts={filteredProducts}
            setShowPaymentModal={setShowPaymentModal}
            setSelectedOrderForReceipt={setSelectedOrderForReceipt}
            setHandshakeModalOrder={setHandshakeModalOrder}
            setLang={setLang}
            lang={lang}
            cur={cur}
          />
        )}

        {currentRole === "supplier" && (
          <SupplierScreen
            supplierTab={supplierTab}
            setSupplierTab={setSupplierTab}
            products={products}
            setProducts={setProducts}
            clients={clients}
            setClients={setClients}
            pendingVerifications={pendingVerifications}
            setPendingVerifications={setPendingVerifications}
            deliveryBids={deliveryBids}
            setDeliveryBids={setDeliveryBids}
            setShowBulkPriceModal={setShowBulkPriceModal}
            setShowAddProductModal={setShowAddProductModal}
            setShowAddRetailerModal={setShowAddRetailerModal}
            lang={lang}
            cur={cur}
          />
        )}

        {currentRole === "driver" && (
          <DriverScreen
            driverTab={driverTab}
            setDriverTab={setDriverTab}
            driverCodCollected={driverCodCollected}
            setDriverCodCollected={setDriverCodCollected}
            driverOpenJobs={driverOpenJobs}
            driverBidInput={driverBidInput}
            setDriverBidInput={setDriverBidInput}
            driverBidSuccess={driverBidSuccess}
            setDriverBidSuccess={setDriverBidSuccess}
            lang={lang}
            cur={cur}
          />
        )}
      </main>

      {/* ── Modals & Overlays ── */}
      <PaymentModal
        isOpen={showPaymentModal}
        onClose={() => setShowPaymentModal(false)}
        paymentAmount={paymentAmount}
        setPaymentAmount={setPaymentAmount}
        paymentMethod={paymentMethod}
        setPaymentMethod={setPaymentMethod}
        paymentRef={paymentRef}
        setPaymentRef={setPaymentRef}
        onSubmit={(amt, method, ref) => {
          setPendingVerifications([
            {
              id: "pv-" + Date.now(),
              client: "Hanout Moulay",
              clientAr: "حانوت مولاي",
              method,
              ref,
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
        lang={lang}
        cur={cur}
      />

      <PartialReceiptModal
        order={selectedOrderForReceipt}
        onClose={() => setSelectedOrderForReceipt(null)}
        receivedQtys={receivedQtys}
        setReceivedQtys={setReceivedQtys}
        onConfirm={(calcTotal, diff) => {
          if (!selectedOrderForReceipt) return;
          if (diff > 0) {
            setCurrentBalance((prev) => Math.max(0, prev - diff));
          }
          const currentItems = selectedOrderForReceipt.items.map((it) => ({
            ...it,
            received: receivedQtys[it.name] ?? it.ordered,
          }));
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
        lang={lang}
        cur={cur}
      />

      <HandshakePinModal
        order={handshakeModalOrder}
        onClose={() => {
          setHandshakeModalOrder(null);
          setHandshakeSuccess(false);
          setHandshakePinInput("");
        }}
        handshakePinInput={handshakePinInput}
        setHandshakePinInput={setHandshakePinInput}
        handshakeSuccess={handshakeSuccess}
        setHandshakeSuccess={setHandshakeSuccess}
        onSuccessDelivered={() => {
          if (!handshakeModalOrder) return;
          setOrders((prev) =>
            prev.map((o) => (o.id === handshakeModalOrder.id ? { ...o, status: "delivered" } : o))
          );
        }}
        lang={lang}
        cur={cur}
      />

      <BulkPriceModal
        isOpen={showBulkPriceModal}
        onClose={() => setShowBulkPriceModal(false)}
        bulkAdjustmentType={bulkAdjustmentType}
        setBulkAdjustmentType={setBulkAdjustmentType}
        bulkAdjustmentValue={bulkAdjustmentValue}
        setBulkAdjustmentValue={setBulkAdjustmentValue}
        products={products}
        onApply={() => {
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
        lang={lang}
        cur={cur}
      />

      <AddRetailerModal
        isOpen={showAddRetailerModal}
        onClose={() => setShowAddRetailerModal(false)}
        newRetailerPhone={newRetailerPhone}
        setNewRetailerPhone={setNewRetailerPhone}
        newRetailerLimit={newRetailerLimit}
        setNewRetailerLimit={setNewRetailerLimit}
        onAdd={() => {
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
          alert(
            lang === "ar"
              ? "تم إرسال دعوة بالواتساب لمول الحانوت ! الكارني غادي يتفعل مباشرة بعد التأكيد."
              : "Invitation WhatsApp envoyée au commerçant ! Dès confirmation, le carnet sera actif."
          );
        }}
        cur={cur}
      />

      <AddProductModal
        isOpen={showAddProductModal}
        onClose={() => setShowAddProductModal(false)}
        onAdd={(newProduct) => {
          setProducts([newProduct, ...products]);
          setShowAddProductModal(false);
        }}
        lang={lang}
        cur={cur}
      />
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
