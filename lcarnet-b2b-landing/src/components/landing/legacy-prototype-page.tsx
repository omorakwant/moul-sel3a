import { BentoFeatures } from "./bento-features";
import { Footer } from "./footer";
import { Hero } from "./hero";
import { Pricing } from "./pricing";
import { TrustBar } from "./trust-bar";
import { WorkflowSection } from "./workflow-section";

/** Earlier “enterprise” style landing — shown at /prototype */
export function LegacyPrototypePage() {
  return (
    <>
      <main className="flex-1 bg-[#0A0A0A]">
        <Hero />
        <TrustBar />
        <BentoFeatures />
        <WorkflowSection />
        <Pricing />
      </main>
      <Footer />
    </>
  );
}
