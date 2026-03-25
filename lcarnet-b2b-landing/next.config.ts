import type { NextConfig } from "next";

const flutterBase =
  process.env.NEXT_PUBLIC_FLUTTER_APP_URL?.replace(/\/+$/, "") ?? "";

const nextConfig: NextConfig = {
  async redirects() {
    if (!flutterBase) return [];
    return [
      {
        source: "/prototype",
        destination: `${flutterBase}/`,
        permanent: false,
      },
    ];
  },
};

export default nextConfig;
