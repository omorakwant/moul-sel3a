import Link from "next/link";
import { ArrowRight, Sparkles } from "lucide-react";
import { DashboardMockup } from "./dashboard-mockup";

export function Hero() {
  return (
    <section className="relative overflow-hidden px-4 pb-16 pt-10 sm:pb-24 sm:pt-16 md:pt-24">
      <div
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_80%_50%_at_50%_-20%,rgba(99,102,241,0.22),transparent)]"
        aria-hidden
      />
      <div className="relative mx-auto max-w-5xl text-center">
        <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-white/[0.08] bg-white/[0.04] px-3 py-1.5 text-xs font-medium text-zinc-400 backdrop-blur-md">
          <Sparkles className="h-3.5 w-3.5 text-indigo-400" aria-hidden />
          Built for enterprise B2B teams
        </div>
        <h1 className="mx-auto max-w-4xl text-4xl font-semibold leading-[1.08] tracking-tight text-white sm:text-5xl md:text-6xl lg:text-7xl">
          <span className="bg-gradient-to-br from-white via-zinc-100 to-indigo-400/90 bg-clip-text text-transparent">
            L&apos;Carnet B2B
          </span>
          <br />
          <span className="mt-2 inline-block text-zinc-300">
            Command your supply chain in real time
          </span>
        </h1>
        <p className="mx-auto mt-6 max-w-2xl text-base leading-relaxed text-zinc-400 sm:text-lg">
          Unify orders, credit, and logistics on one premium platform—so your
          teams move faster with full visibility from quote to cash.
        </p>
        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row sm:gap-5">
          <Link
            href="#pricing"
            className="group inline-flex h-12 min-w-[180px] items-center justify-center gap-2 rounded-full bg-indigo-500 px-8 text-sm font-semibold text-white shadow-[0_0_40px_-4px_rgba(99,102,241,0.65),0_8px_32px_-8px_rgba(99,102,241,0.45)] transition hover:bg-indigo-400 hover:shadow-[0_0_48px_-2px_rgba(129,140,248,0.75)]"
          >
            Get Started
            <ArrowRight className="h-4 w-4 transition group-hover:translate-x-0.5" aria-hidden />
          </Link>
          <Link
            href="#demo"
            className="inline-flex h-12 min-w-[180px] items-center justify-center rounded-full border border-white/[0.12] bg-white/[0.03] px-8 text-sm font-semibold text-zinc-200 backdrop-blur-sm transition hover:border-white/20 hover:bg-white/[0.06]"
          >
            Book a Demo
          </Link>
        </div>
      </div>
      <div className="relative mx-auto mt-16 max-w-5xl px-2 sm:mt-20">
        <div className="absolute -inset-x-10 -bottom-20 h-40 bg-[radial-gradient(ellipse_at_center,rgba(99,102,241,0.2),transparent_70%)] blur-2xl" aria-hidden />
        <DashboardMockup />
      </div>
    </section>
  );
}
