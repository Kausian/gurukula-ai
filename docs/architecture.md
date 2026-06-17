# Gurukula AI — Architecture

Gurukula is a **privacy-first, offline-first on-device AI study assistant**.
Students paste notes, get summaries and flashcards, rewrite/proofread text, and
build project ideas. The defining rule: **study data never leaves the device.**

## Overview

```
Flutter UI (feature screens)
   │  Riverpod providers (state)        go_router (navigation + auth gate)
   ▼
Domain services
   ├── AuthService ───────────► Firebase Auth (Google identity ONLY)
   ├── StudyController ──┐
   └── AiService ◄───────┤
        ├── MockAiService (deterministic, offline fallback)
        └── OnDeviceAiService ──MethodChannel "gurukula/ai"──► Kotlin GenAiBridge
                                                               (ML Kit GenAI /
                                                                Gemini Nano via AICore)
   ▼
Repositories ──► Hive boxes  (ALL study data, local-only)
```

Three principles drive every decision:

1. **Local-first.** Hive is the single source of truth for all study content.
2. **Identity-only cloud.** Firebase is used solely for Google Sign-In.
3. **Graceful AI degradation.** On-device AI is used where available; everything
   falls back to a mock so the app works on any device.

## Flutter + Riverpod + go_router structure

Feature-first layout under `lib/`:

```
lib/
├── main.dart                  # async: Firebase.initializeApp → Hive init → seed → runApp
├── app/
│   ├── app.dart               # GurukulaApp (ConsumerWidget) → MaterialApp.router
│   ├── router.dart            # routerProvider: GoRouter + auth-gate redirect
│   └── theme.dart             # Material 3 light/dark, pastel design system
├── core/
│   ├── constants/             # branding/strings
│   ├── utils/                 # text_clean, date_format
│   └── widgets/               # AppCard, StatCard, StatusBadge, PageHeader, ...
├── data/
│   ├── local/                 # hive_boxes, hive_init, seed_data
│   ├── models/                # 7 Hive models + generated *.g.dart adapters
│   ├── repositories/          # one repository per box (CRUD + queries)
│   └── providers.dart         # repo providers + derived/reactive providers
├── features/
│   ├── auth/                  # auth_providers (authStateProvider, currentUserProvider)
│   ├── onboarding/            # splash, welcome, create_profile
│   ├── home/ upload/ library/ profile/ idea_lab/
│   └── study/                 # paste_text, study_workspace, study_providers, tabs
└── services/
    ├── ai_service.dart        # AiService interface + DTOs + AiAvailability
    ├── mock_ai_service.dart
    ├── on_device_ai_service.dart
    ├── auth_service.dart
    └── auth_config.dart
```

- **State:** Riverpod. Repositories and services are exposed as `Provider`s;
  derived read-models (dashboard stats, recent activity, library list, workspace
  data) are computed providers.
- **Navigation:** `go_router`, created inside `routerProvider` so the redirect
  reacts to auth state. The 5 primary tabs live in a `StatefulShellRoute`; the
  Paste screen and Study Workspace are full-screen routes on the root navigator.

### Reactivity (important detail)

Derived providers rebuild automatically when Hive changes, via
`dataChangesProvider` — a `StreamProvider<int>` that merges every box's
`watch()` stream and emits a **distinct incrementing value** per change.

> It must emit distinct values: an earlier `StreamProvider<void>` emitting
> `null` was deduped by Riverpod (`AsyncData<void>(null)` equals the previous
> one), so live updates after the first stopped firing. Emitting an `int` fixes
> it. Providers that read data do `ref.watch(dataChangesProvider)` for the side
> effect of rebuilding.

## Hive local data layer

All study data is stored locally in Hive (no cloud database). Boxes are opened
at startup in `data/local/hive_init.dart` before `runApp`, so repositories read
them synchronously.

Seven models with fixed Hive `typeId`s (never renumber once data exists):

| typeId | Model | typeId | Model |
|---|---|---|---|
| 0 | `UserProfile` | 4 | `Rewrite` |
| 1 | `StudyDocument` | 5 | `Idea` |
| 2 | `Summary` | 6 | `ActivityEvent` |
| 3 | `Flashcard` | 7–10 | enums (DocumentType, RewriteTone, Difficulty, ActivityType) |

- **Repositories** wrap each box with CRUD plus domain queries
  (`byDocument`, `recent`, `byGoogleUid`, ...). A generic `HiveRepository<T>`
  base provides the shared operations.
- **`ActivityEvent`** is the single source of truth for dashboard stats and the
  recent-activity feed; every meaningful action logs one.
- Adapters are generated with `hive_ce_generator` (`*.g.dart` + a
  `lib/hive_registrar.g.dart`) and committed.
- All timestamps are stored in **UTC**.

## Firebase Auth — identity only

Firebase is used for **one thing: Google Sign-In**. No Firestore, no Storage,
no Functions, no Analytics.

```
Splash → not signed in            → Welcome → "Continue with Google"
       → signed in, no profile     → Create Profile (saved to Hive)
       → signed in + local profile → Home (shell)
```

- `AuthService` wraps `firebase_auth` + `google_sign_in`. A successful sign-in
  provides only the student's Google **name, email and photo**.
