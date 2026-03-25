import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { SiteHeader } from "@/components/home/site-header";
import { MoroccanFooter } from "@/components/home/moroccan-footer";

export default function RegisterPage() {
  return (
    <div className="flex min-h-full flex-col bg-black">
      <SiteHeader />
      <main className="mx-auto flex w-full max-w-lg flex-1 flex-col justify-center px-4 py-16">
        <h1 className="text-center text-3xl font-extrabold text-white sm:text-4xl">
          Join the marketplace
        </h1>
        <p className="mt-4 text-center text-base font-medium text-white/70">
          Créez votre compte fournisseur, détaillant ou transporteur. Le flux
          complet d&apos;inscription arrive ici très bientôt — en attendant,
          explorez le prototype ou contactez-nous.
        </p>
        <div className="mt-10 flex flex-col gap-3">
          <Link
            href="/prototype"
            className="flex h-12 items-center justify-center gap-2 rounded-full border-2 border-[#FF6B00] bg-[#FF6B00] text-sm font-bold text-black shadow-[0_0_32px_-4px_rgba(255,107,0,0.45)] transition hover:bg-[#ff8533]"
          >
            View live prototype
            <ArrowRight className="h-4 w-4" aria-hidden />
          </Link>
          <Link
            href="/"
            className="flex h-12 items-center justify-center rounded-full border-2 border-white text-sm font-bold text-white transition hover:bg-white hover:text-black"
          >
            Back to home
          </Link>
        </div>
      </main>
      <MoroccanFooter />
    </div>
  );
}
