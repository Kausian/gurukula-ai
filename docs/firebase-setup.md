# Firebase setup (Gurukula AI)

Gurukula uses Firebase for **one thing only: Google Sign-In (identity)**. Follow
these steps to configure it on a fresh machine. None of this stores study data
in the cloud, and none of it requires a paid plan.

## What Firebase is (and isn't) used for

- **Used:** Firebase Authentication with the **Google** sign-in provider, for
  identity only (name, email, profile photo).
- **Not used:** Firestore, Cloud Storage, Cloud Functions, Analytics. None of
  these are enabled or required.
- **Study data stays local.** All documents, summaries, flashcards, rewrites,
  ideas and activity live in **Hive on the device**. Nothing is uploaded to a
  server. Sign-in only attaches a Google identity to the local profile.
- **Cost:** Firebase Auth + Google Sign-In are free on the Spark (no-cost) plan.
  No billing account is needed.

## Prerequisites

- Flutter SDK installed and on `PATH`.
- A Google account.
- Firebase CLI and FlutterFire CLI:
  ```bash
  npm install -g firebase-tools          # or use the standalone installer
  firebase login
  dart pub global activate flutterfire_cli
  ```

## 1. Create the Firebase project

1. Go to https://console.firebase.google.com and click **Add project**.
2. Name it (for example `Gurukula AI`).
3. **Google Analytics can be disabled** — it is not used.

## 2. Enable Google Authentication

1. In the project: **Build → Authentication → Get started**.
2. Open the **Sign-in method** tab.
3. Enable the **Google** provider, set a project support email, and save.
4. Do **not** enable any other product (no Firestore, Storage, or Functions).

## 3. Android app details

- **Package name / application id:** `com.gurukula.gurukula_ai`
  (defined in `android/app/build.gradle.kts`; it must match the Firebase
  Android app exactly).
- `minSdk` is already set to `maxOf(23, flutter.minSdkVersion)` because Firebase
  Auth requires API 23+.

## 4. SHA-1 and SHA-256 fingerprints

Google Sign-In on Android fails with `ApiException: 10` unless the signing
certificate fingerprints are registered with Firebase.

Get the **debug** fingerprints for your machine:

```bash
cd android
./gradlew signingReport      # Windows: .\gradlew.bat signingReport
```

Copy the `SHA1:` and `SHA-256:` values shown under `Variant: debug`. Then in the
Firebase console: **Project settings → your Android app → Add fingerprint**, and
add **both** the SHA-1 and the SHA-256.

> Each machine's debug keystore is different, so every developer adds their own
> debug fingerprints. Add your **release** keystore fingerprints later when you
> ship a signed build.

## 5. Generate the Flutter config (FlutterFire CLI)

From the project root:

```bash
flutterfire configure
```

- Select the Firebase project from step 1.
- Select the **Android** platform.

This registers the Android app, downloads **`google-services.json`** into
`android/app/`, and generates **`lib/firebase_options.dart`**.

## 6. google-services.json placement

The file must live at:

```
android/app/google-services.json
```

The Gradle Google Services plugin (configured in `android/settings.gradle.kts`
and `android/app/build.gradle.kts`) reads it at build time. The build fails if it
is missing.

## 7. firebase_options.dart note

`flutterfire configure` generates `lib/firebase_options.dart`. The app currently
calls `Firebase.initializeApp()` with no arguments, which works on Android via
`google-services.json`. If you want explicit, multi-platform initialization, you
can switch `lib/main.dart` to:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

(and import `firebase_options.dart`).

## 8. Google server client ID (required for sign-in)

`google_sign_in` 7.x needs the Firebase **Web client ID** as the *server client
id* so it can return an idToken that Firebase accepts.

Find it in the Firebase console under
**Authentication → Sign-in method → Google → Web SDK configuration → "Web client
ID"** (it looks like `xxxxxxxx.apps.googleusercontent.com`). It is also present
in `google-services.json` as the `oauth_client` entry with `client_type: 3`.

Provide it at run time with `--dart-define`:

```bash
flutter run -d emulator-5554 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

(See `lib/services/auth_config.dart`, which reads `GOOGLE_SERVER_CLIENT_ID`.)

On an emulator, sign into a Google account once (Settings → Accounts) so the
account picker has an account to choose.

## 9. Files that are git-ignored (regenerate locally)

These contain machine/project-specific config and are intentionally **not**
committed. Every machine must regenerate them with the steps above:

- `android/app/google-services.json` (from `flutterfire configure` or the
  Firebase console)
- `lib/firebase_options.dart` (from `flutterfire configure`)

Both are listed in `.gitignore`. After cloning the repo, run
`flutterfire configure` to recreate them before building.

## Quick recap

1. Create project, enable Google Auth.
2. `flutterfire configure` (Android) → drops `google-services.json` and
   `firebase_options.dart`.
3. Add debug SHA-1 + SHA-256 to the Firebase Android app.
4. Copy the Web client ID and run with
   `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
5. Sign in. Study data stays local in Hive.