- The router's redirect is driven by `authStateProvider` plus whether a local
  `UserProfile` has been "claimed" by the signed-in account (`byGoogleUid`).
- On first sign-in, the existing local profile (including the seeded sample) is
  **claimed in place**: the same record keeps its id and gains the Google
  identity, so all locally-owned documents/ideas stay correctly attached.
- Firebase Auth persists the session locally, so after the one-time login the
  app opens straight to Home with no internet.

Config files (`android/app/google-services.json`, `lib/firebase_options.dart`)
are git-ignored and regenerated per machine. See `docs/firebase-setup.md`.

## AI: one interface, swappable implementations

`AiService` (`lib/services/ai_service.dart`) is the single abstraction the app
codes against:

```dart
abstract class AiService {
  Future<AiAvailability> checkAvailability();          // available/downloading/unsupported/mock
  Future<AiSummary> summarizeText(String text);
  Future<List<AiFlashcardDraft>> generateFlashcards(String text, {int count});
  Future<String> proofreadText(String text);
  Future<String> rewriteText(String text, RewriteTone tone);
}
```

`StudyController` only ever talks to `AiService`, so swapping implementations
changes nothing upstream. The implementation is chosen in `study_providers.dart`:

```dart
final aiServiceProvider = Provider<AiService>((ref) {
  const fallback = MockAiService();
  if (!kIsWeb && Platform.isAndroid) {
    return OnDeviceAiService(fallback: fallback);
  }
  return fallback;
});
```

### MockAiService (fallback)

A deterministic, fully-offline implementation using simple text heuristics
(sentence splitting for summaries/key points, Q/A drafts for flashcards, tone
transforms for rewrites). It is the safety net: the entire study flow works
through it on any device, with no model and no network.

### OnDeviceAiService (MethodChannel bridge)

The Android implementation. It calls the native `gurukula/ai` MethodChannel and
is **defensive per feature**: any missing plugin, unavailable model, or error
transparently falls back to the mock for that call.

- `summarizeText` / `proofreadText` / `rewriteText` → try native, else mock.
- `generateFlashcards` → always mock (ML Kit GenAI has no flashcard API).
- `checkAvailability` → maps the native status string to `AiAvailability`; the
  Profile "AI and offline status" card shows it live.

On a supported device this silently upgrades summaries/rewrites/proofreading to
real on-device inference, with **zero changes to the study screens.**

### Kotlin GenAiBridge

`android/app/src/main/kotlin/com/gurukula/gurukula_ai/GenAiBridge.kt` registers
the MethodChannel (set up in `MainActivity.configureFlutterEngine`). It is the
boundary to **ML Kit GenAI**, which runs on **Gemini Nano via AICore**.

Current state (skeleton): `checkAvailability` returns `"unsupported"`, and the
inference methods return an error so Flutter uses the mock. This is the correct
result wherever AICore is absent. The real ML Kit GenAI wiring is documented as
TODOs inside the file.

## Why the emulator shows "Not supported"

Gemini Nano runs through **AICore**, which is only present on specific high-end
devices (e.g. Pixel 8+/9, Galaxy S24+). **Standard Android emulators do not ship
AICore**, so `checkAvailability` truthfully reports `"unsupported"`, and the app
runs every AI feature through `MockAiService`. This is expected and correct: the
bridge and the graceful fallback are exactly what's being demonstrated.

## Enabling real Gemini Nano / ML Kit GenAI later

On a supported physical device:

1. Add ML Kit GenAI dependencies in `android/app/build.gradle.kts` and set
   `minSdk` to 26:
   ```
   implementation("com.google.mlkit:genai-summarization:<version>")
   implementation("com.google.mlkit:genai-rewriting:<version>")
   implementation("com.google.mlkit:genai-proofreading:<version>")
   ```
2. In `GenAiBridge.kt`, create the clients (Summarization / Rewriting /
   Proofreading) and:
   - `checkAvailability()` → combine each client's `checkFeatureStatus()`
     (`AVAILABLE` → `"available"`, `DOWNLOADABLE`/`DOWNLOADING` →
     `"downloading"`, `UNAVAILABLE` → `"unsupported"`).
   - `summarize` / `proofread` / `rewrite` → `downloadFeature()` if needed, then
     `runInference(...)` and reply with `result.success(text)` (post the reply
     on the main thread).
   - Close the clients in `dispose()`.
3. No Dart changes are required: `OnDeviceAiService` already maps the status
   strings and falls back per feature, and the Profile card already shows the
   live status. The first run downloads the Nano model via AICore (the
   "Downloading" state).

## Privacy & cost guarantees

- **Study data stays local.** Documents, summaries, flashcards, rewrites, ideas
  and activity live only in Hive on the device. Nothing is uploaded to a server.
- **Firebase is identity-only.** Google Sign-In provides a name, email and
  photo; no study content is sent to Firebase (no Firestore/Storage/Functions).
- **No cloud AI.** Summaries/rewrites run on-device (Gemini Nano) or via the
  local mock. No Gemini Cloud API, no OpenAI, no paid services.
- **Zero-cost.** Firebase Auth + Google Sign-In are free (Spark plan); on-device
  AI and Hive are free; the app needs no backend.
```
