# Pre-launch Report Checklist — Gurukula AI

Google Play runs your app on real devices after you upload a release and
produces a **Pre-launch report** (Play Console → Test and release → Pre-launch
report). Review it before closed testing / production.

## Before it runs

- [ ] Upload the **signed AAB** (upload key; Play App Signing enabled).
- [ ] **App access:** because sign-in is required, provide reviewer/test
      credentials **or** clear account-creation instructions (Google Sign-In),
      so the crawler/reviewer can get past the Auth Landing screen. See
      `reviewer-instructions.md`. *(The automated crawler cannot complete Google
      Sign-In on its own, so expect it to mostly exercise the sign-in screen
      unless test credentials are provided.)*

## Review the report

- [ ] **Stability → Crashes:** zero crashes on the tested devices (investigate
      any; a crash on launch is a blocker).
- [ ] **Stability → ANRs** (App Not Responding): none.
- [ ] **Screenshots** the crawler captured: app launches and renders (at least
      the Auth Landing screen) with no black/blank screens.
- [ ] **Login / auth issues:** the crawler stops at sign-in (expected for an
      auth-gated app) — confirm the screen renders correctly and isn't crashing.
- [ ] **Performance / accessibility** warnings: note and address reasonable ones
      (contrast, tap targets, text scaling).
- [ ] **Security & trust / vulnerabilities:** review any flagged SDK or manifest
      issues; none expected beyond standard plugin notices.
- [ ] **Policy warnings:** check Data safety / permissions match the actual app
      (`permission-review.md`, `data-safety-answers.md`); resolve any mismatch.
- [ ] **SDK warnings / deprecations:** note any outdated-SDK warnings; not
      necessarily blocking for testing, but plan updates.

## Act on results

- [ ] **Fix high-priority issues** (crashes, ANRs, policy) **before** promoting
      to closed testing or production.
- [ ] Re-upload a new build with a **higher versionCode** after fixes.
- [ ] Re-check the pre-launch report on the new build.

## Notes

- Some pre-launch findings are expected for an auth-gated, offline-focused app
  (crawler can't sign in; large app size from on-device AI libs). Document these
  rather than "fixing" them.
- Keep `production-qa-checklist.md` in sync — manual device testing complements
  the automated pre-launch report.
