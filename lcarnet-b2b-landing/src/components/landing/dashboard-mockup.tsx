import {
  BarChart3,
  CreditCard,
  Package,
  TrendingUp,
} from "lucide-react";

export function DashboardMockup() {
  return (
    <div
      className="relative mx-auto w-full max-w-4xl [perspective:1200px]"
      style={{ perspectiveOrigin: "50% 30%" }}
    >
      <div
        className="relative origin-center transform-gpu rounded-2xl border border-white/[0.12] bg-gradient-to-b from-zinc-900/95 via-[#0d0d0f] to-black p-4 shadow-[0_50px_100px_-20px_rgba(0,0,0,0.85),0_0_60px_-15px_rgba(99,102,241,0.35)] backdrop-blur-sm transition-transform sm:p-6 md:animate-[float_6s_ease-in-out_infinite] md:[transform:rotateX(12deg)_rotateY(-8deg)]"
      >
        <div className="absolute inset-0 rounded-2xl bg-[radial-gradient(ellipse_at_50%_0%,rgba(99,102,241,0.15),transparent_55%)] pointer-events-none" />
        <div className="relative flex flex-col gap-4">
          <div className="flex flex-wrap items-center justify-between gap-3 border-b border-white/[0.06] pb-4">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-500/20 text-indigo-300">
                <BarChart3 className="h-5 w-5" aria-hidden />
              </div>
              <div>
                <p className="text-sm font-semibold text-white">Operations</p>
                <p className="text-xs text-zinc-500">Live overview</p>
              </div>
            </div>
            <div className="flex gap-2">
              <span className="rounded-full bg-emerald-500/15 px-2.5 py-1 text-xs font-medium text-emerald-400">
                Synced
              </span>
            </div>
          </div>
          <div className="grid gap-3 sm:grid-cols-3">
            {[
              { label: "Revenue MTD", value: "2.4M MAD", icon: TrendingUp },
              { label: "Open invoices", value: "128", icon: CreditCard },
              { label: "Active SKUs", value: "3,402", icon: Package },
            ].map(({ label, value, icon: Icon }) => (
              <div
                key={label}
                className="rounded-xl border border-white/[0.06] bg-white/[0.03] p-3"
              >
                <div className="mb-2 flex items-center gap-2 text-zinc-500">
                  <Icon className="h-4 w-4" aria-hidden />
                  <span className="text-xs">{label}</span>
                </div>
                <p className="text-lg font-semibold tracking-tight text-white">
                  {value}
                </p>
              </div>
            ))}
          </div>
          <div className="grid gap-3 md:grid-cols-[1fr_1.2fr]">
            <div className="flex flex-col rounded-xl border border-white/[0.06] bg-white/[0.02] p-4">
              <p className="text-xs font-medium text-zinc-500">Fulfillment</p>
              <div className="mt-4 flex h-28 items-end justify-between gap-2">
                {[72, 88, 64, 91, 78].map((h, i) => (
                  <div
                    key={i}
                    className="flex-1 rounded-t-sm bg-gradient-to-t from-indigo-600/50 to-indigo-400/90"
                    style={{ height: `${h}%` }}
                  />
                ))}
              </div>
            </div>
            <div className="rounded-xl border border-white/[0.06] bg-white/[0.02] p-4">
              <p className="text-xs font-medium text-zinc-500">Recent activity</p>
              <ul className="mt-3 space-y-2 text-sm">
                {[
                  "Invoice #4402 paid — Atlas Retail",
                  "PO synced from ERP",
                  "Shipment confirmed — Casablanca",
                ].map((line) => (
                  <li
                    key={line}
                    className="flex items-center gap-2 border-l-2 border-indigo-500/50 pl-3 text-zinc-400"
                  >
                    {line}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
