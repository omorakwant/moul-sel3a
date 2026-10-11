"use client";

import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, ExternalLink, RefreshCw, Store, Truck, BookOpen } from "lucide-react";

function PrototypeViewer() {
  const searchParams = useSearchParams();
  const initialRole = searchParams.get("role") || "retailer";
  const [currentRole, setCurrentRole] = useState(initialRole);
  const [isLoading, setIsLoading] = useState(true);

  // Read configured Flutter URL or default to relative subpath /prototype/index.html
  const flutterBaseUrl =
    process.env.NEXT_PUBLIC_FLUTTER_APP_URL?.replace(/\/$/, "") || "";

  // Compute iframe target URL
  const targetSrc = flutterBaseUrl
    ? `${flutterBaseUrl}/#/${currentRole === "supplier" ? "supplier/dashboard" : currentRole === "driver" ? "driver/marketplace" : "retailer/dashboard"}`
    : `/prototype/index.html?role=${currentRole}`;

  const roles = [
    { id: "retailer", label: "Détaillant (Hanout)", icon: BookOpen },
    { id: "supplier", label: "Fournisseur (Grossiste)", icon: Store },
    { id: "driver", label: "Transporteur (Chauffeur)", icon: Truck },
  ];

  return (
    <div className="flex h-screen w-screen flex-col bg-black text-white">
      {/* Top Navigation & Role Control Bar */}
      <header className="flex h-14 shrink-0 items-center justify-between border-b border-white/10 bg-black/90 px-4 backdrop-blur-md">
        <div className="flex items-center gap-4">
          <Link
            href="/"
            className="flex items-center gap-2 rounded-lg border border-white/15 bg-white/[0.04] px-3 py-1.5 text-xs font-semibold text-white/90 transition hover:border-[#FF6B00]/60 hover:text-[#FF6B00]"
          >
            <ArrowLeft className="h-4 w-4" />
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

        {/* Role Switcher in Header */}
        <div className="flex items-center gap-1 sm:gap-2">
          <span className="mr-1 hidden text-xs font-medium text-white/50 md:inline">
            Tester un rôle :
          </span>
          {roles.map((r) => {
            const Icon = r.icon;
            const active = currentRole === r.id;
            return (
              <button
                key={r.id}
                onClick={() => {
                  setCurrentRole(r.id);
                  setIsLoading(true);
                }}
                className={`flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-bold transition ${
                  active
                    ? "bg-[#FF6B00] text-black shadow-[0_0_16px_rgba(255,107,0,0.4)]"
                    : "border border-white/10 bg-white/[0.03] text-white/70 hover:border-white/20 hover:text-white"
                }`}
              >
                <Icon className="h-3.5 w-3.5" />
                <span className="hidden sm:inline">{r.label}</span>
                <span className="sm:hidden">{r.id.toUpperCase()}</span>
              </button>
            );
          })}

          <a
            href={targetSrc}
            target="_blank"
            rel="noopener noreferrer"
            title="Ouvrir dans un nouvel onglet"
            className="ml-2 hidden rounded-lg border border-white/15 p-2 text-white/60 transition hover:border-white/30 hover:text-white lg:inline-flex"
          >
            <ExternalLink className="h-4 w-4" />
          </a>
        </div>
      </header>

      {/* Main Interactive Prototype Container */}
      <main className="relative flex-1 bg-[#1C1917]">
        {isLoading && (
          <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-[#000000]">
            <div className="flex h-16 w-16 animate-pulse items-center justify-center rounded-2xl bg-[#FF6B00] text-3xl font-extrabold text-black shadow-[0_0_40px_rgba(255,107,0,0.5)]">
              ل
            </div>
            <p className="mt-4 text-sm font-bold text-white">
              Initialisation du prototype Flutter Web...
            </p>
            <p className="mt-1 text-xs text-white/50">
              Rôle actif : <span className="text-[#FF6B00] capitalize">{currentRole}</span>
            </p>
            <div className="mt-6 h-1 w-48 overflow-hidden rounded-full bg-white/10">
              <div className="h-full w-full animate-[marquee_1.5s_linear_infinite] bg-[#FF6B00]" />
            </div>
          </div>
        )}

        <iframe
          src={targetSrc}
          className="h-full w-full border-0"
          title="L'Carnet B2B Functional Prototype"
          allow="camera; microphone; geolocation"
          onLoad={() => setIsLoading(false)}
        />
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
      <PrototypeViewer />
    </Suspense>
  );
}
