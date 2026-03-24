import { CheckCircle2 } from "lucide-react";

const STEPS = [
  { title: "Onboard & verify", detail: "KYC, credit limits, and buyer roles in one flow." },
  { title: "Quote to order", detail: "Structured catalogs, tiers, and approvals your reps love." },
  { title: "Fulfill & reconcile", detail: "Shipments, invoices, and cash application stay in sync." },
];

export function WorkflowSection() {
  return (
    <section
      id="workflow"
      className="scroll-mt-24 border-t border-white/[0.06] px-4 py-20 sm:py-28"
    >
      <div className="mx-auto grid max-w-6xl gap-12 lg:grid-cols-2 lg:gap-16 lg:items-center">
        <div className="order-2 lg:order-1">
          <div className="relative rounded-2xl border border-white/[0.08] bg-gradient-to-br from-zinc-900/80 to-black p-6 shadow-[0_0_80px_-24px_rgba(99,102,241,0.35)]">
            <div className="absolute inset-0 rounded-2xl bg-[radial-gradient(ellipse_at_30%_20%,rgba(99,102,241,0.12),transparent_50%)]" />
            <ol className="relative space-y-0">
              {STEPS.map((step, i) => (
                <li key={step.title} className="flex gap-4">
                  <div className="flex flex-col items-center">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-indigo-500/40 bg-indigo-500/15 text-sm font-semibold text-indigo-200">
                      {i + 1}
                    </div>
                    {i < STEPS.length - 1 && (
                      <div className="my-1 w-px flex-1 min-h-[2rem] bg-gradient-to-b from-indigo-500/50 to-transparent" />
                    )}
                  </div>
                  <div className="pb-8 pt-1">
                    <p className="font-semibold text-white">{step.title}</p>
                    <p className="mt-1 text-sm text-zinc-500">{step.detail}</p>
                  </div>
                </li>
              ))}
            </ol>
            <div className="relative mt-2 flex items-center gap-2 rounded-xl border border-white/[0.06] bg-white/[0.03] p-4">
              <CheckCircle2 className="h-5 w-5 shrink-0 text-emerald-400" aria-hidden />
              <p className="text-sm text-zinc-400">
                <span className="font-medium text-zinc-200">Closed loop:</span>{" "}
                Every step emits events your BI and ERP can consume.
              </p>
            </div>
          </div>
        </div>
        <div className="order-1 lg:order-2">
          <p className="text-xs font-semibold uppercase tracking-[0.2em] text-indigo-400/90">
            How it works
          </p>
          <h2 className="mt-3 text-3xl font-semibold tracking-tight text-white sm:text-4xl">
            A B2B process your teams can actually follow
          </h2>
          <p className="mt-4 text-lg text-zinc-400">
            Replace fragmented tools with a single path from first quote to final
            payment—clear ownership, fewer handoffs, and audit-ready history by
            default.
          </p>
          <ul className="mt-8 space-y-3 text-zinc-400">
            {[
              "Role-based workflows with escalation",
              "Immutable timeline for disputes and finance",
              "Operational metrics tied to revenue outcomes",
            ].map((item) => (
              <li key={item} className="flex gap-3">
                <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-indigo-500" />
                {item}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
