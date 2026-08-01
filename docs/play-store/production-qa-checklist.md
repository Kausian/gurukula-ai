# Production QA Checklist — Gurukula AI (v1.29.0)

A manual + automated QA pass to run before each Play Store release. Automated
gates (`analyze`, `test`, release APK/AAB) run in CI/locally; the manual items
need a real device (ideally one small phone and one large phone, plus large
system font scaling).

Identity for this release: **versionName 1.29.0 · versionCode 31 ·
`com.gurukula.gurukula_ai`**.

---

## Automated gates (must pass)

- [ ] `flutter analyze` → no issues
- [ ] `flutter test` → all pass
- [ ] `flutter build apk --release --dart-define="GOOGLE_SERVER_CLIENT_ID=…"`
- [ ] `flutter build appbundle --release --dart-define="GOOGLE_SERVER_CLIENT_ID=…"`

## 1. Startup

- [ ] Fresh signed-release install opens past the native splash to **Auth
      Landing** (regression guard for the v1.28.x encrypted-box crash).
- [ ] No infinite loading / stuck splash.
- [ ] If startup init fails, a "Couldn't start Gurukula AI" recovery screen
      appears (not a frozen splash).
- [ ] No router redirect loop; no missing-Hive-box crash.

## 2. Auth & routing

- [ ] Signed-out → Auth Landing (Log in / Sign up / Continue with Google).
- [ ] Login screen opens; Signup screen opens.
- [ ] Google Sign-In completes → profile completion (if new) → onboarding (if
      not done) → Home.
- [ ] Email sign up creates account + profile → onboarding → Home
      *(needs Firebase Email/Password enabled)*.
- [ ] Email login works; wrong password shows a clear message.
- [ ] Password reset shows success/error safely.
- [ ] Existing signed-in user lands on Home.
- [ ] Sign out → Auth Landing.
- [ ] Onboarding never appears before auth.

## 3. Account deletion & local reset

- [ ] Profile → Privacy & data → **Clear local study data** confirms, wipes
      notes/tools, **keeps** the account/profile, storage still works.
- [ ] Profile → Danger zone → **Delete account** opens, requires typing DELETE
      (+ password for email accounts).
- [ ] Email delete re-auth works; wrong password shows a clear error and does
      **not** delete local data.
- [ ] Google delete re-auth (interactive) works.
- [ ] On success → Auth Landing; app reopens clean; **no Privacy Lock trap**.
- [ ] Firebase delete failure leaves local data intact.

## 4. Encrypted storage

- [ ] Notes save and reload across app restarts.
- [ ] Profile → Encrypted Storage shows **On** (or **Off** honestly if the
      secure key was unavailable).
- [ ] Clear-local / delete-account do not corrupt storage (app reopens fine).

## 5. Privacy Lock

- [ ] Enable → set PIN → relaunch prompts for unlock.
- [ ] PIN unlock works; biometric unlock works (if device supports); biometric
      failure/cancel falls back to PIN.
- [ ] Change PIN; disable Privacy Lock.
- [ ] Not locked out unexpectedly. (Known: forgotten PIN → clear app data.)

## 6. Study features

- [ ] Add note / edit note (Note tab reflects edits).
- [ ] Import: TXT, PDF, gallery OCR, camera OCR.
- [ ] Summary (Short/Medium/Detailed) + regenerate + stale notice.
- [ ] Flashcards (Quick revision / Exam prep) + add fresh cards.
- [ ] Quiz (Easy/Medium/Hard) + take quiz + revision mode.
- [ ] Idea Lab; Study Planner (create/edit/delete goal, days-remaining).
- [ ] Library favorites + note-lens filter; Study Pack export; copy/share/export.
- [ ] Empty / loading / error states look correct.

## 7. Offline & fallback

- [ ] Already-installed app opens and uses local notes with no internet.
- [ ] Fallback generation works when on-device AI is unavailable (no overclaim).
- [ ] Google/email auth shows a clear "network error" message when offline.
- [ ] No cloud-AI claims anywhere.

## 8. UI stability

- [ ] No yellow/black overflow stripes on any screen.
- [ ] Auth Landing / Login / Signup fit and scroll on a small phone and with
      large system font scaling (Auth Landing is now scroll-safe).
- [ ] Signup scrolls with the keyboard open.
- [ ] Profile "Student profile" rows wrap long values (no overflow).
- [ ] Delete account screen readable; bottom nav doesn't overlap content.

## 9. Security / privacy audit

- [ ] `git status` shows no `key.properties`, `*.jks`, `*.keystore`, `*.apk`,
      `*.aab`, `google-services.json`, or `firebase_options.dart` staged.
- [ ] Only `USE_BIOMETRIC` declared in the app manifest; the rest are
      auth/ML-Kit plugin permissions (see `permission-review.md`). No analytics,
      tracking, or ads.
- [ ] Privacy/Terms/Data-Deletion wording is honest and not overclaiming.
- [ ] Export/share warning and deletion wording are clear.

## 10. Build artifacts & signing

- [ ] `android/key.properties` present locally for a real (upload-signed) build;
      absent → release falls back to debug key (NOT Play-uploadable).
- [ ] APK: `build/app/outputs/flutter-apk/app-release.apk`
- [ ] AAB: `build/app/outputs/bundle/release/app-release.aab`
- [ ] versionCode is higher than the previous Play upload.

## Known limitations (carried forward)

- Firebase **Email/Password** must be enabled in the Firebase Console for the
  email auth paths; otherwise the app shows "Email sign-in is not enabled yet —
  continue with Google."
- Google Sign-In in Play builds needs the **Play app signing** SHA-1/256 added
  to Firebase (see `google-signin-release-notes.md`).
- If the secure-storage encryption key is ever lost (rare; e.g. some
  backup/restore cases), encrypted study data can't be recovered; the app fails
  open (empty, not crashing). No cloud backup by design.
- Forgotten Privacy Lock PIN → clear app data to recover (no PIN reset).
- Release APK is large (~95 MB) due to ML Kit GenAI native libs; Play delivers
  smaller per-device splits from the AAB.
- Firebase re-auth / Google Sign-In deletion paths are device/Firebase-bound and
  can't be unit-tested — verify manually per section 3.
