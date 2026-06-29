import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";

const urwGeometric = localFont({
  src: [
    {
      path: "./fonts/URWGeometricLight.otf",
      weight: "300",
      style: "normal",
    },
    {
      path: "./fonts/URWGeometricRegular.otf",
      weight: "400",
      style: "normal",
    },
    {
      path: "./fonts/URWGeometricMedium.otf",
      weight: "500",
      style: "normal",
    },
    {
      path: "./fonts/URWGeometricBold.otf",
      weight: "700",
      style: "normal",
    },
  ],
});

export const metadata: Metadata = {
  title: "Gurukula AI | Your Offline-First AI Learning Assistant",
  description: "Gurukula AI is a private, offline-first AI learning assistant for students. Study, summarize documents, create flashcards, and organize knowledge without needing an internet connection.",
  keywords: ["offline AI", "AI study assistant", "student AI helper", "private AI", "document summarization", "local learning assistant", "flashcard generator"],
  authors: [{ name: "Gurukula AI Team" }],
  openGraph: {
    title: "Gurukula AI | Offline AI Learning Assistant",
    description: "Study, brainstorm, and organize knowledge with privacy-first offline AI. No internet required.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${urwGeometric.className} h-full antialiased`}
      suppressHydrationWarning
    >
      <head>
        {/* Preload Critical CSS - Helps with render-blocking */}
        <link
          rel="preload"
          href="/_next/static/css/2s_ntibu-127a.css" 
          as="style"
        />
      </head>
      
      <body className="min-h-full flex flex-col bg-background text-foreground transition-colors duration-300">
        <ThemeProvider
          attribute="class"
          defaultTheme="light"
          enableSystem={false}
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}

