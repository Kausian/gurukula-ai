"use client";

import * as React from "react";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { ScrollReveal } from "@/components/scroll-reveal";
import { AnimatedText, AnimatedReveal } from "@/components/animated-text";

export function FAQ() {
  return (
    <section
      id="faq"
      className="py-20 md:py-28 border-t border-border/40 bg-muted/5 overflow-hidden"
    >
      <div className="container mx-auto max-w-screen-2xl px-6 space-y-16">
        <div className="text-center max-w-3xl mx-auto space-y-4">
          <AnimatedReveal
            as="h2"
            className="text-xs font-bold tracking-widest text-violet-500 uppercase"
          >
            Got Questions?
          </AnimatedReveal>
          <h3 className="text-3xl sm:text-4xl font-bold tracking-tight">
            <AnimatedText text="Frequently Asked Questions" stagger={0.06} />
          </h3>
          <AnimatedReveal
            as="p"
            delay={0.3}
            className="text-muted-foreground text-base sm:text-lg"
          >
            Everything you need to know about Gurukula AI and how local models
            work on your machine.
          </AnimatedReveal>
        </div>

        <ScrollReveal
          direction="up"
          delay={0.1}
          className="bg-card border border-border/80 rounded-2xl p-6 md:p-8 shadow-md"
        >
          <Accordion type="single" collapsible className="w-full">
            <AccordionItem value="item-1" className="border-b border-border/60">
              <AccordionTrigger className="text-base font-bold text-left hover:text-violet-500 hover:no-underline py-4">
                Does Gurukula AI work offline?
              </AccordionTrigger>
              <AccordionContent className="text-sm sm:text-base text-muted-foreground leading-relaxed pb-4">
                Gurukula AI is offline focused. The core study workflow, local
                library, imported notes, revision, and saved study data work
                locally on the device. Some setup steps, such as downloading the
                APK, Google Sign-In, or supported device AI model preparation,
                may require internet access.
              </AccordionContent>
            </AccordionItem>

            <AccordionItem value="item-2" className="border-b border-border/60">
              <AccordionTrigger className="text-base font-bold text-left hover:text-violet-500 hover:no-underline py-4">
                Is my study data private?
              </AccordionTrigger>
              <AccordionContent className="text-sm sm:text-base text-muted-foreground leading-relaxed pb-4">
                Yes. Study content is stored locally on the device. Gurukula AI
                does not use OpenAI API or cloud Gemini API for study
                generation.
              </AccordionContent>
            </AccordionItem>

            <AccordionItem value="item-3" className="border-b border-border/60">
              <AccordionTrigger className="text-base font-bold text-left hover:text-violet-500 hover:no-underline py-4">
                Does Gurukula AI use Gemini Nano?
              </AccordionTrigger>
              <AccordionContent className="text-sm sm:text-base text-muted-foreground leading-relaxed pb-4">
                Gurukula AI uses ML Kit GenAI / Gemini Nano where supported. If
                the device does not support on-device AI, the app continues
                using fallback mode.
              </AccordionContent>
            </AccordionItem>

            <AccordionItem value="item-4" className="border-b border-border/60">
              <AccordionTrigger className="text-base font-bold text-left hover:text-violet-500 hover:no-underline py-4">
                Does Gurukula AI support handwritten notes?
              </AccordionTrigger>
              <AccordionContent className="text-sm sm:text-base text-muted-foreground leading-relaxed pb-4">
                Camera and gallery OCR work best with clear printed English
                text. Handwriting may be inaccurate and should be reviewed
                before saving.
              </AccordionContent>
            </AccordionItem>

            <AccordionItem value="item-5" className="border-0">
              <AccordionTrigger className="text-base font-bold text-left hover:text-violet-500 hover:no-underline py-4">
                Does Gurukula AI support Sinhala or Tamil OCR?
              </AccordionTrigger>
              <AccordionContent className="text-sm sm:text-base text-muted-foreground leading-relaxed pb-4">
                Not yet. Current OCR is focused on clear printed English text.
              </AccordionContent>
            </AccordionItem>

            <AccordionItem value="item-6" className="border-0">
              <AccordionTrigger className="text-base font-bold text-left hover:text-violet-500 hover:no-underline py-4">
                Is Gurukula AI free?
              </AccordionTrigger>
              <AccordionContent className="text-sm sm:text-base text-muted-foreground leading-relaxed pb-4">
                The current GitHub APK release is part of the active development
                and portfolio version of the app.
              </AccordionContent>
            </AccordionItem>

            <AccordionItem value="item-7" className="border-0">
              <AccordionTrigger className="text-base font-bold text-left hover:text-violet-500 hover:no-underline py-4">
                Which devices are supported?
              </AccordionTrigger>
              <AccordionContent className="text-sm sm:text-base text-muted-foreground leading-relaxed pb-4">
                Gurukula AI is currently built for Android. Minimum Android
                requirement is API 26 / Android 8.0 or higher after ML Kit GenAI
                integration.
              </AccordionContent>
            </AccordionItem>
          </Accordion>
        </ScrollReveal>
      </div>
    </section>
  );
}
