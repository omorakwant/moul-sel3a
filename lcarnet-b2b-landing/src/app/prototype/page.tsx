import Link from "next/link";
import { ExternalLink } from "lucide-react";

/**
 * Shown only when NEXT_PUBLIC_FLUTTER_APP_URL is not set at build time.
 * Otherwise next.config.ts redirects /prototype → Flutter app (Hanout / role switcher).
 */
export default function PrototypeFallbackPage() {
  return (
    <div className="min-h-screen bg-black px-4 py-16 text-white">
      <div className="mx-auto max-w-lg text-center">
        <p className="text-xs font-bold uppercase tracking-[0.2em] text-[#FF6B00]">
          Configuration
        </p>
        <h1 className="mt-3 text-2xl font-extrabold">
          Lier le prototype Flutter
        </h1>
        <p className="mt-4 text-sm font-medium leading-relaxed text-white/70">
          L&apos;application fonctionnelle (tableaux de bord, retailer / supplier /
          driver, données mock) est le build{" "}
          <strong className="text-white">Flutter Web</strong> dans{" "}
          <code className="rounded bg-white/10 px-1 text-[#FF6B00]">app/</code>, pas
          une page React dans ce dossier.
        </p>
        <ol className="mt-6 list-decimal space-y-2 pl-5 text-left text-sm font-medium text-white/75">
          <li>
            Déployez le repo avec{" "}
            <strong className="text-white">Root Directory = .</strong> (racine) et
            le build Flutter (voir <code className="text-[#FF6B00]">vercel.json</code>{" "}
            à la racine du monorepo).
          </li>
          <li>
            Copiez l&apos;URL publique (ex.{" "}
            <code className="text-white/90">…vercel.app</code>).
          </li>
          <li>
            Dans le projet Vercel <strong className="text-white">landing</strong>
            , ajoutez la variable{" "}
            <code className="text-[#FF6B00]">NEXT_PUBLIC_FLUTTER_APP_URL</code>{" "}
            avec cette URL, puis redéployez.
          </li>
        </ol>
        <p className="mt-6 text-xs text-white/50">
          Voir <code className="text-white/70">lcarnet-b2b-landing/.env.example</code>{" "}
          et la section marketing dans <code className="text-white/70">DEPLOY_VERCEL.md</code>.
        </p>
        <div className="mt-10 flex flex-col gap-3 sm:flex-row sm:justify-center">
          <Link
            href="/"
            className="inline-flex items-center justify-center gap-2 rounded-full border-2 border-white px-6 py-3 text-sm font-bold text-white transition hover:bg-white hover:text-black"
          >
            Retour à l&apos;accueil
          </Link>
          <a
            href="https://github.com/omorakwant/moul-sel3a"
            className="inline-flex items-center justify-center gap-2 rounded-full border-2 border-[#FF6B00] bg-[#FF6B00] px-6 py-3 text-sm font-bold text-black transition hover:bg-[#ff8533]"
            target="_blank"
            rel="noopener noreferrer"
          >
            Dépôt GitHub
            <ExternalLink className="h-4 w-4" aria-hidden />
          </a>
        </div>
      </div>
    </div>
  );
}
