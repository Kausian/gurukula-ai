"use client"

import * as React from "react"
import { AnimatePresence, motion } from "framer-motion"
import { BookOpen, Menu, X, ArrowUp } from "lucide-react"
import Image from "next/image"

import { Button } from "@/components/ui/button"
import { ThemeToggle } from "@/components/theme-toggle"

// Import modular section components
import { Hero } from "@/components/sections/hero"
import { Features } from "@/components/sections/features"
import { WhyUs } from "@/components/sections/why-us"
import { HowItWorks } from "@/components/sections/how-it-works"
import { Benefits } from "@/components/sections/benefits"
import { About } from "@/components/sections/about"
import { FAQ } from "@/components/sections/faq"
import { CTA } from "@/components/sections/cta"

export default function Home() {
  const [mobileMenuOpen, setMobileMenuOpen] = React.useState(false)
  const [showSplash, setShowSplash] = React.useState(true)
  const [showScrollTop, setShowScrollTop] = React.useState(false)

  React.useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 300) {
        setShowScrollTop(true)
      } else {
        setShowScrollTop(false)
      }
    }
    window.addEventListener("scroll", handleScroll)
    return () => window.removeEventListener("scroll", handleScroll)
  }, [])

  React.useEffect(() => {
    if (showSplash) {
      document.body.style.overflow = "hidden"
    } else {
      document.body.style.overflow = ""
    }

    const timer = setTimeout(() => {
      setShowSplash(false)
    }, 2000)
    
    return () => {
      clearTimeout(timer)
      document.body.style.overflow = ""
    }
  }, [showSplash])

  // Smooth scroll handler
  const scrollToSection = (id: string) => {
    setMobileMenuOpen(false)
    const element = document.getElementById(id)
    if (element) {
      element.scrollIntoView({ behavior: "smooth" })
    }
  }

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  return (
    <>
      <AnimatePresence>
        {showSplash && (
          <motion.div
            key="splash"
            initial={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.5 }}
            className="fixed inset-0 z-[100] flex flex-col items-center justify-center bg-[#5b1ee6]"
          >
            <Image
              src="/loading.jpeg"
              alt="Gurukula AI Splash"
              fetchPriority="high"
              width={200}
              height={200}
              className="object-contain rounded-2xl shadow-2xl animate-pulse mb-8"
              priority
            />
            {/* <motion.h1 
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2, duration: 0.5 }}
              className="text-3xl md:text-5xl font-extrabold tracking-widest text-transparent bg-clip-text bg-gradient-to-r from-violet-700 via-violet-500 to-violet-400 uppercase"
            >
              Gurukula AI
            </motion.h1> */}
          </motion.div>
        )}
      </AnimatePresence>

      <div className="flex flex-col min-h-screen px-4 sm:px-6 lg:px-10">
      {/* Sticky Header */}
      <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/80 backdrop-blur-md transition-all duration-300">
        <div className="container mx-auto flex h-16 max-w-screen-2xl items-center justify-between px-6">
          <div className="flex items-center space-x-2.5 cursor-pointer" onClick={() => scrollToSection("hero")}>
            <div className="relative flex h-9 w-9 items-center justify-center rounded-xl overflow-hidden shadow-lg shadow-violet-500/20">
              <Image src="/logo.jpeg" alt="Gurukula AI Logo" width={36} height={36} className="object-cover" />
              <span className="absolute -top-1 -right-1 flex h-2.5 w-2.5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
              </span>
            </div>
            {/* <span className="text-lg font-bold tracking-tight bg-gradient-to-r from-foreground via-foreground/90 to-muted-foreground bg-clip-text text-transparent">
              Gurukula <span className="text-violet-500">AI</span>
            </span> */}
          </div>

          {/* Desktop Nav Links */}
          <nav className="hidden md:flex space-x-6 text-sm font-medium text-muted-foreground">
            {[
              { id: "features", label: "features" },
              { id: "why-us", label: "why us" },
              { id: "how-it-works", label: "how it works" },
              { id: "benefits", label: "benefits" },
              { id: "faq", label: "FAQ" }
            ].map((item) => (
              <button
                key={item.id}
                onClick={() => scrollToSection(item.id)}
                className="hover:text-foreground capitalize transition-colors duration-200 cursor-pointer"
              >
                {item.label}
              </button>
            ))}
          </nav>

          <div className="hidden md:flex items-center space-x-4">
            <ThemeToggle />
            <Button
              size="sm"
              onClick={() => scrollToSection("download")}
              className="bg-violet-600 text-white hover:bg-violet-500 shadow-md shadow-violet-600/10 text-xs font-semibold cursor-pointer"
            >
              Download APK
            </Button>
          </div>

          {/* Mobile Menu Actions */}
          <div className="flex items-center space-x-2 md:hidden">
            <ThemeToggle />
            <Button
              variant="ghost"
              size="icon"
              className="h-9 w-9 rounded-lg"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              {mobileMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </Button>
          </div>
        </div>
      </header>

      {/* Mobile Drawer */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3 }}
            className="md:hidden border-b border-border bg-card/95 backdrop-blur-md overflow-hidden"
          >
            <div className="container mx-auto px-4 py-4 flex flex-col space-y-3.5">
              {[
                { id: "features", label: "features" },
                { id: "why-us", label: "why us" },
                { id: "how-it-works", label: "how it works" },
                { id: "benefits", label: "benefits" },
                { id: "faq", label: "FAQ" }
              ].map((item) => (
                <button
                  key={item.id}
                  onClick={() => scrollToSection(item.id)}
                  className="text-left text-sm font-medium text-muted-foreground hover:text-foreground py-2 capitalize border-b border-border/50 last:border-0"
                >
                  {item.label}
                </button>
              ))}
              <div className="flex flex-col gap-2 pt-2">
                <Button
                  variant="outline"
                  onClick={() => scrollToSection("download")}
                  className="w-full text-xs font-semibold"
                >
                  Learn More
                </Button>
                <Button
                  onClick={() => scrollToSection("download")}
                  className="w-full bg-violet-600 text-white hover:bg-violet-500 text-xs font-semibold"
                >
                  Download App
                </Button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Main Content Sections */}
      <main className="flex-1">
        <Hero scrollToSection={scrollToSection} />
        <Features />
        <WhyUs />
        <HowItWorks />
        <Benefits />
        <About />
        <FAQ />
        <CTA />
      </main>

      {/* Footer */}
      <footer className="border-t border-border/40 bg-muted/20 py-8 text-xs text-muted-foreground">
        <div className="container mx-auto max-w-screen-2xl px-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center space-x-2">
            <div className="flex h-6 w-6 items-center justify-center overflow-hidden rounded-lg">
              <Image src="/logo.jpeg" alt="Gurukula AI Logo" width={24} height={24} className="object-cover" />
            </div>
            <span className="font-bold text-foreground">Gurukula AI</span>
          </div>
          <p>© {new Date().getFullYear()} Gurukula AI. All rights reserved. Created for students with privacy in mind.</p>
          <div className="flex space-x-4">
            <a href="#" className="hover:text-foreground transition-colors">Privacy Policy</a>
            <a href="#" className="hover:text-foreground transition-colors">Terms of Service</a>
            <a href="#" className="hover:text-foreground transition-colors">Documentation</a>
          </div>
        </div>
      </footer>

      {/* Scroll to Top Button */}
      <AnimatePresence>
        {showScrollTop && (
          <motion.button
            initial={{ opacity: 0, scale: 0.8, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.8, y: 20 }}
            onClick={scrollToTop}
            className="fixed bottom-6 right-6 z-50 p-3 rounded-full bg-violet-600 text-white shadow-lg shadow-violet-600/30 hover:bg-violet-500 hover:-translate-y-1 transition-all duration-300"
            aria-label="Scroll to top"
          >
            <ArrowUp className="w-5 h-5" />
          </motion.button>
        )}
      </AnimatePresence>
    </div>
    </>
  )
}
