const PLACES = [
  "Casablanca",
  "Rabat",
  "Fès",
  "Marrakech",
  "Tanger",
  "Agadir",
  "Meknès",
  "Oujda",
  "Kénitra",
  "Tétouan",
  "Salé",
  "Mohammedia",
];

export function MoroccanMarquee() {
  const row = [...PLACES, ...PLACES];
  return (
    <section
      className="border-y border-white/10 bg-[#050505] py-8"
      aria-label="Villes desservies"
    >
      <p className="mb-5 text-center text-[11px] font-bold uppercase tracking-[0.25em] text-[#FF6B00]/90">
        Ensemble sur tout le Royaume
      </p>
      <div className="relative overflow-hidden">
        <div className="flex w-max animate-[marquee_38s_linear_infinite] gap-12 md:gap-20">
          {row.map((city, i) => (
            <span
              key={`${city}-${i}`}
              className="shrink-0 text-base font-bold text-white/35 sm:text-lg"
            >
              {city}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
