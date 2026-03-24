import type { LucideIcon } from "lucide-react";
import {
  BarChart3,
  FileText,
  PlugZap,
  ShieldCheck,
  Workflow,
  Zap,
} from "lucide-react";

const PRIMARY = [
  {
    title: "Real-time Analytics",
    description:
      "Live dashboards and cohort views so revenue, risk, and fulfillment stay aligned.",
    icon: BarChart3,
  },
  {
    title: "Automated Invoicing",
    description:
      "Rules-based billing, reminders, and reconciliation—without spreadsheet chaos.",
    icon: FileText,
  },
  {
    title: "Seamless Integration",
    description:
      "ERP, CRM, and banking connectors with resilient sync and observability.",
    icon: PlugZap,
  },
];

const SECONDARY = [
  {
    title: "Enterprise Security",
    description:
      "SSO, audit trails, and least-privilege roles designed for regulated workflows.",
    icon: ShieldCheck,
  },
  {
    title: "Workflow Automation",
    description:
      "Orchestrate approvals, POs, and exceptions with guardrails your ops team trusts.",
    icon: Workflow,
  },
  {
    title: "Low-latency Events",
    description:
      "Stream updates across teams the moment status changes—no refresh tax.",
    icon: Zap,
  },
];

function FeatureCard({
  title,
  description,
  icon: Icon,
}: {
  title: string;
  description: string;
  icon: LucideIcon;
}) {
  return (
    <article
      className="group relative overflow-hidden rounded-2xl border border-white/[0.08] bg-white/[0.03] p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.03)_inset] backdrop-blur-xl transition hover:border-indigo-500/30 hover:shadow-[0_0_40px_-12px_rgba(99,102,241,0.35)]"
    >
      <div className="absolute -right-8 -top-8 h-32 w-32 rounded-full bg-indigo-500/10 blur-2xl transition group-hover:bg-indigo-500/20" />
      <div className="relative flex h-10 w-10 items-center justify-center rounded-xl border border-white/10 bg-white/[0.06] text-indigo-300">
        <Icon className="h-5 w-5" aria-hidden />
      </div>
      <h3 className="relative mt-4 text-lg font-semibold text-white">{title}</h3>
      <p className="relative mt-2 text-sm leading-relaxed text-zinc-400">{description}</p>
    </article>
  );
}

export function BentoFeatures() {
  return (
    <section id="features" className="scroll-mt-24 px-4 py-20 sm:py-28">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-semibold tracking-tight text-white sm:text-4xl">
            Everything your B2B stack was missing
          </h2>
          <p className="mt-4 text-zinc-400">
            A cohesive control plane—analytics, money movement, and integrations
            in one premium surface.
          </p>
        </div>
        <div className="mt-14 grid gap-4 md:grid-cols-3">
          {PRIMARY.map((f) => (
            <FeatureCard key={f.title} {...f} />
          ))}
        </div>
        <div className="mt-4 grid gap-4 md:grid-cols-3">
          {SECONDARY.map((f) => (
            <FeatureCard key={f.title} {...f} />
          ))}
        </div>
      </div>
    </section>
  );
}
