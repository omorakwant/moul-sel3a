import {
  MoroccanFooter,
  MoroccanHero,
  MoroccanMarquee,
  MoroccanPricing,
  MoroccanSolutions,
  SiteHeader,
} from "@/components/home";

export default function Home() {
  return (
    <div className="flex min-h-full flex-1 flex-col bg-black">
      <SiteHeader />
      <main className="flex-1">
        <MoroccanHero />
        <MoroccanMarquee />
        <MoroccanSolutions />
        <MoroccanPricing />
      </main>
      <MoroccanFooter />
    </div>
  );
}
