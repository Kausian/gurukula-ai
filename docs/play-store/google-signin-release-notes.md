# Google Sign-In — Release / Play Store Notes (Gurukula AI)

Google Sign-In works in debug because the debug SHA-1 is registered in the
Firebase project. **Release/Play builds are signed with different keys**, so
their SHA fingerprints must also be registered or Google Sign-In will fail (a
sign-in that returns/cancels with no account, or an `ApiException 10`).

## Why it can break in release

- Debug builds are signed with the local **debug** keystore.
- Release builds are signed with your **upload key**.
- With **Play App Signing**, Google re-signs the app for distribution with the
  **app signing key** — a third, different fingerprint.
- Google Sign-In / Firebase authorize by **package name + SHA-1/SHA-256**. Every
  signing identity that end users run must be registered.

## What to register in Firebase

In Firebase Console → Project settings → Your app (`com.gurukula.gurukula_ai`)
→ **Add fingerprint**, add SHA-1 **and** SHA-256 for:

1. **Upload key** — for release APKs you test outside Play (e.g. GitHub Release
   downloads) and for internal testing before Play re-signing is in effect.
2. **Play app signing key** — for what real users install from Play. Get these
   from Play Console after Play App Signing is enabled (see below).

After adding fingerprints, re-download the updated `google-services.json` and
replace `android/app/google-services.json` (git-ignored). Do **not** edit
Firebase config blindly — only add fingerprints; don't remove existing ones.

## How to get the SHA fingerprints

**Upload key (from the keystore):**

```powershell
keytool -list -v `
  -keystore "D:\Gurukula App\keystores\gurukula-upload-key.jks" `
  -alias gurukula-upload
```

**Via Gradle (once `android/key.properties` is set):**

```powershell
cd android
.\gradlew signingReport
```

Look for the `release` variant's SHA-1 / SHA-256.

**Play app signing key (after Play App Signing is enabled):**

Play Console → your app → **Setup → App integrity → App signing** →
copy the SHA-1 and SHA-256 under "App signing key certificate".

## Order of operations

1. Enable Play App Signing on first release.
2. Add **upload key** SHA-1/SHA-256 to Firebase (for pre-Play testing).
3. Once Play App Signing is active, add the **Play app signing** SHA-1/SHA-256
   to Firebase.
4. Replace `google-services.json`, rebuild, and verify Google Sign-In in a
   Play internal-testing build.

## Notes

- The `GOOGLE_SERVER_CLIENT_ID` passed via `--dart-define` (OAuth **web** client
  id) is the same across debug/release and is not a secret.
- Email/password sign-in does **not** depend on SHA fingerprints; only Google
  Sign-In does.
