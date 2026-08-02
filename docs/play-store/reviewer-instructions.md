# Reviewer Instructions — Gurukula AI (v1.30.0)

Paste (an adapted version of) this into Play Console → **App content → App
access** (and the testing-track notes) so reviewers can exercise the app.

Replace the `<...>` placeholders with the real deployed URLs and any test
credentials before submitting.

---

## Getting in

Gurukula AI requires sign-in (identity only; study data stays on the device).

- **Google Sign-In** is available on the Auth Landing and Login screens.
- **Email/password** sign-in/sign-up is available **only if the Email/Password
  provider is enabled** in our Firebase project. If email sign-in shows
  "Email sign-in is not enabled yet — continue with Google", please use Google
  Sign-In (this is expected, not a bug).
- Optional test account (if provided): `<TEST_EMAIL>` / `<TEST_PASSWORD>`.

### Create an account
1. Launch the app → **Auth Landing**.
2. Tap **Sign up** (email) or **Continue with Google**.
3. Email sign up: enter full name, email, password, confirm, and a few student
   details (study level, subject, goal; institution is optional).
4. Google sign-in: after signing in, complete the small **student profile** step
   (study level, subject, goal; institution optional).
5. A short **onboarding** appears on first run — you can Skip it.
6. You arrive at **Home**.

## Try the core flow (no private files needed)

1. **Create a note:** Home/Upload → **Paste text** → paste any sample text
   (e.g. a paragraph about photosynthesis) → save. (No personal files required.)
2. Open the note → **Note tab** shows it. Use the tabs:
   - **Summary** → choose Short/Medium/Detailed → generate.
   - **Flashcards** → Quick revision / Exam prep → generate.
   - **Quiz** → Easy/Medium/Hard → generate → take the quiz.
3. **Export:** Note tab → **Export study pack (.txt)** → uses the system share
   sheet.
4. **Study Planner:** add a goal with a future date; see days-remaining.

### OCR / import (optional)
- Upload → import a **TXT** or **text-based PDF**, or **scan/gallery** an image.
- OCR works best with **clear printed text**; blurry or handwritten text may not
  recognize well (expected).
- Please use non-personal sample text/images.

## Privacy & data features

- **Privacy Lock:** Profile → Privacy Lock → enable → set a PIN. Relaunch to see
  the unlock screen (PIN, plus biometric if the device supports it).
- **Clear local study data:** Profile → Privacy & data → Clear local study data
  (keeps the account).
- **Delete account:** Profile → Danger zone → **Delete account** → type
  **DELETE** (email accounts re-enter password; Google accounts re-authenticate)
  → returns to the Auth Landing screen. (Use a throwaway test account.)

## Important expectations (not bugs)

- **On-device AI may show "Not supported"** on some devices/emulators. In that
  case the app uses **local fallback generation** — summaries/flashcards/quizzes
  still work. This is expected and functioning.
- No ads, no analytics/tracking, no cloud AI, no cloud sync.

## Links

- Privacy Policy: `https://<YOUR-VERCEL-DOMAIN>/privacy`
- Terms of Use: `https://<YOUR-VERCEL-DOMAIN>/terms`
- Data Deletion: `https://<YOUR-VERCEL-DOMAIN>/data-deletion`
- Support email: **skausian@gmail.com**
