import Link from "next/link";
import { ArrowRight, Store, Truck, TrendingUp } from "lucide-react";

export function MoroccanHero() {
  return (
    <section className="relative overflow-hidden px-4 pb-20 pt-10 sm:pb-28 sm:pt-16">
      <div
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_85%_55%_at_50%_-15%,rgba(255,107,0,0.2),transparent_55%)]"
        aria-hidden
      />
      <div className="relative mx-auto max-w-4xl text-center">
        <p className="mb-5 inline-flex items-center rounded-full border border-white/15 bg-white/[0.04] px-3 py-1 text-xs font-bold uppercase tracking-[0.15em] text-[#FF6B00]">
          Marché marocain
        </p>
        <h1 className="text-4xl font-extrabold leading-[1.1] tracking-tight text-white sm:text-5xl md:text-6xl lg:text-[3.25rem]">
          Connecting Moroccan Suppliers with Local Retailers.
        </h1>
        <p className="mx-auto mt-6 max-w-3xl text-base font-medium leading-relaxed text-white/85 sm:text-lg">
          We provide a free market for supply chain and logistics to help suppliers and retailers grow together.
        </p>
        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row sm:gap-4">
          <Link
            href="/register"
            className="inline-flex h-12 min-w-[200px] items-center justify-center gap-2 rounded-full bg-[#FF6B00] px-8 text-sm font-bold text-black shadow-[0_0_40px_-4px_rgba(255,107,0,0.65),0_10px_40px_-12px_rgba(255,107,0,0.35)] transition hover:bg-[#ff8533] hover:shadow-[0_0_48px_-2px_rgba(255,107,0,0.5)]"
          >
            Get Started
            <ArrowRight className="h-4 w-4" aria-hidden />
          </Link>
          <Link
            href="/prototype"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex h-12 min-w-[200px] items-center justify-center rounded-full border-2 border-white bg-transparent px-8 text-sm font-bold text-white transition hover:bg-white hover:text-black"
          >
            View Prototype
          </Link>
        </div>
      </div>

      <div className="relative mx-auto mt-16 grid max-w-4xl gap-4 sm:grid-cols-3">
        {[
          {
            icon: Store,
            title: "Fournisseurs & grossistes",
            subtitle: "Catalogue visible partout au Maroc",
          },
          {
            icon: Truck,
            title: "Logistique suivie",
            subtitle: "Du dépôt jusqu’au hanout",
          },
          {
            icon: TrendingUp,
            title: "Croissance partagée",
            subtitle: "Confiance numérique, dette claire",
          },
        ].map(({ icon: Icon, title, subtitle }) => (
          <div
            key={title}
            className="rounded-2xl border border-white/12 bg-white/[0.03] p-5 text-center shadow-[0_0_32px_-8px_rgba(255,107,0,0.25)] backdrop-blur-sm"
          >
            <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-xl border border-[#FF6B00]/40 bg-[#FF6B00]/10 text-[#FF6B00]">
              <Icon className="h-6 w-6" strokeWidth={2} aria-hidden />
            </div>
            <p className="mt-3 text-sm font-bold text-white">{title}</p>
            <p className="mt-1 text-xs font-medium text-white/65">{subtitle}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
