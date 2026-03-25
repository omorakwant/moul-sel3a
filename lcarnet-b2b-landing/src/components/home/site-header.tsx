import Link from "next/link";
import { Menu } from "lucide-react";

const nav = [
  { href: "/#marche", label: "Le marché" },
  { href: "/#logistique", label: "Logistique" },
  { href: "/#carnet", label: "L'Carnet" },
  { href: "/#tarifs", label: "Tarifs" },
];

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 border-b border-white/10 bg-black/85 backdrop-blur-md">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between gap-4 px-4 sm:h-16">
        <Link
          href="/"
          className="text-sm font-bold tracking-tight text-white sm:text-base"
        >
          L&apos;Carnet <span className="text-[#FF6B00]">B2B</span>
        </Link>
        <nav className="hidden items-center gap-8 md:flex" aria-label="Principal">
          {nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="text-sm font-semibold text-white/85 transition hover:text-[#FF6B00]"
            >
              {item.label}
            </Link>
          ))}
          <Link
            href="/app"
            target="_blank"
            className="text-sm font-semibold text-white/70 transition hover:text-white"
          >
            Prototype
          </Link>
          <Link
            href="/register"
            className="rounded-full bg-[#FF6B00] px-4 py-2 text-sm font-bold text-black shadow-[0_0_24px_-4px_rgba(255,107,0,0.55)] transition hover:bg-[#ff8533]"
          >
            S&apos;inscrire
          </Link>
        </nav>
        <div className="flex items-center gap-2 md:hidden">
          <Link
            href="/register"
            className="rounded-full bg-[#FF6B00] px-3 py-1.5 text-xs font-bold text-black"
          >
            S&apos;inscrire
          </Link>
          <details className="relative">
            <summary className="list-none cursor-pointer rounded-lg border border-white/15 p-2 text-white">
              <Menu className="h-5 w-5" aria-hidden />
            </summary>
            <div className="absolute right-0 mt-2 flex min-w-[200px] flex-col gap-1 rounded-xl border border-white/10 bg-black py-2 shadow-xl">
              {nav.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="px-4 py-2 text-sm font-semibold text-white hover:bg-white/5"
                >
                  {item.label}
                </Link>
              ))}
              <Link
                href="/app"
                target="_blank"
                className="px-4 py-2 text-sm font-semibold text-white/80 hover:bg-white/5"
              >
                Prototype
              </Link>
            </div>
          </details>
        </div>
      </div>
    </header>
  );
}
