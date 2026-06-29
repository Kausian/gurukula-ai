"use client";

import * as React from "react";
import { motion, Variants } from "framer-motion";
import {
  UploadCloud,
  Eye,
  FileText,
  Layers,
  CheckCircle,
  Lightbulb,
  FolderOpen,
  ShieldCheck,
  Brain,
  Library,
  Share2,
} from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { ScrollReveal } from "@/components/scroll-reveal";
import { AnimatedText, AnimatedReveal } from "@/components/animated-text";

export function Features() {
  const featuresList = [
    {
      icon: UploadCloud,
      title: "Import Notes",
      desc: "Paste study notes, import .txt files, upload text-based PDFs, import gallery images, or scan printed notes using the camera.",
    },
    {
      icon: Eye,
      title: "Preview Before Saving",
      desc: "Review and edit extracted text before creating a study workspace. This helps clean OCR/PDF text before generating study tools.",
    },
    {
      icon: FileText,
      title: "Clear Summaries",
      desc: "Turn long notes into focused summaries. Uses ML Kit GenAI / Gemini Nano on supported devices. Safe fallback on unsupported devices.",
    },
    {
      icon: Layers,
      title: "Flashcards",
      desc: "Generate quick revision cards from your study material.",
    },
    {
      icon: CheckCircle,
      title: "Quiz Mode",
      desc: "Test yourself with quizzes created from your notes.",
    },
    {
      icon: Brain,
      title: "Smart Revision",
      desc: "Use flashcards and spaced practice to keep track of what needs review.",
    },
    {
      icon: Lightbulb,
      title: "Idea Lab",
      desc: "Generate, refine, and organize project ideas for assignments, coursework, and personal learning.",
    },
    {
      icon: Library,
      title: "Local Library",
      desc: "Keep notes, summaries, flashcards, quizzes, and ideas saved locally. Search, filter, and reopen your study materials from one place.",
    },
    {
      icon: Share2,
      title: "Copy, Share, and Export",
      desc: "Copy, share, or export summaries, flashcards, quizzes, ideas, and study content when needed.",
    },
    {
      icon: ShieldCheck,
      title: "Privacy-First",
      desc: "Study content stays on the device. Gurukula AI does not use OpenAI API or cloud Gemini API for study generation.",
    },
  ];

  const containerVariants: Variants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const cardVariants: Variants = {
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

  return (
    <section
      id="features"
      className="py-20 md:py-28 border-t border-border/40 bg-muted/5 overflow-hidden"
    >
      <div className="container mx-auto max-w-screen-2xl px-6 space-y-16">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <AnimatedReveal
            as="h2"
            className="text-xs font-bold tracking-widest text-violet-500 uppercase"
          >
            Core Architecture
          </AnimatedReveal>
          <h3 className="text-3xl sm:text-4xl font-bold tracking-tight">
            <AnimatedText text="Supercharged Student Features" stagger={0.06} />
          </h3>
          <AnimatedReveal
            as="p"
            delay={0.3}
            className="text-muted-foreground text-base sm:text-lg"
          >
            Everything you need to digest lectures, organize homework, and study
            efficiently, compiled into a single offline desktop application.
          </AnimatedReveal>
        </div>

        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: false, margin: "-60px" }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {featuresList.map((feature, index) => {
            const IconComponent = feature.icon;
            return (
              <motion.div
                key={index}
                variants={cardVariants}
                whileHover={{ y: -6, scale: 1.01 }}
                className="h-full"
              >
                <Card className="h-full bg-card/50 hover:bg-card border-border/60 hover:border-violet-500/35 hover:shadow-lg transition-all duration-300 group cursor-pointer">
                  <CardContent className="p-6 space-y-4">
                    <div className="inline-flex items-center justify-center p-3 rounded-xl bg-violet-500/10 dark:bg-violet-500/5 text-violet-600 dark:text-violet-400 group-hover:scale-110 transition-transform duration-300">
                      <IconComponent className="h-6 w-6" />
                    </div>
                    <div className="space-y-2">
                      <h4 className="text-lg font-bold tracking-tight group-hover:text-violet-500 dark:group-hover:text-violet-400 transition-colors">
                        {feature.title}
                      </h4>
                      <p className="text-sm sm:text-base text-muted-foreground leading-relaxed">
                        {feature.desc}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            );
          })}
        </motion.div>
      </div>
    </section>
  );
}
