import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { LegacyPrototypePage } from "@/components/landing/legacy-prototype-page";

export default function PrototypePage() {
  return (
    <div className="flex min-h-full flex-col">
      <div className="border-b border-white/10 bg-[#0A0A0A] px-4 py-3">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3">
          <p className="text-sm font-medium text-white/80">
            <span className="font-bold text-indigo-400">Prototype</span> —
            version exploratoire (style product / enterprise). La marque live est
            sur{" "}
            <Link href="/" className="font-semibold text-white underline">
              l&apos;accueil
            </Link>
            .
          </p>
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-sm font-semibold text-white/90 hover:text-white"
          >
            <ArrowLeft className="h-4 w-4" aria-hidden />
            Retour accueil L&apos;Carnet B2B
          </Link>
        </div>
      </div>
      <LegacyPrototypePage />
    </div>
  );
}
