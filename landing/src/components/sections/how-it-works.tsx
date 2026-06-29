"use client";

import * as React from "react";
import { motion, Variants } from "framer-motion";
// import { ScrollReveal } from "@/components/scroll-reveal";
import { AnimatedText, AnimatedReveal } from "@/components/animated-text";

export function HowItWorks() {
  const stepsList = [
    {
      step: "01",
      title: "Add your material",
      desc: "Paste text, import a TXT file, upload a text-based PDF, import an image, or scan printed notes with the camera.",
    },
    {
      step: "02",
      title: "Preview and edit",
      desc: "Review extracted text, fix OCR mistakes, and rename your study workspace before saving.",
    },
    {
      step: "03",
      title: "Generate study tools",
      desc: "Create summaries, flashcards, quizzes, and revision cards from the same study content.",
    },
    {
      step: "04",
      title: "Revise smarter",
      desc: "Return to your local library whenever you need to review, export, or continue studying.",
    },
  ];

  const containerVariants: Variants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
      },
    },
  };

  const stepVariants: Variants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        type: "spring",
        stiffness: 80,
        damping: 15,
      },
    },
  };

  const lineVariants: Variants = {
    hidden: { scaleX: 0 },
    visible: {
      scaleX: 1,
      transition: { duration: 0.8, delay: 0.1, ease: "easeInOut" },
    },
  };

  return (
    <section
      id="how-it-works"
      className="py-20 md:py-28 border-t border-border/40 bg-muted/5 overflow-hidden"
    >
      <div className="container mx-auto max-w-screen-2xl px-6 space-y-16">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <AnimatedReveal
            as="h2"
            className="text-xs font-bold tracking-widest text-violet-500 uppercase"
          >
            Workflow
          </AnimatedReveal>
          <h3 className="text-3xl sm:text-4xl font-bold tracking-tight">
            <AnimatedText
              text="From notes to revision in a few taps"
              stagger={0.07}
            />
          </h3>
          <AnimatedReveal
            as="p"
            delay={0.3}
            className="text-muted-foreground text-sm sm:text-base"
          >
            Get up and running with offline learning instantly.
          </AnimatedReveal>
        </div>

        <div className="relative max-w-5xl mx-auto">
          <motion.div
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: false, margin: "-60px" }}
            className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8"
          >
            {stepsList.map((step, idx) => (
              <motion.div
                key={idx}
                variants={stepVariants}
                whileHover={{ y: -5, scale: 1.01 }}
                className="flex flex-col items-center text-center space-y-4 p-5 rounded-2xl bg-card/40 border border-border/60 hover:border-violet-500/20 hover:shadow-md transition-all duration-300 relative group cursor-pointer"
              >
                <div className="w-12 h-12 rounded-full bg-violet-500/10 dark:bg-violet-500/5 text-violet-600 dark:text-violet-400 flex items-center justify-center text-base font-extrabold border border-violet-500/25 group-hover:scale-105 transition-transform duration-300">
                  {step.step}
                </div>
                <h4 className="text-lg font-bold tracking-tight group-hover:text-violet-500 dark:group-hover:text-violet-400 transition-colors">
                  {step.title}
                </h4>
                <p className="text-sm sm:text-base text-muted-foreground leading-relaxed">
                  {step.desc}
                </p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
}
