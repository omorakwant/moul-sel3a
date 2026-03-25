import Link from "next/link";
import { Check } from "lucide-react";

const TIERS = [
  {
    name: "Basic Merchant",
    price: "0",
    period: " pour commencer",
    description:
      "Pour le détaillant ou le petit hanout qui veut voir les fournisseurs et commander clair.",
    features: [
      "Accès au catalogue grossistes partenaires",
      "Demandes de devis simples",
      "Suivi basique des commandes",
      "Notification livraison",
    ],
    cta: "Créer un compte",
    highlighted: false,
  },
  {
    name: "Growing Wholesaler",
    price: "899",
    period: "/mois",
    description:
      "Pour le grossiste qui scale : plus de références, logistique et carnet digital.",
    features: [
      "Vitrine produits illimitée (fair use)",
      "Outils logistique & transporteurs",
      "Carnet crédit digital + relances",
      "Support prioritaire (FR / Darija)",
      "Exports pour la compta",
    ],
    cta: "Essayer ce plan",
    highlighted: true,
  },
  {
    name: "Réseau & import",
    price: "Sur mesure",
    period: "",
    description:
      "Importateurs et chaînes : intégrations, volumes, conditions dédiées.",
    features: [
      "SLA et chef de compte",
      "API / synchro stock (selon besoin)",
      "Multisites & permissions avancées",
      "Facturation centralisée",
    ],
    cta: "Nous contacter",
    highlighted: false,
  },
];

export function MoroccanPricing() {
  return (
    <section id="tarifs" className="scroll-mt-24 border-t border-white/10 px-4 py-20 sm:py-28">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-extrabold tracking-tight text-white sm:text-4xl">
            Tarifs pensés pour les PME marocaines
          </h2>
          <p className="mx-auto mt-4 max-w-2xl text-base font-medium text-white/70">
            Montants en dirhams (MAD), TVA selon votre statut. Commencez gratuit,
            montez en gamme quand votre volume le demande.
          </p>
        </div>
        <div className="mt-14 grid gap-6 lg:grid-cols-3">
          {TIERS.map((tier) => (
            <div
              key={tier.name}
              className={`relative flex flex-col rounded-2xl border p-8 ${
                tier.highlighted
                  ? "border-[#FF6B00]/55 bg-gradient-to-b from-[#FF6B00]/[0.12] to-transparent shadow-[0_0_60px_-12px_rgba(255,107,0,0.4)] lg:z-10 lg:scale-[1.02]"
                  : "border-white/10 bg-white/[0.02]"
              }`}
            >
              {tier.highlighted && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-[#FF6B00] px-3 py-0.5 text-xs font-bold text-black">
                  Le plus choisi
                </span>
              )}
              <h3 className="text-lg font-extrabold text-white">{tier.name}</h3>
              <p className="mt-2 text-sm font-medium text-white/55">
                {tier.description}
              </p>
              <div className="mt-6 flex flex-wrap items-baseline gap-1">
                {tier.price !== "Sur mesure" && (
                  <span className="text-sm font-bold text-[#FF6B00]">MAD</span>
                )}
                <span className="text-4xl font-extrabold tracking-tight text-white">
                  {tier.price}
                </span>
                <span className="text-white/50">{tier.period}</span>
              </div>
              <ul className="mt-8 flex-1 space-y-3 text-sm font-medium text-white/70">
                {tier.features.map((f) => (
                  <li key={f} className="flex gap-2">
                    <Check
                      className="mt-0.5 h-4 w-4 shrink-0 text-[#FF6B00]"
                      aria-hidden
                    />
                    {f}
                  </li>
                ))}
              </ul>
              <Link
                href="/register"
                className={`mt-8 inline-flex h-11 items-center justify-center rounded-full text-sm font-bold transition ${
                  tier.highlighted
                    ? "bg-[#FF6B00] text-black hover:bg-[#ff8533]"
                    : "border-2 border-white bg-transparent text-white hover:bg-white hover:text-black"
                }`}
              >
                {tier.cta}
              </Link>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
