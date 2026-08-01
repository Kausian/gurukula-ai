# Release Build Checklist — Gurukula AI

Use this for every Play Store release. Commands are Windows PowerShell, run from
the project root `D:\Gurukula App\Gurukula`.

Google Sign-In needs the server client id passed at build time via
`--dart-define`. Keep it handy (it is not a secret, but keep it consistent).

```
GOOGLE_SERVER_CLIENT_ID = 135007688251-7hpgdoiorkdjt4d5fvr7h9nekul6vviq.apps.googleusercontent.com
```

## App identity (current)

| Field | Value |
|---|---|
| App name / label | Gurukula AI |
| applicationId / package | `com.gurukula.gurukula_ai` (permanent — do not change) |
| versionName | `1.28.0` (from pubspec `version:`) |
| versionCode | `29` (the `+NN` in pubspec `version:`) |
| minSdk | 26 (ML Kit GenAI / Firebase Auth) |
| compileSdk | tracks Flutter (currently 36) |
| targetSdk | tracks Flutter (currently 36) |
| Launcher icon | `flutter_launcher_icons` → `assets/logo/app_launcher_icon.png` |

## Versioning rule

- `versionName` = human semantic version, e.g. `1.28.0`.
- `versionCode` = a **monotonically increasing integer**, e.g. `29`.
- **Never reuse a versionCode** in Play Console.
- **Every** Play upload must have a **higher versionCode** than the previous one.
- Bump both in one place: `pubspec.yaml` → `version: 1.28.0+29`
  (`versionName+versionCode`). Flutter maps them into the Android build.

## Pre-flight

- [ ] `android/key.properties` exists and points at the upload keystore
      (see `production-signing.md`). Without it, release builds are debug-signed
      and **cannot** be uploaded to Play.
- [ ] `android/app/google-services.json` present (Firebase; git-ignored).
- [ ] `pubspec.yaml` version bumped (higher versionCode than the last upload).

## Build steps

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test

# Release APK (for GitHub Releases / sideload testing)
flutter build apk --release --dart-define="GOOGLE_SERVER_CLIENT_ID=135007688251-7hpgdoiorkdjt4d5fvr7h9nekul6vviq.apps.googleusercontent.com"

# Release App Bundle (for Play Store upload)
flutter build appbundle --release --dart-define="GOOGLE_SERVER_CLIENT_ID=135007688251-7hpgdoiorkdjt4d5fvr7h9nekul6vviq.apps.googleusercontent.com"
```

## Verify outputs

- APK: `build\app\outputs\flutter-apk\app-release.apk`
- AAB: `build\app\outputs\bundle\release\app-release.aab`

Optional: copy artifacts to a local folder OUTSIDE the repo, e.g.
`D:\Gurukula App\release-builds\`, so nothing built is ever committed
(`build/`, `*.apk`, `*.aab` are git-ignored anyway).

```powershell
New-Item -ItemType Directory -Force -Path "D:\Gurukula App\release-builds"
Copy-Item "build\app\outputs\bundle\release\app-release.aab" "D:\Gurukula App\release-builds\gurukula-1.28.0-29.aab"
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "D:\Gurukula App\release-builds\gurukula-1.28.0-29.apk"
```

## Ship

- [ ] Tag the release in git (e.g. `git tag v1.28.0`).
- [ ] Upload the **AAB** to Play Console (internal testing → production track).
- [ ] Upload the **APK** only to **GitHub Releases** (never the AAB there;
      Play distributes the AAB).
- [ ] Confirm Google Sign-In works in the Play build; if not, add Play app
      signing SHA fingerprints to Firebase (`google-signin-release-notes.md`).

## No-secrets check before committing

```powershell
git status
```

Ensure none of these are staged: `key.properties`, `*.jks`, `*.keystore`,
`*.apk`, `*.aab`, `google-services.json`, `lib/firebase_options.dart`.
