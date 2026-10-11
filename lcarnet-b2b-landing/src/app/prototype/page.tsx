"use client";

import { useState, Suspense } from "react";
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
} from "lucide-react";

type RoleType = "retailer" | "supplier" | "driver";

function PrototypeApp() {
  const searchParams = useSearchParams();
  const initialRole = (searchParams.get("role")?.toLowerCase() as RoleType) || "retailer";
  const [currentRole, setCurrentRole] = useState<RoleType>(
    ["retailer", "supplier", "driver"].includes(initialRole) ? initialRole : "retailer"
  );
  const [viewMode, setViewMode] = useState<"interactive" | "flutter">("interactive");
  const [pinEntered, setPinEntered] = useState("");
  const [handshakeVerified, setHandshakeVerified] = useState(false);
  const [paymentDeclared, setPaymentDeclared] = useState(false);

  const flutterUrl = process.env.NEXT_PUBLIC_FLUTTER_APP_URL || "";

  return (
    <div className="flex min-h-screen flex-col bg-black text-white font-sans">
      {/* ── Top Bar ── */}
      <header className="sticky top-0 z-50 flex h-14 shrink-0 items-center justify-between border-b border-white/10 bg-black/90 px-3 sm:px-6 backdrop-blur-md">
        <div className="flex items-center gap-3 sm:gap-4">
          <Link
            href="/"
            className="flex items-center gap-1.5 rounded-lg border border-white/15 bg-white/[0.04] px-2.5 py-1.5 text-xs font-semibold text-white/90 transition hover:border-[#FF6B00]/60 hover:text-[#FF6B00]"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">Retour au site</span>
          </Link>

          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#FF6B00] text-xs font-black text-black">
              ل
            </div>
            <span className="text-sm font-bold tracking-tight">
              L&apos;Carnet <span className="text-[#FF6B00]">B2B</span>
              <span className="ml-2 rounded-full border border-white/15 bg-white/5 px-2 py-0.5 text-[10px] font-medium text-white/60">
                Prototype Live
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
            <span className="hidden sm:inline">Transporteur (Chauffeur)</span>
            <span className="sm:hidden">Chauffeur</span>
          </button>
        </div>
      </header>

      {/* ── Main Workspace ── */}
      <main className="flex-1 bg-[#121110] p-3 sm:p-6 flex flex-col items-center justify-center">
        {/* ══════════════════════════════════════════════════════════════════════
            ROLE 1: RETAILER (HANOUT MOULAY)
           ══════════════════════════════════════════════════════════════════════ */}
        {currentRole === "retailer" && (
          <div className="w-full max-w-[430px] rounded-3xl border border-white/15 bg-[#1C1917] p-5 shadow-2xl">
            {/* Phone Header */}
            <div className="flex items-center justify-between border-b border-white/10 pb-4">
              <div>
                <p className="text-xs font-medium text-white/50">Profil Détaillant actif</p>
                <h2 className="text-base font-extrabold text-white">Hanout Moulay — Rabat</h2>
                <p className="text-[11px] text-white/40">Souk Al Had • +212 6 61 00 00 01</p>
              </div>
              <span className="rounded-full border border-emerald-500/30 bg-emerald-500/10 px-2.5 py-1 text-[10px] font-bold text-emerald-400">
                Connecté (Mock)
              </span>
            </div>

            {/* Carnet Solde (Rolling Debt Card) */}
            <div className="mt-4 rounded-2xl border border-[#FF6B00]/40 bg-gradient-to-br from-[#FF6B00]/15 via-black to-black p-4">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold uppercase tracking-wider text-[#FF6B00]">
                  Solde Carnet (Dette Rolling)
                </span>
                <span className="rounded bg-[#FF6B00]/20 px-2 py-0.5 text-[10px] font-bold text-[#FF6B00]">
                  À régler
                </span>
              </div>
              <div className="mt-2 flex items-baseline gap-1.5">
                <span className="text-3xl font-black text-white">4 250,75</span>
                <span className="text-sm font-bold text-[#FF6B00]">MAD</span>
              </div>
              <p className="mt-1 text-xs text-white/60">
                Chez <strong>Accessoires Pro Casablanca</strong> • Plafond: 15 000 MAD
              </p>

              <div className="mt-4 flex gap-2">
                <button
                  onClick={() => setPaymentDeclared(true)}
                  className="flex-1 rounded-xl bg-[#FF6B00] py-2 text-xs font-bold text-black transition hover:bg-[#ff8533]"
                >
                  {paymentDeclared ? "✓ Déclaration envoyée" : "Déclarer un versement"}
                </button>
                <a
                  href="https://wa.me/212522000000?text=Salam%20Accessoires%20Pro%2C%20je%20viens%20d%27effectuer%20un%20virement%20pour%20Hanout%20Moulay"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-center rounded-xl border border-white/15 bg-white/5 px-3 py-2 text-xs font-bold text-white hover:bg-white/10"
                >
                  <Phone className="h-3.5 w-3.5" />
                </a>
              </div>
              {paymentDeclared && (
                <p className="mt-2 text-center text-[11px] font-medium text-emerald-400">
                  Notification WhatsApp envoyée au grossiste avec preuve de versement.
                </p>
              )}
            </div>

            {/* Handshake Delivery Card */}
            <div className="mt-4 rounded-2xl border border-white/10 bg-black/40 p-4">
              <div className="flex items-center justify-between">
                <span className="flex items-center gap-1.5 text-xs font-bold text-white">
                  <ShieldCheck className="h-4 w-4 text-[#FF6B00]" />
                  Livraison PIN Handshake
                </span>
                <span className="text-[10px] font-semibold text-amber-400">Chauffeur en route</span>
              </div>
              <p className="mt-1 text-xs text-white/60">
                Commande n° CMD-2026-84 (24 articles). Entrez le code à 4 chiffres présenté par le livreur :
              </p>

              <div className="mt-3 flex items-center gap-2">
                <input
                  type="text"
                  maxLength={4}
                  placeholder="Ex: 7492"
                  value={pinEntered}
                  onChange={(e) => setPinEntered(e.target.value)}
                  className="h-10 w-28 rounded-xl border border-white/20 bg-white/5 text-center text-sm font-black tracking-widest text-white outline-none focus:border-[#FF6B00]"
                />
                <button
                  onClick={() => {
                    if (pinEntered === "7492") setHandshakeVerified(true);
                    else alert("Code PIN incorrect. Le code test du chauffeur est 7492.");
                  }}
                  className="h-10 flex-1 rounded-xl bg-white/10 text-xs font-bold text-white transition hover:bg-white/20"
                >
                  Valider la réception
                </button>
              </div>

              {handshakeVerified && (
                <div className="mt-3 rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-2 text-center text-xs font-bold text-emerald-400">
                  ✓ Livraison validée ! La dette est synchronisée au carnet.
                </div>
              )}
            </div>

            {/* Supplier Catalog Quick Look */}
            <div className="mt-4">
              <h3 className="text-xs font-bold text-white/50 uppercase tracking-wider mb-2">
                Catalogue Grossiste (Prix par quantité)
              </h3>
              <div className="space-y-2">
                {[
                  { name: "Coque Silicone iPhone 13/14", t1: "15 DH", t2: "12 DH (x10)", t3: "10 DH (x50)" },
                  { name: "Verre Trempé 9H Samsung A54", t1: "8 DH", t2: "6,5 DH (x20)", t3: "5 DH (x100)" },
                  { name: "Câble Type-C Tressé 60W", t1: "14 DH", t2: "11 DH (x15)", t3: "9 DH (x50)" },
                ].map((item) => (
                  <div
                    key={item.name}
                    className="flex items-center justify-between rounded-xl border border-white/5 bg-white/[0.02] p-2.5 text-xs"
                  >
                    <div>
                      <p className="font-bold text-white">{item.name}</p>
                      <p className="text-[10px] text-white/45">
                        {item.t1} • {item.t2} • {item.t3}
                      </p>
                    </div>
                    <button className="rounded-lg bg-[#FF6B00]/15 px-2 py-1 text-[11px] font-bold text-[#FF6B00] hover:bg-[#FF6B00] hover:text-black">
                      + Commander
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* ══════════════════════════════════════════════════════════════════════
            ROLE 2: SUPPLIER (ACCESSOIRES PRO CASABLANCA)
           ══════════════════════════════════════════════════════════════════════ */}
        {currentRole === "supplier" && (
          <div className="w-full max-w-4xl rounded-3xl border border-white/15 bg-[#1C1917] p-6 shadow-2xl">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between border-b border-white/10 pb-4 gap-3">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-[#FF6B00]">
                  Tableau de Bord Grossiste (Vue Desktop)
                </span>
                <h2 className="text-xl font-extrabold text-white">Accessoires Pro Casablanca</h2>
                <p className="text-xs text-white/50">Derb Omar, Entrepôt n°12 • 14 Hanouts partenaires actifs</p>
              </div>
              <div className="flex gap-2">
                <span className="rounded-xl border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-bold text-white">
                  Créances totales : <span className="text-[#FF6B00]">148 900 MAD</span>
                </span>
              </div>
            </div>

            {/* Quick Metrics */}
            <div className="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                <p className="text-xs font-medium text-white/50">Commandes du jour</p>
                <p className="text-2xl font-black text-white mt-1">18</p>
                <p className="text-[11px] text-emerald-400 mt-1">↑ +4 par rapport à hier</p>
              </div>
              <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                <p className="text-xs font-medium text-white/50">Livraisons en transit</p>
                <p className="text-2xl font-black text-amber-400 mt-1">6 chauffeurs</p>
                <p className="text-[11px] text-white/40 mt-1">Casablanca, Rabat, Fès</p>
              </div>
              <div className="rounded-2xl border border-white/10 bg-black/40 p-4">
                <p className="text-xs font-medium text-white/50">Règlements en attente</p>
                <p className="text-2xl font-black text-[#FF6B00] mt-1">12 450 MAD</p>
                <p className="text-[11px] text-white/40 mt-1">3 preuves WhatsApp reçues</p>
              </div>
            </div>

            {/* Wholesale Inventory Table */}
            <div className="mt-6">
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-bold text-white">Catalogue Stock & Paliers Grossiste</h3>
                <span className="text-xs text-white/50">Ajustement global prix : +0%</span>
              </div>

              <div className="overflow-x-auto rounded-2xl border border-white/10">
                <table className="w-full text-left text-xs">
                  <thead className="border-b border-white/10 bg-white/[0.03] text-white/60">
                    <tr>
                      <th className="p-3 font-semibold">Référence Produit</th>
                      <th className="p-3 font-semibold">Stock</th>
                      <th className="p-3 font-semibold">Prix Unitaire (1-9)</th>
                      <th className="p-3 font-semibold">Palier 1 (10-49)</th>
                      <th className="p-3 font-semibold">Palier Gros (50+)</th>
                      <th className="p-3 font-semibold text-right">Statut</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-white/5">
                    {[
                      { ref: "Écran OLED iPhone 13 Pro (Grade A)", stock: "140 pcs", p1: "135 DH", p2: "120 DH", p3: "110 DH", status: "Actif" },
                      { ref: "Chargeur Rapide 33W Type-C", stock: "320 pcs", p1: "42 DH", p2: "35 DH", p3: "29 DH", status: "Actif" },
                      { ref: "Écouteurs TWS Bluetooth 5.3", stock: "85 pcs", p1: "65 DH", p2: "52 DH", p3: "45 DH", status: "Actif" },
                      { ref: "Verre Trempé Confidentialité 14 Pro", stock: "600 pcs", p1: "12 DH", p2: "9,5 DH", p3: "7,5 DH", status: "Actif" },
                    ].map((row) => (
                      <tr key={row.ref} className="hover:bg-white/[0.02]">
                        <td className="p-3 font-bold text-white">{row.ref}</td>
                        <td className="p-3 text-white/70">{row.stock}</td>
                        <td className="p-3 text-white">{row.p1}</td>
                        <td className="p-3 text-emerald-400 font-semibold">{row.p2}</td>
                        <td className="p-3 text-[#FF6B00] font-bold">{row.p3}</td>
                        <td className="p-3 text-right">
                          <span className="rounded-full bg-emerald-500/10 px-2 py-0.5 text-[10px] font-bold text-emerald-400">
                            {row.status}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {/* ══════════════════════════════════════════════════════════════════════
            ROLE 3: DRIVER (KOURTIA HASSAN)
           ══════════════════════════════════════════════════════════════════════ */}
        {currentRole === "driver" && (
          <div className="w-full max-w-[430px] rounded-3xl border border-white/15 bg-[#1C1917] p-5 shadow-2xl">
            {/* Driver Header */}
            <div className="flex items-center justify-between border-b border-white/10 pb-4">
              <div>
                <p className="text-xs font-medium text-white/50">Espace Transporteur (Kourtia)</p>
                <h2 className="text-base font-extrabold text-white">Kourtia Hassan</h2>
                <p className="text-[11px] text-white/40">Secteur : Casablanca – Rabat • Moto / Triporteur</p>
              </div>
              <span className="rounded-full border border-[#FF6B00]/40 bg-[#FF6B00]/10 px-2.5 py-1 text-[10px] font-bold text-[#FF6B00]">
                En tournée
              </span>
            </div>

            {/* Active Delivery Job */}
            <div className="mt-4 rounded-2xl border border-[#FF6B00]/40 bg-gradient-to-br from-[#FF6B00]/20 via-black to-black p-4">
              <span className="text-[10px] font-black uppercase tracking-wider text-[#FF6B00]">
                Mission en cours • Course n° 2026-84
              </span>
              <h3 className="mt-1 text-base font-extrabold text-white">Derb Omar ➔ Souk Al Had, Rabat</h3>
              <p className="mt-1 text-xs text-white/60">Destinataire : Hanout Moulay (24 colis d&apos;accessoires)</p>

              {/* Secret Delivery PIN */}
              <div className="mt-4 rounded-xl border border-white/15 bg-black/60 p-3 text-center">
                <p className="text-[11px] font-bold text-white/50 uppercase">Code PIN à montrer au commerçant</p>
                <p className="text-3xl font-black tracking-widest text-[#FF6B00] mt-1">7492</p>
                <p className="text-[10px] text-white/40 mt-1">
                  Le client doit entrer ce code sur son téléphone pour valider la remise physique.
                </p>
              </div>

              {/* COD Fee */}
              <div className="mt-3 flex items-center justify-between text-xs pt-2 border-t border-white/10">
                <span className="text-white/60">Frais de transport négociés :</span>
                <span className="font-bold text-emerald-400">75,00 MAD</span>
              </div>
            </div>

            {/* Available Marketplace Bids */}
            <div className="mt-4">
              <h3 className="text-xs font-bold text-white/50 uppercase tracking-wider mb-2">
                Missions Ouvertes aux Enchères (Marketplace)
              </h3>
              <div className="space-y-2">
                {[
                  { from: "Garage Allal, Casa", to: "Médina, Fès", packages: "3 cartons", est: "120 - 160 MAD" },
                  { from: "Derb Ghallef, Casa", to: "Océan, Rabat", packages: "1 carton", est: "60 - 80 MAD" },
                ].map((bid) => (
                  <div
                    key={bid.from}
                    className="rounded-xl border border-white/10 bg-black/40 p-3 text-xs"
                  >
                    <div className="flex justify-between items-center">
                      <p className="font-bold text-white">{bid.from} ➔ {bid.to}</p>
                      <span className="font-extrabold text-[#FF6B00]">{bid.est}</span>
                    </div>
                    <p className="text-[10px] text-white/45 mt-1">{bid.packages} • Prêt à charger</p>
                    <button className="mt-2 w-full rounded-lg bg-white/10 py-1.5 font-bold text-white hover:bg-white/20">
                      Proposer une offre de livraison
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </main>
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
