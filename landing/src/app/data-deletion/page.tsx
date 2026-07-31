import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Data Deletion | Gurukula AI",
  description:
    "How to delete your Gurukula AI account or clear your local study data, and what gets removed.",
};

const UPDATED = "31 July 2026";

export default function DataDeletionPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-16">
      <Link href="/" className="text-sm text-neutral-500 hover:underline">
        ← Back to Gurukula AI
      </Link>
      <h1 className="mt-6 text-3xl font-bold">Data Deletion</h1>
      <p className="mt-2 text-sm text-neutral-500">Last updated: {UPDATED}</p>

      <div className="prose prose-neutral dark:prose-invert mt-8 max-w-none">
        <p>
          Gurukula AI lets you delete your data directly inside the app. There
          are two options, depending on whether you also want to remove your
          account.
        </p>

        <h2>Option 1 — Delete account (account + all local data)</h2>
        <ol>
          <li>Open the app and go to the Profile tab.</li>
          <li>
            Scroll to the <strong>Danger zone</strong> and tap{" "}
            <strong>Delete account</strong>.
          </li>
          <li>
            Review what will be deleted, type <strong>DELETE</strong> to
            confirm, and (for email accounts) re-enter your password. Google
            users may be asked to sign in again to confirm.
          </li>
          <li>Tap Delete my account.</li>
        </ol>
        <p>This permanently removes:</p>
        <ul>
          <li>Your Firebase Authentication account and sign-in</li>
          <li>Your student profile (name, study level, subject, goal, institution)</li>
          <li>All notes/documents, summaries, flashcards, quizzes and quiz results</li>
          <li>Rewrites, ideas, study goals and activity history</li>
          <li>Privacy Lock settings and locally stored study data</li>
        </ul>
        <p>
          After deletion you are returned to the signed-out landing screen and
          the app behaves like a fresh install.
        </p>

        <h2>Option 2 — Clear local study data (keep your account)</h2>
        <ol>
          <li>Open the app and go to the Profile tab.</li>
          <li>
            Under <strong>Privacy &amp; data</strong>, tap{" "}
            <strong>Clear local study data</strong> and confirm.
          </li>
        </ol>
        <p>
          This removes your notes and generated study materials from the device
          but keeps your account and student profile, so you can start fresh
          without signing up again.
        </p>

        <h2>What may remain outside the app</h2>
        <p>
          If you exported or shared a file (for example a study pack saved to
          Files, sent by email, or shared to another app), that copy lives
          outside Gurukula AI and is not affected by deletion. You control those
          copies wherever you saved or sent them.
        </p>

        <h2>Need help?</h2>
        <p>
          If you cannot access the app to delete your data, email{" "}
          <a href="mailto:skausian@gmail.com">skausian@gmail.com</a> from the
          email address associated with your account and we will help you delete
          your account.
        </p>
      </div>
    </main>
  );
}
