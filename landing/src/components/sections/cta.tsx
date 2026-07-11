"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { Mail, Lock, Code2, Info } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ScrollReveal } from "@/components/scroll-reveal";
import { AnimatedText, AnimatedReveal } from "@/components/animated-text";

export function CTA() {
  const [selectedPlatform, setSelectedPlatform] = React.useState("iOS");

  return (
    <section
      id="download"
      className="py-20 md:py-28 border-t border-border/40 relative overflow-hidden bg-radial from-violet-500/10 via-transparent to-transparent"
    >
      {/* Animated background blob */}
      <motion.div
        animate={{
          scale: [1, 1.15, 1],
          opacity: [0.4, 0.7, 0.4],
        }}
        transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 -z-10 h-96 w-96 rounded-full bg-violet-500/10 blur-3xl"
      />

      <div className="container mx-auto max-w-screen-2xl px-6 text-center space-y-8">
        <div className="space-y-4">
          <h2 className="text-3xl sm:text-4xl font-extrabold tracking-tight">
            <AnimatedText
              text="Build a better revision habit from your own notes."
              stagger={0.05}
            />
          </h2>
          <AnimatedReveal
            as="p"
            delay={0.35}
            className="text-muted-foreground text-base sm:text-lg max-w-lg mx-auto leading-relaxed"
          >
            Import your study material, generate revision tools, and keep
            everything organized locally with Gurukula AI.
          </AnimatedReveal>
        </div>

        <ScrollReveal
          direction="up"
          delay={0.15}
          className="max-w-md mx-auto p-6 rounded-2xl border border-border bg-card/60 backdrop-blur-sm space-y-5"
        >
          <div className="space-y-1.5">
            <h3 className="text-lg font-bold text-foreground">
              Explore Gurukula AI on GitHub.
            </h3>
            <p className="text-sm text-muted-foreground">
              View the project repository for details, source code,
              documentation, and APK releases.
            </p>
          </div>

          <div className="pt-2">
            <motion.div whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
              <Button
                asChild
                size="lg"
                className="w-full bg-violet-600 hover:bg-violet-500 text-white font-bold h-11 shadow-md shadow-violet-600/15 cursor-pointer"
              >
                <a
                  href="https://github.com/Kausian/gurukula-ai"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <Code2 className="w-4 h-4 mr-2" /> View on GitHub
                </a>
              </Button>
            </motion.div>
          </div>

          <div className="flex items-start space-x-2 pt-3 border-t border-border/50 text-left">
            <Info className="w-4 h-4 text-violet-500 shrink-0 mt-0.5" />
            <p className="text-xs text-muted-foreground leading-tight">
              APK releases, documentation, and source code are all available on
              the GitHub repository.
            </p>
          </div>
        </ScrollReveal>

        <ScrollReveal
          direction="none"
          delay={0.25}
          className="flex items-center justify-center gap-6 text-sm text-muted-foreground pt-4"
        >
          <a
            href="mailto:support@gurukula.ai"
            className="hover:text-foreground transition-colors flex items-center space-x-1.5"
          >
            <Mail className="w-4 h-4" />
            <span>Contact Support</span>
          </a>
          <span>•</span>
          <a
            href="#"
            className="hover:text-foreground transition-colors flex items-center space-x-1.5"
          >
            <Lock className="w-4 h-4" />
            <span>Security Details</span>
          </a>
        </ScrollReveal>
      </div>
    </section>
  );
}
