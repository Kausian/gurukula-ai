# Internal & Closed Testing Guide — Gurukula AI (v1.31.0)

Step-by-step for running Google Play Console **Internal testing** and **Closed
testing** before production. Cross-references:
`play-console-submission-checklist.md`, `reviewer-instructions.md`,
`google-signin-release-notes.md`, `pre-launch-report-checklist.md`.

- App: **Gurukula AI** · Package: `com.gurukula.gurukula_ai` · Category: Education
- This release: **versionName 1.31.0 · versionCode 33**
- Legal URLs: `https://gurukula-ai-landing.vercel.app/{privacy,terms,data-deletion}`

---

## A. Internal testing (fast, up to 100 testers)

Use this first to sanity-check the Play-distributed build (real signing, real
Google Sign-In).

1. **Create the app** in Play Console (if not done): Create app → name
   *Gurukula AI* → App, Free, Education. Complete the required *App content*
   declarations (see submission checklist).
2. **Build the signed AAB** with the upload key
   (`android/key.properties` present) and the Google server client id:
   ```powershell
   flutter build appbundle --release --dart-define="GOOGLE_SERVER_CLIENT_ID=135007688251-7hpgdoiorkdjt4d5fvr7h9nekul6vviq.apps.googleusercontent.com"
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`.
3. **Enable Play App Signing** when prompted on the first upload.
4. Play Console → **Testing → Internal testing → Create new release** → upload
   `app-release.aab`.
5. **Release notes:** paste from `internal-test-release-notes.md`.
6. **Testers:** Internal testing → Testers tab → create/select an email list →
   add tester Gmail addresses → Save.
7. **Save & publish** the internal release (review is minimal for internal).
8. **Opt-in link:** copy the "Copy link" URL and send it to testers (also in
   `tester-instructions.md`). Each tester opens it, accepts, then installs from
   Google Play.
9. **Verify on a real device installed from Play:**
   - App opens past splash → Auth Landing (regression guard).
   - **Google Sign-In works** in the Play build. If it fails, add the Play app
     signing SHA-1/256 to Firebase — see `google-signin-release-notes.md` →
     "Play Console testing".
   - Complete profile → onboarding → Home; create a note; generate summary/
     flashcards/quiz; export a study pack.
   - **Account deletion** (Profile → Danger zone) returns to Auth Landing.
   - **Data Deletion URL** loads: `.../data-deletion`.

## B. Closed testing (required before production for many accounts)

1. Play Console → **Testing → Closed testing → Create track** (or use the
   default "Alpha") → **Create new release** → upload the same signed AAB (or
   promote the internal build).
2. **Testers:** add a **Google Group** (recommended) or an email list. Aim for
   **at least 12 opted-in testers** (see the 12/14 rule below).
3. Add release notes; **Save & publish** (closed releases may take longer to go
   live than internal).
4. Send the **opt-in link** to testers; each must opt in via the Play link,
   then **install, open, and actually use** the app.
5. **Track** opt-ins/installs/activity in `tester-tracking-template.md`; collect
   feedback via `tester-feedback-form.md`.
6. Watch the **Pre-launch report** and crash/ANR data
   (`pre-launch-report-checklist.md`); fix high-priority issues.
7. When Play's testing requirement is satisfied, **apply for production access**
   if Play Console prompts for it, then create a Production release.

### The 12 testers / 14 days rule (important)

Google Play may require **newer personal developer accounts** to run a **closed
test with at least 12 testers who have opted in and kept the app for 14
continuous days** before you can apply for production access. Practical notes:

- Keep **≥ 12 testers opted in continuously** for the full window — if a tester
  opts out, the count can drop and the clock effectively needs that count
  maintained.
- Testers must **actually install and open** the app, not just opt in.
- Recruit a few **extra** testers (e.g. 14–16) as a buffer against drop-off.
- The exact requirement is shown in Play Console for **your** account — follow
  the on-screen requirement text; it can differ by account type/region and can
  change over time. **[Verify in Play Console.]**

## Quick reference

| Track | Testers | Speed | Purpose |
|---|---|---|---|
| Internal | up to 100 | fast | verify the signed Play build works |
| Closed | your list / Google Group (≥12 if required) | slower | satisfy pre-production testing requirement |
| Production | public | staged | launch |
