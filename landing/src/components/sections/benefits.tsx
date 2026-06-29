"use client";

import { motion, Variants } from "framer-motion";
import { ScrollReveal } from "@/components/scroll-reveal";
import { AnimatedText, AnimatedReveal } from "@/components/animated-text";

export function Benefits() {
  const benefitsList = [
    {
      title: "Local Storage",
      desc: "Study content is stored locally on the Android device.",
    },
    {
      title: "No Cloud AI Upload",
      desc: "No OpenAI API and no cloud Gemini API are used.",
    },
    {
      title: "On-device OCR",
      desc: "Image text recognition runs on-device using ML Kit Text Recognition.",
    },
    {
      title: "On-device AI Where Supported",
      desc: "Gurukula AI uses ML Kit GenAI / Gemini Nano where supported for real on-device summary generation.",
    },
    {
      title: "Safe Fallback Mode",
      desc: "If on-device AI is unavailable, downloading, unsupported, slow, or fails, Gurukula AI uses fallback mode so the app remains usable.",
    },
    {
      title: "User Control",
      desc: "Students can manage and delete their local study data from the app.",
    },
  ];

  const containerVariants: Variants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1 },
    },
  };

  const cardVariants: Variants = {
    hidden: { opacity: 0, y: 28 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { type: "spring", stiffness: 80, damping: 16 },
    },
  };

  return (
    <section
      id="benefits"
      className="py-20 md:py-28 border-t border-border/40 bg-muted/5 overflow-hidden"
    >
      <div className="container mx-auto max-w-screen-2xl px-6 space-y-16">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <AnimatedReveal
            as="h2"
            className="text-xs font-bold tracking-widest text-violet-500 uppercase"
          >
            Privacy-First
          </AnimatedReveal>
          <h3 className="text-3xl sm:text-4xl font-bold tracking-tight">
            <AnimatedText text="Your notes stay yours" stagger={0.06} />
          </h3>
          <AnimatedReveal
            as="div"
            delay={0.3}
            className="text-muted-foreground text-base sm:text-lg space-y-4"
          >
            <p>
              Gurukula AI is designed for students who care about privacy and
              control. Study notes are stored locally on the device using Hive.
              OCR processing happens on-device. Firebase is used for Google
              Sign-In only, not for storing study content.
            </p>
            <p>
              Gurukula AI does not upload your study notes to OpenAI or cloud
              Gemini APIs.
            </p>
          </AnimatedReveal>
        </div>

        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: false, margin: "-60px" }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
        >
          {benefitsList.map((benefit, idx) => (
            <motion.div
              key={idx}
              variants={cardVariants}
              whileHover={{ y: -6, scale: 1.01 }}
              className="p-6 rounded-2xl border border-border bg-card/60 hover:shadow-md hover:border-violet-500/15 transition-all duration-300 space-y-3 cursor-pointer"
            >
              <div className="w-8 h-8 rounded-lg bg-violet-500/10 dark:bg-violet-500/5 text-violet-600 dark:text-violet-400 flex items-center justify-center text-base font-bold border border-violet-500/25">
                {idx + 1}
              </div>
              <h4 className="text-lg font-bold tracking-tight">
                {benefit.title}
              </h4>
              <p className="text-sm sm:text-base text-muted-foreground leading-relaxed">
                {benefit.desc}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
