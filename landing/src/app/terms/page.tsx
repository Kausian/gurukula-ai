import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Terms of Use | Gurukula AI",
  description:
    "Terms of Use for Gurukula AI — a study assistance tool provided as-is. Verify important study content.",
};

const UPDATED = "31 July 2026";

export default function TermsPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-16">
      <Link href="/" className="text-sm text-neutral-500 hover:underline">
        ← Back to Gurukula AI
      </Link>
      <h1 className="mt-6 text-3xl font-bold">Terms of Use</h1>
      <p className="mt-2 text-sm text-neutral-500">Last updated: {UPDATED}</p>

      <div className="prose prose-neutral dark:prose-invert mt-8 max-w-none">
        <p>
          These terms apply to your use of Gurukula AI (“the app”), developed by
          Kausian Senthan. By using the app, you agree to these terms.
        </p>

        <h2>What Gurukula AI is</h2>
        <p>
          Gurukula AI is a study assistance tool. It helps you turn your notes
          into summaries, flashcards, quizzes and other study materials, and
          plan your study goals.
        </p>

        <h2>Study content and accuracy</h2>
        <ul>
          <li>
            Generated study materials may contain mistakes or omissions. They
            are a study aid, not a source of truth.
          </li>
          <li>
            You should verify important study content against your course
            materials and trusted sources before relying on it.
          </li>
          <li>
            Gurukula AI does not guarantee any exam results, grades or academic
            outcomes.
          </li>
        </ul>

        <h2>Your content and exports</h2>
        <ul>
          <li>Your notes and study materials are yours.</li>
          <li>
            When you export or share a file from the app, you are responsible
            for how and where you share it. Content shared outside the app is no
            longer controlled by the app.
          </li>
        </ul>

        <h2>Accounts</h2>
        <p>
          You are responsible for keeping your sign-in credentials secure. You
          can delete your account at any time from within the app — see the{" "}
          <Link href="/data-deletion">Data Deletion</Link> page.
        </p>

        <h2>Provided “as is”</h2>
        <p>
          Gurukula AI is provided on an “as is” and “as available” basis for
          study support, without warranties of any kind. To the extent permitted
          by law, the developer is not liable for any loss arising from your use
          of the app, including reliance on generated study materials.
        </p>

        <h2>Changes</h2>
        <p>
          We may update these terms as the app evolves. Continued use after an
          update means you accept the revised terms.
        </p>

        <h2>Contact</h2>
        <p>
          Questions about these terms? Email{" "}
          <a href="mailto:skausian@gmail.com">skausian@gmail.com</a>.
        </p>
      </div>
    </main>
  );
}
