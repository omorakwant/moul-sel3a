import type { ReactNode } from "react";
import type { LucideIcon } from "lucide-react";
import { BookOpen, Store, Truck } from "lucide-react";

const sections: {
  id: string;
  icon: LucideIcon;
  title: string;
  headline: string;
  body: ReactNode;
}[] = [
  {
    id: "marche",
    icon: Store,
    title: "Le marché",
    headline:
      "Des grossistes directement connectés aux hanouts et détaillants du quartier.",
    body: (
      <>
        L&apos;Carnet B2B rapproche les importateurs et grossistes des commerces
        de proximité partout au Maroc. Vos références, vos prix, votre fiabilité
        : visibles pour les détaillants qui en ont besoin — sans intermédiaires
        opaques.
      </>
    ),
  },
  {
    id: "logistique",
    icon: Truck,
    title: "Logistique",
    headline:
      "Une vitrine pour les transporteurs : affréter, suivre, livrer avec transparence.",
    body: (
      <>
        Les prestataires logistiques proposent leurs trajets et capacités sur la
        plateforme. Du pickup chez le fournisseur jusqu&apos;au hanout, les
        mouvements sont tracés pour que marchands et transporteurs sachent où en
        sont les marchandises, sans appels interminables.
      </>
    ),
  },
  {
    id: "carnet",
    icon: BookOpen,
    title: "Le carnet digital",
    headline:
      "Du cahier papier au carnet numérique : crédit et dette rolling, lisibles.",
    body: (
      <>
        On remplace le petit carnet griffonné par un suivi clair : qui doit quoi, à
        qui, et jusqu&apos;à quand. Moins d&apos;erreurs, moins de litiges, plus
        de confiance entre fournisseur et détaillant — la base d&apos;une relation
        B2B saine au Maroc.
      </>
    ),
  },
];

export function MoroccanSolutions() {
  return (
    <section className="px-4 py-20 sm:py-28">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-extrabold tracking-tight text-white sm:text-4xl">
            Une solution née du terrain marocain
          </h2>
          <p className="mt-4 text-base font-medium text-white/70">
            Marché, transport et crédit B2B : les trois piliers pour faire tourner
            la boutique et le dépôt.
          </p>
        </div>
        <div className="mt-16 flex flex-col gap-16">
          {sections.map((s, i) => (
            <article
              key={s.id}
              id={s.id}
              className={`scroll-mt-28 grid gap-10 lg:grid-cols-2 lg:items-center ${
                i % 2 === 1 ? "lg:flex-row-reverse" : ""
              }`}
            >
              <div className={i % 2 === 1 ? "lg:order-2" : ""}>
                <div className="inline-flex items-center gap-2 rounded-full border border-[#FF6B00]/35 bg-[#FF6B00]/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-[#FF6B00]">
                  <s.icon className="h-4 w-4" strokeWidth={2} aria-hidden />
                  {s.title}
                </div>
                <h3 className="mt-4 text-2xl font-extrabold text-white sm:text-3xl">
                  {s.headline}
                </h3>
                <div className="mt-4 text-base font-medium leading-relaxed text-white/70">
                  {s.body}
                </div>
              </div>
              <div
                className={`rounded-2xl border border-white/12 bg-gradient-to-br from-white/[0.06] to-transparent p-8 shadow-[0_0_48px_-12px_rgba(255,107,0,0.2)] ${
                  i % 2 === 1 ? "lg:order-1" : ""
                }`}
              >
                <div className="flex h-40 flex-col items-center justify-center gap-3 text-center sm:h-48">
                  <div className="flex h-16 w-16 items-center justify-center rounded-2xl border border-[#FF6B00]/40 bg-black text-[#FF6B00]">
                    <s.icon className="h-8 w-8" strokeWidth={1.75} aria-hidden />
                  </div>
                  <p className="text-sm font-bold text-white/50">{s.title}</p>
                </div>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
