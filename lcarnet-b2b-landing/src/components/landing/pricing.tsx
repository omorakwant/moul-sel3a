import Link from "next/link";
import { Check } from "lucide-react";

const TIERS = [
  {
    name: "Starter",
    price: "990",
    period: "/mo",
    description: "For lean teams getting serious about B2B ops.",
    features: [
      "Up to 5 seats",
      "Core analytics",
      "Email support",
      "Standard integrations",
    ],
    cta: "Start trial",
    highlighted: false,
  },
  {
    name: "Pro",
    price: "2,490",
    period: "/mo",
    description: "The complete platform for scaling revenue teams.",
    features: [
      "Unlimited seats",
      "Real-time analytics & alerts",
      "SSO & audit logs",
      "Priority support & SLAs",
      "Full integration suite",
    ],
    cta: "Get Pro",
    highlighted: true,
  },
  {
    name: "Enterprise",
    price: "Custom",
    period: "",
    description: "Dedicated success, security reviews, and custom contracts.",
    features: [
      "Dedicated CSM",
      "Custom data residency",
      "Advanced compliance",
      "24/7 phone support",
    ],
    cta: "Contact sales",
    highlighted: false,
  },
];

export function Pricing() {
  return (
    <section id="pricing" className="scroll-mt-24 px-4 py-20 sm:py-28">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-semibold tracking-tight text-white sm:text-4xl">
            Simple, transparent pricing
          </h2>
          <p className="mt-4 text-zinc-400">
            Start fast on Starter, scale on Pro, or go bespoke with Enterprise.
          </p>
        </div>
        <div className="mt-14 grid gap-6 lg:grid-cols-3">
          {TIERS.map((tier) => (
            <div
              key={tier.name}
              className={`relative flex flex-col rounded-2xl border p-8 ${
                tier.highlighted
                  ? "border-indigo-500/50 bg-gradient-to-b from-indigo-500/[0.12] to-transparent shadow-[0_0_60px_-12px_rgba(99,102,241,0.45)] lg:scale-[1.02] lg:z-10"
                  : "border-white/[0.08] bg-white/[0.02]"
              }`}
            >
              {tier.highlighted && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-indigo-500 px-3 py-0.5 text-xs font-semibold text-white">
                  Most popular
                </span>
              )}
              <h3 className="text-lg font-semibold text-white">{tier.name}</h3>
              <p className="mt-2 text-sm text-zinc-500">{tier.description}</p>
              <div className="mt-6 flex items-baseline gap-1">
                {tier.price !== "Custom" && (
                  <span className="text-sm text-zinc-500">MAD</span>
                )}
                <span className="text-4xl font-semibold tracking-tight text-white">
                  {tier.price}
                </span>
                <span className="text-zinc-500">{tier.period}</span>
              </div>
              <ul className="mt-8 flex-1 space-y-3 text-sm text-zinc-400">
                {tier.features.map((f) => (
                  <li key={f} className="flex gap-2">
                    <Check
                      className="mt-0.5 h-4 w-4 shrink-0 text-indigo-400"
                      aria-hidden
                    />
                    {f}
                  </li>
                ))}
              </ul>
              <Link
                href="#demo"
                className={`mt-8 inline-flex h-11 items-center justify-center rounded-full text-sm font-semibold transition ${
                  tier.highlighted
                    ? "bg-indigo-500 text-white hover:bg-indigo-400"
                    : "border border-white/15 bg-white/[0.04] text-white hover:bg-white/[0.08]"
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
