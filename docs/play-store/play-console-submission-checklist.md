# Play Console Submission Checklist — Gurukula AI (v1.30.0)

End-to-end checklist for the first Play Store submission. Cross-references the
other docs in `docs/play-store/`.

## 0. Prerequisites

- [ ] Google Play Developer account (one-time registration fee paid).
- [ ] Release **AAB** built and signed with the **upload key**
      (`production-signing.md`; `release-build-checklist.md`). A debug-signed
      AAB is **not** acceptable.
- [ ] `versionCode` higher than any previous upload (this release: 32).
- [ ] Legal pages deployed and reachable: `/privacy`, `/terms`,
      `/data-deletion` on the landing domain.

## 1. Create the app

- [ ] Play Console → **Create app**.
- [ ] App name: **Gurukula AI**; default language; **App** (not game); **Free**.
- [ ] Declarations (developer program policies, US export laws).

## 2. Set up → App content

- [ ] **Privacy policy** URL: `https://<domain>/privacy`.
- [ ] **App access:** provide reviewer instructions (`reviewer-instructions.md`)
      — how to sign in, note the email/Google fallback.
- [ ] **Ads:** **No ads**.
- [ ] **Content rating:** complete the IARC questionnaire
      (`content-rating-notes.md`) — answer truthfully.
- [ ] **Target audience & content:** select the appropriate age range; app is a
      general study tool, not directed at children.
- [ ] **Data safety:** fill using `data-safety-answers.md`; add the **Data
      deletion URL** `https://<domain>/data-deletion`.
- [ ] **Government apps / Financial / Health:** No.
- [ ] **News app:** No.

## 3. Store presence → Main store listing

- [ ] **Short description** (`store-listing.md` §B — under 80 chars).
- [ ] **Full description** (`store-listing.md` §C).
- [ ] **App icon** 512×512 (`app-icon-checklist.md`).
- [ ] **Feature graphic** 1024×500 (`feature-graphic-brief.md`).
- [ ] **Phone screenshots** ×8 (`screenshot-plan.md`) — real UI, demo content.
- [ ] (Optional) 7-inch / 10-inch tablet screenshots if targeting tablets.
- [ ] **Category:** Education. **Tags:** relevant education tags.
- [ ] **Contact details:** support email **skausian@gmail.com** (+ website =
      landing domain if desired).

## 4. Store settings

- [ ] **App category:** Education.
- [ ] **Countries/regions:** choose availability.

## 5. Release → Testing first

- [ ] **Internal testing:** upload the signed AAB, add tester emails, roll out.
- [ ] Install from the internal track on a real device; run the
      `production-qa-checklist.md` manual checks.
- [ ] Verify **Google Sign-In works in the Play build**; if it fails, add the
      **Play app signing** SHA-1/256 to Firebase
      (`google-signin-release-notes.md`) and re-test.
- [ ] (If needed) **Closed testing** track for a wider group.

## 6. Pre-launch report

- [ ] Review the **Pre-launch report** (crashes, accessibility, security).
- [ ] Fix any blocking issues before promoting.

## 7. Production

- [ ] Create a **Production** release with a "What's new" note
      (`store-listing.md` §E).
- [ ] Complete the release rollout (staged rollout recommended).
- [ ] Monitor crash rate / reviews after launch.

## Final no-secrets gate

- [ ] `git status` shows no `key.properties`, `*.jks`, `*.keystore`, `*.apk`,
      `*.aab`, `google-services.json`, or `firebase_options.dart` staged.
