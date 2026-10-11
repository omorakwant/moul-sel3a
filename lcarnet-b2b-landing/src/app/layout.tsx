import type { Metadata } from "next";
import { Manrope, Inter } from "next/font/google";
import "./globals.css";
import { WhatsAppButton } from "@/components/ui/whatsapp-button";

const manrope = Manrope({
  variable: "--font-manrope",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
});

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: "L'Carnet B2B — Marché & logistique pour pros au Maroc",
  description:
    "Connectez fournisseurs et détaillants. Marketplace transparente, logistique suivie, carnet digital pour le commerce B2B marocain.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="fr"
      className={`${manrope.variable} ${inter.variable} h-full scroll-smooth antialiased`}
    >
      <body className="min-h-full flex flex-col bg-black text-white font-sans">
        {children}
        <WhatsAppButton />
      </body>
    </html>
  );
}
