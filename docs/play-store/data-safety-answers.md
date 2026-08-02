# Play Data Safety — Answer Guide (Gurukula AI, v1.30.0)

A practical, question-by-question guide for the Play Console **Data safety**
form, grounded in the actual app behavior (see `data-safety-draft.md`,
`permission-review.md`, and the Privacy Policy / Data Deletion pages). Answer in
Play Console exactly as below unless the app changes.

Items marked **[Verify]** should be confirmed against the current Play Console
wording / Firebase docs at submission time, since Google occasionally rewords
the form.

---

## Overview answers

- **Does your app collect or share any required user data types?** → **Yes**
  (a small amount, for authentication only).
- **Is all of the user data collected by your app encrypted in transit?** →
  **Yes** (Firebase Authentication uses HTTPS/TLS).
- **Do you provide a way for users to request that their data is deleted?** →
  **Yes** (in-app Delete account + public Data Deletion page).

## Data collected (declare these)

Collected via **Firebase Authentication / Google Sign-In**, for sign-in only.

| Data type (Play category) | Collected | Shared | Purpose | Required/Optional |
|---|---|---|---|---|
| **Email address** (Personal info) | Yes | No | Account management / app functionality | Required for an account |
| **Name** (Personal info) | Yes | No | Account management / app functionality | Optional |
| **User IDs** (Personal info → User IDs; Firebase UID) | Yes | No | Account management / app functionality | Required |

Notes for the form:
- "Collected" = sent off-device (to Firebase for auth). "Shared" = sent to a
  third party for their own use → **No** for all of the above.
- Do **not** declare study content as collected — it is not sent off device.

## Data NOT collected / NOT shared

Answer **No / not collected** for all of these:

- Location (approximate or precise).
- Financial info.
- Health & fitness.
- Messages, contacts, calendar, call logs.
- **Photos/videos** — images chosen for OCR are processed **on-device** and are
  not uploaded, so **not collected**. **[Verify]** the form's photo/OCR wording;
  if it asks about *access* vs *collection*, the app *accesses* a
  user-selected image locally but does **not** collect/transmit it.
- App activity / analytics, advertising ID, device identifiers for tracking.

## Data processed on-device only (not declared as "collected")

These stay on the device and are **not** sent anywhere, so they are not
"collected" in Play terms:

- Student profile (name, study level, course/subject, study goal, optional
  institution).
- Study notes/documents, summaries, flashcards, quizzes, quiz results,
  rewrites, ideas, study goals, activity history.
- Privacy Lock settings (a salted PIN hash — never the raw PIN).
- All stored in a local Hive database, protected at rest by **Encrypted
  Storage** (AES; key in the Android secure store).

## Security practices (declare)

- **Data is encrypted in transit:** Yes.
- **Data is encrypted at rest:** Yes (local study-data boxes are encrypted
  on-device). **[Verify]** — Play's "encrypted in transit" question is about
  network transfer; the at-rest note is accurate for our local storage and can
  be mentioned in the app's privacy section.
- **You provide a way to request data deletion:** Yes.
- **Committed to Play Families Policy / independent security review:** answer
  per your actual status (typically **No** to independent review).

## Deletion

- **In-app account deletion:** Profile → Danger zone → **Delete account**
  (types DELETE; re-auth for email/Google). Deletes the Firebase account and all
  local data.
- **In-app local reset:** Profile → Privacy & data → **Clear local study data**
  (keeps the account).
- **Data deletion URL (required by Play):**
  `https://<YOUR-VERCEL-DOMAIN>/data-deletion` — **[Verify]** replace with the
  deployed landing domain (the `/data-deletion` page exists in `landing/`).

## Feature-specific

- **Authentication:** Firebase Authentication; Google Sign-In; email/password
  where enabled in Firebase.
- **Camera/gallery:** used only when the user chooses to scan/import notes;
  OCR (Google ML Kit) runs on-device; images are not uploaded.
- **Ads:** None.
- **Analytics / tracking:** None.
- **Cloud AI:** None (no OpenAI, no cloud Gemini API). On-device AI where
  supported; local fallback otherwise.
- **Cloud sync / Firestore:** None.

## Consistency check

Before submitting, confirm these answers match:
- Privacy Policy (`landing /privacy`)
- Data Deletion page (`landing /data-deletion`)
- `permission-review.md`
If any wording differs, update the docs — the Data Safety form must not
contradict the Privacy Policy.
