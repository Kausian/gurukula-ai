import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Privacy Policy | Gurukula AI",
  description:
    "Privacy Policy for Gurukula AI — a privacy-first, offline-focused study assistant. Learn what data is stored locally and how sign-in works.",
};

const UPDATED = "31 July 2026";

export default function PrivacyPage() {
  return (
    <main className="mx-auto max-w-3xl px-6 py-16">
      <Link href="/" className="text-sm text-neutral-500 hover:underline">
        ← Back to Gurukula AI
      </Link>
      <h1 className="mt-6 text-3xl font-bold">Privacy Policy</h1>
      <p className="mt-2 text-sm text-neutral-500">Last updated: {UPDATED}</p>

      <div className="prose prose-neutral dark:prose-invert mt-8 max-w-none">
        <p>
          Gurukula AI is a privacy-first, offline-focused study assistant for
          students. This policy explains what data the app uses and where it is
          stored. In plain terms: your study content stays on your device.
        </p>

        <h2>Who we are</h2>
        <p>
          Gurukula AI is developed by Kausian Senthan (“the developer”,
          “we”). You can contact us at{" "}
          <a href="mailto:skausian@gmail.com">skausian@gmail.com</a>.
        </p>

        <h2>Sign-in and authentication</h2>
        <ul>
          <li>Gurukula AI uses Firebase Authentication for sign-in.</li>
          <li>Google Sign-In is available.</li>
          <li>
            Email/password authentication is available where it is enabled for
            the app in Firebase.
          </li>
          <li>
            Authentication is used for identity only. We use your account to let
            you sign in; we do not use it to sync your study content to any
            server.
          </li>
        </ul>

        <h2>Where your study data is stored</h2>
        <ul>
          <li>
            Your student profile details (such as name, study level,
            course/subject, study goal and optional institution) are stored
            locally on your device.
          </li>
          <li>
            Your study notes and generated materials — summaries, flashcards,
            quizzes, quiz results, rewrites, ideas, study goals and activity —
            are stored locally on your device.
          </li>
          <li>
            Encrypted Storage protects saved study data at rest on your device
            using a key held in the device secure store.
          </li>
          <li>
            Privacy Lock can require biometric unlock or a PIN to open the app.
          </li>
        </ul>

        <h2>Camera, gallery and OCR</h2>
        <ul>
          <li>
            The camera and gallery are used only when you choose to import or
            scan notes.
          </li>
          <li>
            Text recognition (OCR) uses Google ML Kit, which may use Google Play
            services or on-device components to read text from the images you
            select.
          </li>
        </ul>

        <h2>AI generation</h2>
        <ul>
          <li>
            On-device AI is used only where it is supported by your device and
            runtime.
          </li>
          <li>
            When on-device AI is not available, the app uses local, rule-based
            fallback generation.
          </li>
          <li>Gurukula AI does not use the OpenAI API.</li>
          <li>Gurukula AI does not use a cloud Gemini API.</li>
        </ul>

        <h2>What we do NOT do</h2>
        <ul>
          <li>No cloud sync of your study content.</li>
          <li>No cloud database or Firestore profile sync.</li>
          <li>No analytics or tracking SDKs.</li>
          <li>No advertising.</li>
        </ul>

        <h2>Deleting your data</h2>
        <p>
          You can delete your data at any time from inside the app. See the{" "}
          <Link href="/data-deletion">Data Deletion</Link> page for details on
          deleting your account or clearing your local study data.
        </p>

        <h2>Children</h2>
        <p>
          Gurukula AI is a general study tool. If you are under the age required
          by your local laws to consent to processing, please use the app with a
          parent or guardian.
        </p>

        <h2>Changes</h2>
        <p>
          We may update this policy as the app evolves. Material changes will be
          reflected on this page with a new “last updated” date.
        </p>

        <h2>Contact</h2>
        <p>
          Questions about privacy? Email{" "}
          <a href="mailto:skausian@gmail.com">skausian@gmail.com</a>.
        </p>
      </div>
    </main>
  );
}
