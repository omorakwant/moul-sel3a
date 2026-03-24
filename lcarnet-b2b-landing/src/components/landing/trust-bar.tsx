const BRANDS = [
  "Northwind",
  "Atlas Group",
  "Magenta",
  "Vertex Labs",
  "Helio Systems",
  "Cedar Trade",
  "Nova Logistics",
  "Silverline",
];

export function TrustBar() {
  const items = [...BRANDS, ...BRANDS];
  return (
    <section
      className="border-y border-white/[0.06] bg-[#080808] py-10"
      aria-label="Trusted by teams at"
    >
      <p className="mb-6 text-center text-xs font-medium uppercase tracking-[0.2em] text-zinc-600">
        Trusted by modern enterprises
      </p>
      <div className="relative overflow-hidden">
        <div className="flex w-max animate-[marquee_40s_linear_infinite] gap-16 md:gap-24">
          {items.map((name, i) => (
            <span
              key={`${name}-${i}`}
              className="shrink-0 select-none text-lg font-semibold tracking-tight text-zinc-500 grayscale sm:text-xl"
            >
              {name}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
