"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { WifiOff, Download, Code2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ProductMockup } from "@/components/product-mockup";

interface HeroProps {
  scrollToSection: (id: string) => void;
}

export function Hero({ scrollToSection }: HeroProps) {
  const fadeIn = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6 } },
  };

  const staggerContainer = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  return (
    <section
      id="hero"
      className="relative pt-4 pb-20 md:pt-6 md:pb-28 overflow-hidden bg-radial from-violet-500/5 via-transparent to-transparent"
    >

      {/* Subtle blurred decorative radial blobs */}
      <motion.div
        animate={{
          x: [0, 20, 0, -20, 0],
          y: [0, -30, 0, 30, 0],
        }}
        transition={{
          duration: 20,
          repeat: Infinity,
          ease: "easeInOut",
        }}
        className="absolute top-1/4 left-1/4 -z-10 h-72 w-72 rounded-full bg-violet-500/10 blur-3xl"
      />
      <motion.div
        animate={{
          x: [0, -30, 0, 20, 0],
          y: [0, 20, 0, -20, 0],
        }}
        transition={{
          duration: 25,
          repeat: Infinity,
          ease: "easeInOut",
        }}
        className="absolute bottom-1/4 right-1/4 -z-10 h-80 w-80 rounded-full bg-violet-500/5 blur-3xl"
      />

      <div className="container mx-auto max-w-screen-2xl px-6 py-4 md:py-6">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-8 items-center">
          <motion.div
            initial="hidden"
            animate="visible"
            variants={staggerContainer}
            className="max-w-2xl mx-auto lg:mx-0 space-y-6 text-center lg:text-left lg:-mt-12 xl:-mt-20"
          >
            {/* Product Badge */}
            <motion.div
              variants={fadeIn}
              className="inline-flex items-center space-x-1.5 rounded-full border border-violet-500/30 bg-violet-500/10 dark:bg-violet-500/5 px-3.5 py-1 text-xs font-semibold text-violet-600 dark:text-violet-400 backdrop-blur-sm"
            >
              <WifiOff className="w-3.5 h-3.5" />
              <span>Your notes stay yours.</span>
            </motion.div>

            {/* Title */}
            <motion.h1
              variants={fadeIn}
              className="text-[28px] xs:text-3.5xl sm:text-5xl md:text-6xl font-extrabold tracking-tight leading-tight"
            >
              <motion.span
                animate={{ scale: [1, 1.08, 1] }}
                transition={{
                  duration: 4,
                  ease: "easeInOut",
                  repeat: Infinity,
                  repeatType: "mirror",
                }}
                className="inline-block origin-center aurora-shine-text uppercase text-xg sm:text-l md:text-2xl"
              >
                GURUKULA &nbsp;AI
              </motion.span>
              <br />
              Study Smarter, Even
              <br /> When The <br />
              <span className="bg-gradient-to-r from-violet-600 via-violet-500 to-violet-500 bg-clip-text text-transparent">
                Internet Does Not Help.
              </span>
            </motion.h1>

            {/* Description */}
            <motion.div
              variants={fadeIn}
              className="text-base sm:text-lg md:text-xl text-muted-foreground leading-relaxed max-w-2xl mx-auto lg:mx-0 space-y-4"
            >
              <p>
                Gurukula AI is a privacy-first, offline-focused study assistant for students. It helps students turn notes, TXT files, text-based PDFs, gallery images, and camera-scanned printed notes into summaries, flashcards, quizzes, revision cards, and project ideas.
              </p>
              <p>
                Built for students who want a calm, private, and organized way to study from their own material.
              </p>
            </motion.div>

            {/* Hero Buttons */}
            <motion.div
              variants={fadeIn}
              className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-3"
            >
              <Button
                size="lg"
                onClick={() => scrollToSection("download")}
                className="w-full sm:w-auto h-11 bg-violet-600 hover:bg-violet-500 text-white font-semibold shadow-lg shadow-violet-600/20 px-6 cursor-pointer"
              >
                <Download className="w-4 h-4 mr-2" /> Download APK
              </Button>
              <Button
                variant="outline"
                size="lg"
                onClick={() =>
                  window.open("https://github.com/gurukula-ai", "_blank")
                }
                className="w-full sm:w-auto h-11 border-border/80 hover:bg-muted font-semibold px-6 cursor-pointer"
              >
                <Code2 className="w-4 h-4 mr-2" /> View on GitHub
              </Button>
            </motion.div>
          </motion.div>

          {/* Product Mockup Showcase */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{
              delay: 0.4,
              duration: 0.8,
              type: "spring",
              stiffness: 50,
            }}
            className="flex justify-center lg:justify-end lg:-translate-x-42 xl:-translate-x-52"
          >
            <div className="relative rounded-[44px] p-1.5 bg-gradient-to-b from-border/80 via-border/30 to-border/10 shadow-2xl lg:rotate-[1deg] lg:hover:rotate-[1deg] hover:-translate-y-2 transition-all duration-500 ease-out cursor-pointer">
              <ProductMockup />
              {/* Decorative glow underneath */}
              <div className="absolute -inset-4 -z-20 bg-gradient-to-t from-violet-500/15 to-violet-500/5 rounded-[48px] blur-2xl opacity-60" />
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
