# Gurukula AI — User flow

How a student moves through the app, from first launch to daily study.

## First-run / authentication

```
Splash (resolving session)
  └─ not signed in → Welcome
        └─ "Continue with Google" → Google account picker → Firebase sign-in
              └─ no local profile for this account → Create Profile
                    (username, study level, subject, learning goal, language)
                    → saved to Hive → Home
              └─ profile already exists → Home
```

- The auth gate (`routerProvider` redirect) decides the destination from the
  Firebase auth state plus whether a local profile is "claimed" by the account.
- Firebase Auth persists the session, so after the first login the app reopens
  straight to Home, even offline.
- On first login the seeded sample profile is claimed in place (keeps its id, so
  any locally-owned content stays attached).

## Main navigation

A 5-tab bottom navigation: **Home · Upload · Idea Lab · Library · Profile**.

## Core study loop

```
Upload (or Home quick action) → Paste text → "Create study workspace"
  → StudyDocument saved + summary auto-generated
  → Study Workspace
       ├─ Summary    : short + detailed summary, key points
       ├─ Tools      : proofread / rewrite (simpler, formal, shorter) → saved
       ├─ Flashcards : generate → flip → mark reviewed
       └─ Quiz       : generate → take (MCQ / true-false / short answer)
                       → submit → score + per-question review → best score
```

Everything created here is written to Hive and logged as an `ActivityEvent`.

## Idea Lab loop

```
Idea Lab
  ├─ Generate new idea → brief form → preview → Save → Idea Detail
  └─ Saved idea → Idea Detail
        └─ Improve / Turn into project plan / Make CV-worthy (updates in place)
```

## Where things show up

- **Home** — greeting, offline-workspace hero, explore-tools, progress stats
  (notes / flashcards / ideas), a daily challenge, and recent activity.
- **Library** — every saved item, filterable by All / Notes / Summaries /
  Flashcards / Ideas / Quizzes.
- **Profile** — student card, study stats (including quizzes taken), live
  AI/offline status, settings (theme, privacy, delete local data) and sign out.

All of these update live as the student creates content, because the read
providers rebuild on Hive box changes.

## Settings & privacy

- **Theme** — light / dark / system, persisted locally.
- **Privacy** — a reminder that all study data is local.
- **Delete local data** — clears all study content from the device (keeps the
  profile).
- **Sign out** — ends the Google/Firebase session; local data is untouched.
