# Internal Test — Release Notes (Gurukula AI v1.31.0)

Paste the short block below into Play Console's **Release notes** for the
internal/closed testing release. The rest of this file is context for you and
your testers.

---

## Release notes (paste into Play Console)

```
Gurukula AI — testing build (1.31.0)

Thanks for testing! Please try: sign in with Google, create a text note, and
generate a summary, flashcards and a quiz. Also try the Study Planner, Study
Pack export, Privacy Lock, and Delete account.

Use demo notes only — not private or sensitive content.

Note: on some phones "On-device AI: Not supported" is expected; the app then
uses fallback mode and everything still works. OCR works best on clear printed
text.

Your study data stays on your device. Please send feedback via the form.
```

---

## Focus areas for this test

- **First launch on a Play-distributed build:** app reaches the sign-in screen
  (no stuck splash), signs in, completes profile, reaches Home.
- **Google Sign-In in the Play build** (most important — depends on Play app
  signing SHA being registered in Firebase).
- **Core study loop:** note → summary/flashcards/quiz → export.
- **Privacy & data:** Privacy Lock enable/unlock/disable; Clear local study
  data; **Delete account**.

## Known limitations (share with testers)

- **On-device AI support depends on the device/runtime.** Where it isn't
  available, the app uses **local fallback generation** — this is expected and
  fully functional, not a broken feature.
- **OCR works best on clear, printed English text.** Blurry or handwritten
  images may not recognize well.
- **Email/password sign-in** works only if the Email/Password provider is
  enabled in our Firebase project; otherwise use **Google Sign-In**.
- Release APK/app is large (~95 MB) due to ML Kit on-device AI components; Play
  delivers smaller per-device downloads from the AAB.
- If the device's secure key is ever lost (rare), encrypted local data can't be
  recovered; the app fails open (empty), not crashing. No cloud backup by design.

## Tester reminders

- **Do not use private or sensitive notes** during testing.
- **Delete your test account** from Profile → Danger zone when finished.
