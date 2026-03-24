import {
  BentoFeatures,
  Footer,
  Hero,
  Pricing,
  TrustBar,
  WorkflowSection,
} from "@/components/landing";

export default function Home() {
  return (
    <div className="flex min-h-full flex-1 flex-col">
      <main className="flex-1">
        <Hero />
        <TrustBar />
        <BentoFeatures />
        <WorkflowSection />
        <Pricing />
      </main>
      <Footer />
    </div>
  );
}
