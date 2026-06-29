"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { Sparkles } from "lucide-react";
import { ScrollReveal } from "@/components/scroll-reveal";
import { AnimatedText, AnimatedReveal } from "@/components/animated-text";

export function About() {
  return (
    <section
      id="about"
      className="py-20 md:py-28 border-t border-border/40 overflow-hidden"
    >
      <div className="container mx-auto max-w-screen-2xl px-6">
        <div className="max-w-3xl mx-auto text-center space-y-6">
          <ScrollReveal direction="right">
            <AnimatedReveal
              as="h2"
              className="text-xs font-bold tracking-widest text-violet-500 uppercase"
            >
              The Problem
            </AnimatedReveal>
            <h3 className="text-3xl font-bold tracking-tight mt-3">
              <AnimatedText
                text="Studying should not depend on perfect internet or expensive AI tools."
                stagger={0.05}
              />
            </h3>
          </ScrollReveal>
          <ScrollReveal direction="right" delay={0.1}>
            <AnimatedReveal
              as="p"
              delay={0.2}
              className="text-base sm:text-lg text-muted-foreground leading-relaxed"
            >
              Students often have notes scattered across PDFs, text files,
              screenshots, notebooks, and different apps. Revising everything
              manually takes time, and many AI tools require internet access or
              ask students to upload private study material to external servers.
            </AnimatedReveal>
            <p className="text-base sm:text-lg text-muted-foreground leading-relaxed mt-4">
              Gurukula AI gives students a calmer way to study from their own
              content with a local-first workflow designed around privacy,
              revision, and student productivity.
            </p>
          </ScrollReveal>
          <ScrollReveal direction="right" delay={0.2}>
            <div className="pt-4 flex flex-wrap items-center justify-center gap-4">
              {[
                "Privacy First",
                "Local First",
                "Offline Focused",
                "Student Focused",
                "On-device OCR",
                "Fallback-Safe AI",
              ].map((tag, i) => (
                <motion.span
                  key={tag}
                  initial={{ opacity: 0, y: 10 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: false }}
                  transition={{ delay: 0.2 + i * 0.1, duration: 0.4 }}
                  className="inline-flex items-center px-6 py-2.5 rounded-full text-base font-bold border border-violet-500/40 bg-violet-500/10 text-violet-600 dark:text-violet-400 shadow-sm shadow-violet-500/10"
                >
                  {tag}
                </motion.span>
              ))}
            </div>
          </ScrollReveal>
        </div>
      </div>
    </section>
  );
}
