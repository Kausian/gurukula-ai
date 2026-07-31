# Google Play Data Safety — Draft (Gurukula AI, v1.27.0)

A draft for the Play Console **Data safety** form, based on what the code
actually does. Review before submitting; update if the app's behavior changes.

Developer: Kausian Senthan · App: Gurukula AI
Contact: skausian@gmail.com

---

## Summary answers

- **Does your app collect or share any of the required user data types?**
  **Yes** — a small amount, for authentication only (see below).
- **Is all user data encrypted in transit?** Yes — Firebase Authentication uses
  HTTPS/TLS.
- **Do you provide a way for users to request that their data be deleted?**
  **Yes** — in-app **Delete account** (Profile → Danger zone) and a public
  Data Deletion page. See `/data-deletion`.

## Data collected

Only what is needed to sign in. Handled by **Firebase Authentication** /
**Google Sign-In**.

| Data type | Collected | Purpose | Optional? | Shared? |
|---|---|---|---|---|
| Email address | Yes | App functionality — account sign-in | Required to have an account | Not shared |
| Name | Yes (Google display name / name entered at sign up) | App functionality — account/profile | Optional | Not shared |
| User IDs (Firebase UID) | Yes | App functionality — account identity | Required | Not shared |

Notes:
- These are processed by Google Firebase Authentication (the app's auth
  provider). This is "collected" in Play terms because it is sent to Firebase
  for sign-in.
- The app does **not** send study content (notes, summaries, flashcards,
  quizzes, ideas, goals) off the device.

## Data NOT collected / shared

- No location.
- No financial info.
- No health/fitness data.
- No contacts.
- No SMS/call logs.
- No photos/videos are uploaded — images chosen for OCR are processed on-device
  and not sent to us.
- No app-usage analytics, no advertising IDs, no tracking.

## Data stored only on the device (not sent anywhere)

- Student profile (name, study level, course/subject, study goal, optional
  institution).
- Study notes/documents, summaries, flashcards, quizzes, quiz results,
  rewrites, ideas, study goals, activity history.
- Privacy Lock settings (a salted PIN hash, never the raw PIN).
- These are stored in a local database (Hive) and protected at rest by
  **Encrypted Storage** (AES; key held in the Android secure store).

## Security practices

- **Encrypted in transit:** Yes (Firebase Auth over TLS).
- **Encryption at rest:** Study data boxes are encrypted on-device.
- **User can request data deletion:** Yes — in-app Delete account + Clear local
  study data, plus a public Data Deletion page and support email.

## Feature-specific disclosures

- **Camera / gallery:** Used only when the user chooses to scan or import notes.
  Images are read on-device by Google ML Kit text recognition (OCR), which may
  use Google Play services / on-device components. Images are not uploaded by
  the app.
- **Authentication:** Firebase Authentication; Google Sign-In; email/password
  where enabled in Firebase.
- **Ads:** None.
- **Analytics / tracking:** None.
- **Cloud AI:** None (no OpenAI API, no cloud Gemini API). On-device AI is used
  only where supported; otherwise local fallback generation is used.

## Account deletion

- In-app path: Profile → Danger zone → **Delete account** (strong confirmation;
  type DELETE; re-authentication for email or Google as required by Firebase).
  Deletes the Firebase account and all local data.
- Web instructions + support contact: `/data-deletion`.
- Account deletion URL to provide in Play Console: the deployed
  `https://<landing-domain>/data-deletion`.
