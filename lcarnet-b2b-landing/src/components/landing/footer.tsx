import Link from "next/link";

function IconX({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
  );
}

function IconLinkedIn({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
    </svg>
  );
}

function IconGitHub({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
    </svg>
  );
}

const PRODUCT_LINKS = [
  { label: "Features", href: "#features" },
  { label: "Workflow", href: "#workflow" },
  { label: "Pricing", href: "#pricing" },
  { label: "Security", href: "#" },
];

const COMPANY_LINKS = [
  { label: "About", href: "#" },
  { label: "Careers", href: "#" },
  { label: "Blog", href: "#" },
  { label: "Contact", href: "#demo" },
];

const RESOURCE_LINKS = [
  { label: "Documentation", href: "#" },
  { label: "API status", href: "#" },
  { label: "Changelog", href: "#" },
  { label: "Partners", href: "#" },
];

export function Footer() {
  return (
    <footer
      id="demo"
      className="scroll-mt-24 border-t border-white/[0.06] bg-[#050505] px-4 py-16"
    >
      <div className="mx-auto grid max-w-6xl gap-12 sm:grid-cols-2 lg:grid-cols-4">
        <div>
          <p className="text-lg font-semibold tracking-tight text-white">
            L&apos;Carnet B2B
          </p>
          <p className="mt-3 text-sm leading-relaxed text-zinc-500">
            The enterprise surface for orders, credit, and logistics—built for teams
            who ship at scale.
          </p>
          <div className="mt-6 flex gap-3">
            <a
              href="https://twitter.com"
              className="flex h-9 w-9 items-center justify-center rounded-lg border border-white/10 text-zinc-400 transition hover:border-white/20 hover:text-white"
              aria-label="X (Twitter)"
            >
              <IconX className="h-4 w-4" />
            </a>
            <a
              href="https://linkedin.com"
              className="flex h-9 w-9 items-center justify-center rounded-lg border border-white/10 text-zinc-400 transition hover:border-white/20 hover:text-white"
              aria-label="LinkedIn"
            >
              <IconLinkedIn className="h-4 w-4" />
            </a>
            <a
              href="https://github.com"
              className="flex h-9 w-9 items-center justify-center rounded-lg border border-white/10 text-zinc-400 transition hover:border-white/20 hover:text-white"
              aria-label="GitHub"
            >
              <IconGitHub className="h-4 w-4" />
            </a>
          </div>
        </div>
        <div>
          <p className="text-xs font-semibold uppercase tracking-wider text-zinc-500">
            Product
          </p>
          <ul className="mt-4 space-y-2">
            {PRODUCT_LINKS.map((link) => (
              <li key={link.label}>
                <Link
                  href={link.href}
                  className="text-sm text-zinc-400 transition hover:text-white"
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
        <div>
          <p className="text-xs font-semibold uppercase tracking-wider text-zinc-500">
            Company
          </p>
          <ul className="mt-4 space-y-2">
            {COMPANY_LINKS.map((link) => (
              <li key={link.label}>
                <Link
                  href={link.href}
                  className="text-sm text-zinc-400 transition hover:text-white"
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
          <p className="mt-8 text-xs font-semibold uppercase tracking-wider text-zinc-500">
            Resources
          </p>
          <ul className="mt-4 space-y-2">
            {RESOURCE_LINKS.map((link) => (
              <li key={link.label}>
                <Link
                  href={link.href}
                  className="text-sm text-zinc-400 transition hover:text-white"
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
        <div>
          <p className="text-xs font-semibold uppercase tracking-wider text-zinc-500">
            Newsletter
          </p>
          <p className="mt-4 text-sm text-zinc-500">
            Product updates—no fluff, one email a month.
          </p>
          <form className="mt-4 flex flex-col gap-2 sm:flex-row" noValidate>
            <label htmlFor="newsletter-email" className="sr-only">
              Email
            </label>
            <input
              id="newsletter-email"
              type="email"
              name="email"
              placeholder="you@company.com"
              className="h-10 w-full rounded-lg border border-white/10 bg-white/[0.04] px-3 text-sm text-white placeholder:text-zinc-600 outline-none focus:border-indigo-500/50 focus:ring-1 focus:ring-indigo-500/30"
            />
            <button
              type="button"
              className="h-10 shrink-0 rounded-lg bg-white px-4 text-sm font-semibold text-black transition hover:bg-zinc-200"
            >
              Subscribe
            </button>
          </form>
        </div>
      </div>
      <div className="mx-auto mt-14 flex max-w-6xl flex-col items-center justify-between gap-4 border-t border-white/[0.06] pt-8 text-xs text-zinc-600 sm:flex-row">
        <p>© {new Date().getFullYear()} L&apos;Carnet B2B. All rights reserved.</p>
        <div className="flex gap-6">
          <Link href="#" className="hover:text-zinc-400">
            Privacy
          </Link>
          <Link href="#" className="hover:text-zinc-400">
            Terms
          </Link>
        </div>
      </div>
    </footer>
  );
}
