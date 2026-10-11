"use client";

import Link from "next/link";
import { ArrowLeft, BookOpen, Store, Truck, Globe, WifiOff } from "lucide-react";
import { RoleType, LangType } from "../types";

interface PrototypeHeaderProps {
  lang: LangType;
  setLang: (lang: LangType) => void;
  currentRole: RoleType;
  setCurrentRole: (role: RoleType) => void;
  offlineSimulated: boolean;
  setOfflineSimulated: (simulated: boolean) => void;
  cur: Record<string, string>;
}

export function PrototypeHeader({
  lang,
  setLang,
  currentRole,
  setCurrentRole,
  offlineSimulated,
  setOfflineSimulated,
  cur,
}: PrototypeHeaderProps) {
  return (
    <>
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
    </>
  );
}
