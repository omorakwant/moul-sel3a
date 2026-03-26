"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Mail, MapPin, Phone } from "lucide-react";

export function MoroccanContact() {
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setStatus("loading");

    const form = e.currentTarget;
    const data = new FormData(form);

    try {
      // Replace YOUR_FORM_ID with the actual Formspree ID
      const response = await fetch("https://formspree.io/f/YOUR_FORM_ID", {
        method: "POST",
        body: data,
        headers: {
          Accept: "application/json",
        },
      });

      if (response.ok) {
        setStatus("success");
        form.reset();
      } else {
        setStatus("error");
      }
    } catch (error) {
      setStatus("error");
    }
  };

  return (
    <section className="bg-black px-4 py-20 sm:py-28" id="contact">
      <div className="mx-auto max-w-6xl">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="grid gap-12 lg:grid-cols-2 lg:gap-8"
        >
          {/* Left Side: Contact Info */}
          <div className="flex flex-col justify-center">
            <h2 className="text-3xl font-extrabold tracking-tight text-white sm:text-4xl md:text-5xl">
              Get in Touch
            </h2>
            <p className="mt-4 max-w-xl text-base font-medium text-white/70 sm:text-lg">
              Ready to transform your supply chain? Have questions about our marketplace? 
              Reach out to the L&apos;Carnet B2B team.
            </p>

            <div className="mt-10 space-y-6">
              <div className="flex items-center gap-4">
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-white/10 bg-white/5 text-[#FF6B00]">
                  <Mail className="h-6 w-6" aria-hidden />
                </div>
                <div>
                  <p className="text-sm font-medium text-white/50">Email</p>
                  <p className="text-base font-semibold text-white">contact@lcarnetb2b.ma</p>
                </div>
              </div>

              <div className="flex items-center gap-4">
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-white/10 bg-white/5 text-[#FF6B00]">
                  <MapPin className="h-6 w-6" aria-hidden />
                </div>
                <div>
                  <p className="text-sm font-medium text-white/50">Location</p>
                  <p className="text-base font-semibold text-white">Benguerir / Casablanca, Morocco</p>
                </div>
              </div>

              <div className="flex items-center gap-4">
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-white/10 bg-white/5 text-[#FF6B00]">
                  <Phone className="h-6 w-6" aria-hidden />
                </div>
                <div>
                  <p className="text-sm font-medium text-white/50">Phone</p>
                  <p className="text-base font-semibold text-white">+212 6XX-XXXXXX</p>
                </div>
              </div>
            </div>
          </div>

          {/* Right Side: Functional Form */}
          <div className="rounded-2xl border border-white/10 bg-[#0a0a0a] p-6 shadow-2xl sm:p-10">
            {status === "success" ? (
              <motion.div 
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="flex h-full min-h-[300px] flex-col items-center justify-center text-center"
              >
                <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-[#FF6B00]/20 text-[#FF6B00]">
                  <Mail className="h-8 w-8" />
                </div>
                <h3 className="text-2xl font-bold text-white">Shukran!</h3>
                <p className="mt-2 text-white/80">
                  We have received your request and will contact you shortly.
                </p>
                <button
                  onClick={() => setStatus("idle")}
                  className="mt-8 rounded-full border border-white/20 bg-transparent px-6 py-2 text-sm font-bold text-white transition hover:bg-white hover:text-black"
                >
                  Send another message
                </button>
              </motion.div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-5">
                <div className="grid gap-5 sm:grid-cols-2">
                  <div className="flex flex-col gap-1.5">
                    <label htmlFor="name" className="text-sm font-medium text-white/80">
                      Full Name
                    </label>
                    <input
                      required
                      type="text"
                      id="name"
                      name="name"
                      placeholder="Youssef..."
                      className="rounded-lg border border-white/20 bg-black px-4 py-3 text-sm text-white outline-none transition focus:border-[#FF6B00] focus:ring-1 focus:ring-[#FF6B00]"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label htmlFor="company" className="text-sm font-medium text-white/80">
                      Company Name
                    </label>
                    <input
                      required
                      type="text"
                      id="company"
                      name="company"
                      placeholder="Epicerie XYZ..."
                      className="rounded-lg border border-white/20 bg-black px-4 py-3 text-sm text-white outline-none transition focus:border-[#FF6B00] focus:ring-1 focus:ring-[#FF6B00]"
                    />
                  </div>
                </div>

                <div className="grid gap-5 sm:grid-cols-2">
                  <div className="flex flex-col gap-1.5">
                    <label htmlFor="email" className="text-sm font-medium text-white/80">
                      Email Address
                    </label>
                    <input
                      required
                      type="email"
                      id="email"
                      name="email"
                      placeholder="youssef@example.com"
                      className="rounded-lg border border-white/20 bg-black px-4 py-3 text-sm text-white outline-none transition focus:border-[#FF6B00] focus:ring-1 focus:ring-[#FF6B00]"
                    />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label htmlFor="phone" className="text-sm font-medium text-white/80">
                      Phone Number
                    </label>
                    <input
                      required
                      type="tel"
                      id="phone"
                      name="phone"
                      placeholder="+212 612 345 678"
                      className="rounded-lg border border-white/20 bg-black px-4 py-3 text-sm text-white outline-none transition focus:border-[#FF6B00] focus:ring-1 focus:ring-[#FF6B00]"
                    />
                  </div>
                </div>

                <div className="flex flex-col gap-1.5">
                  <label htmlFor="message" className="text-sm font-medium text-white/80">
                    Message
                  </label>
                  <textarea
                    required
                    id="message"
                    name="message"
                    rows={4}
                    placeholder="How can we help your business grow?"
                    className="resize-none rounded-lg border border-white/20 bg-black px-4 py-3 text-sm text-white outline-none transition focus:border-[#FF6B00] focus:ring-1 focus:ring-[#FF6B00]"
                  />
                </div>

                {status === "error" && (
                  <p className="text-sm text-red-500">
                    Something went wrong. Please try again or email us directly.
                  </p>
                )}

                <button
                  type="submit"
                  disabled={status === "loading"}
                  className="mt-2 inline-flex h-12 w-full items-center justify-center rounded-lg bg-[#FF6B00] px-8 text-base font-bold text-white transition hover:bg-white hover:text-[#FF6B00] disabled:cursor-not-allowed disabled:opacity-70"
                >
                  {status === "loading" ? "Sending..." : "Submit Message"}
                </button>
              </form>
            )}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
