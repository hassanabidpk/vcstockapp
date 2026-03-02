import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ClientProviders } from "./providers";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "VC Stocks - Portfolio Tracker",
  description: "Track your US, SG stocks and crypto portfolio",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body className={`${inter.className} bg-slate-950 text-white min-h-screen`}>
        <ClientProviders>
          <div className="max-w-7xl mx-auto">{children}</div>
        </ClientProviders>
      </body>
    </html>
  );
}
