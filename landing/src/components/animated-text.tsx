"use client";

import { motion, Variants } from "framer-motion";
import { ReactNode } from "react";

interface AnimatedTextProps {
  /** The text string to animate word-by-word */
  text: string;
  /** Additional className on the wrapping element */
  className?: string;
  /** Delay before the first word starts (seconds) */
  delay?: number;
  /** Duration per word animation */
  duration?: number;
  /** Gap between each word's animation (seconds) */
  stagger?: number;
  /** HTML tag to render as — defaults to span */
  as?: "h1" | "h2" | "h3" | "h4" | "p" | "span" | "div";
}

interface AnimatedTextChildrenProps {
  /** Pass arbitrary JSX children (e.g. mixed bold/spans) and animate the wrapper */
  children: ReactNode;
  className?: string;
  delay?: number;
  duration?: number;
  stagger?: number;
  as?: "h1" | "h2" | "h3" | "h4" | "p" | "span" | "div";
}

// Word-by-word reveal variants
const containerVariants = (stagger: number): Variants => ({
  hidden: { opacity: 1 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: stagger },
  },
});

const wordVariants = (duration: number): Variants => ({
  hidden: { opacity: 0, y: 18, filter: "blur(4px)" },
  visible: {
    opacity: 1,
    y: 0,
    filter: "blur(0px)",
    transition: { duration, ease: [0.21, 0.47, 0.32, 0.98] },
  },
});

/**
 * AnimatedText — splits `text` into individual words and reveals them
 * sequentially using Framer Motion's whileInView.
 */
export function AnimatedText({
  text,
  className = "",
  delay = 0,
  duration = 0.45,
  stagger = 0.07,
  as: Tag = "span",
}: AnimatedTextProps) {
  const words = text.split(" ");

  return (
    <motion.span
      // Use span as wrapper so it doesn't break heading hierarchy
      initial="hidden"
      whileInView="visible"
      viewport={{ once: false, margin: "-40px" }}
      variants={containerVariants(stagger)}
      transition={{ delayChildren: delay }}
      className={`inline-flex flex-wrap gap-x-[0.28em] ${className}`}
      aria-label={text}
    >
      {words.map((word, i) => (
        <motion.span
          key={i}
          variants={wordVariants(duration)}
          style={{ display: "inline-block" }}
        >
          {word}
        </motion.span>
      ))}
    </motion.span>
  );
}

/**
 * AnimatedReveal — wraps arbitrary children in a single fade+slide reveal.
 * Use this for mixed JSX content (e.g. headings with <span> color accents).
 */
export function AnimatedReveal({
  children,
  className = "",
  delay = 0,
  duration = 0.55,
  as: Tag = "div",
}: AnimatedTextChildrenProps) {
  const MotionTag = motion[Tag as keyof typeof motion] as typeof motion.div;

  return (
    <MotionTag
      initial={{ opacity: 0, y: 20, filter: "blur(4px)" }}
      whileInView={{ opacity: 1, y: 0, filter: "blur(0px)" }}
      viewport={{ once: false, margin: "-40px" }}
      transition={{ duration, delay, ease: [0.21, 0.47, 0.32, 0.98] }}
      className={className}
    >
      {children}
    </MotionTag>
  );
}
