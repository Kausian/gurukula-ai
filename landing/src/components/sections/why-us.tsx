"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { CheckCircle2 } from "lucide-react";
import { ScrollReveal } from "@/components/scroll-reveal";
import { AnimatedText, AnimatedReveal } from "@/components/animated-text";

export function WhyUs() {
  const comparisonRows = [
    {
      label: "Works offline ",
      local: "Core study workflow is offline-focused after setup.",
      cloud: "Usually requires internet access.",
    },
    {
      label: "Study data control",
      local: "Study content is stored locally on the device.",
      cloud: "Study content may be sent to external servers.",
    },
    {
      label: "Student-focused workflow",
      local:
        "Built around notes, summaries, flashcards, quizzes, revision, and ideas.",
      cloud: " General purpose AI chat experience.",
    },
    {
      label: "OCR support",
      local: "Camera and gallery OCR for printed English notes.",
      cloud: "Usually requires uploading files/images.",
    },
    {
      label: "Cost",
      local: "No paid cloud AI API required.",
      cloud: "Many tools have usage limits or paid plans.",
    },
    {
      label: "Distraction level",
      local: "Focused mobile study workspace.",
      cloud: "Browser-based tools can be distracting.",
    },
    {
      label: "Fallback behavior",
      local: "App remains usable even when on-device AI is unsupported.",
      cloud: "Cloud tools require service availability.",
    },
  ];

  return (
    <section
      id="why-us"
      className="py-20 md:py-28 border-t border-border/40 overflow-hidden"
    >
      <div className="container mx-auto max-w-screen-2xl px-6 space-y-16">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <AnimatedReveal
            as="h2"
            className="text-xs font-bold tracking-widest text-violet-500 uppercase"
          >
            Comparison
          </AnimatedReveal>
          <h3 className="text-3xl sm:text-4xl font-bold tracking-tight">
            <AnimatedText text="Why Gurukula AI?" stagger={0.08} />
          </h3>
          <AnimatedReveal
            as="p"
            delay={0.3}
            className="text-muted-foreground text-sm sm:text-base"
          >
            How does a local, offline learning assistant stack up against
            traditional web-based AI platforms?
          </AnimatedReveal>
        </div>

        {/* Comparison Table */}
        <ScrollReveal
          direction="up"
          delay={0.1}
          className="max-w-4xl mx-auto overflow-x-auto rounded-2xl border border-border/80 bg-card/45 shadow-xl"
        >
          <table className="w-full text-left border-collapse min-w-[600px]">
            <thead>
              <tr className="border-b border-border bg-muted/30">
                <th className="p-4 md:p-5 text-base font-bold text-muted-foreground">
                  Capabilities
                </th>
                <th className="p-4 md:p-5 text-base font-bold text-violet-500 bg-violet-500/5 border-x border-border/50">
                  Gurukula AI (Local)
                </th>
                <th className="p-4 md:p-5 text-base font-bold text-muted-foreground">
                  Standard Web AI (Cloud)
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border/60 text-sm">
              {comparisonRows.map((row, index) => (
                <motion.tr
                  key={index}
                  initial={{ opacity: 0, y: 15 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: false, margin: "-40px" }}
                  transition={{ delay: index * 0.05, duration: 0.4 }}
                  className="hover:bg-muted/10 transition-colors"
                >
                  <td className="p-4 md:p-5 font-semibold">{row.label}</td>
                  <td className="p-4 md:p-5 font-medium text-emerald-800 dark:text-emerald-400 bg-violet-500/5 border-x border-border/50">
                    <div className="flex items-center space-x-2">
                      <CheckCircle2 className="w-4 h-4 shrink-0 text-emerald-500" />
                      <span>{row.local}</span>
                    </div>
                  </td>
                  <td className="p-4 md:p-5 text-black dark:text-muted-foreground">
                    {row.cloud}
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </ScrollReveal>
      </div>
    </section>
  );
}
