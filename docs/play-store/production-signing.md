# Production Signing — Gurukula AI (v1.28.0)

How to create the upload keystore and wire it into release builds. Do this once,
locally. **Nothing here is committed to the repo.**

---

## 1. Concepts (read first)

- **Upload key** — the key YOU hold. You sign every build with it and upload to
  Play. This is the keystore you create below.
- **App signing key** — the key Google holds when **Play App Signing** is
  enabled (recommended). Google re-signs your uploaded bundle with it for
  distribution. You never see it.
- The **upload key and app signing key are different**. If you ever lose the
  upload key, Google can reset it (with Play App Signing enabled). If you are
  NOT using Play App Signing, losing the key means you cannot update the app.
- **Back up the keystore securely and never commit it.** If lost, future updates
  become difficult (or impossible without Play App Signing).

## 2. Generate the upload keystore (Windows PowerShell)

Store it **outside the repo**. Example location: `D:\Gurukula App\keystores\`.

```powershell
# Create a folder for keystores OUTSIDE the git repo
New-Item -ItemType Directory -Force -Path "D:\Gurukula App\keystores"

# Generate the upload keystore (keytool ships with the JDK)
keytool -genkeypair -v `
  -keystore "D:\Gurukula App\keystores\gurukula-upload-key.jks" `
  -storetype JKS `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias gurukula-upload
```

`keytool` prompts for a keystore password, a key password (press Enter to reuse
the store password), and your name/org details. **Remember these passwords** —
store them in a password manager.

If `keytool` is not found, use the one bundled with Android Studio's JDK, e.g.:

```powershell
& "$env:LOCALAPPDATA\Programs\Android Studio\jbr\bin\keytool.exe" -genkeypair -v `
  -keystore "D:\Gurukula App\keystores\gurukula-upload-key.jks" `
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias gurukula-upload
```

## 3. Create android/key.properties

Copy the template and fill in real values:

```powershell
Copy-Item "android\key.properties.example" "android\key.properties"
```

Edit `android/key.properties` (absolute path, escaped backslashes on Windows):

```
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=gurukula-upload
storeFile=D:\\Gurukula App\\keystores\\gurukula-upload-key.jks
```

`android/key.properties` is git-ignored. **Do not commit it.**

## 4. How the Gradle config uses it

`android/app/build.gradle.kts`:

- If `android/key.properties` **exists**, release builds are signed with your
  upload key.
- If it is **absent**, release builds fall back to the **debug** key so the
  build still runs — but **those artifacts cannot be uploaded to Play** (they
  are debug-signed). Create `key.properties` before producing a real release.

No passwords or keystore paths live in the repo — only in your local,
git-ignored `key.properties` and the keystore outside the repo.

## 5. Play App Signing (in Play Console)

- When creating the app / first release, **opt in to Play App Signing**
  (default and recommended).
- Upload your first AAB signed with the **upload key**. Google generates and
  stores the **app signing key**.
- After this, if Google Sign-In fails in Play builds, add the **Play app signing
  SHA-1/SHA-256** to Firebase — see `google-signin-release-notes.md`.

## 6. Get SHA fingerprints (for Firebase / OAuth later)

From the keystore directly:

```powershell
keytool -list -v `
  -keystore "D:\Gurukula App\keystores\gurukula-upload-key.jks" `
  -alias gurukula-upload
```

Or via Gradle (once `key.properties` is set):

```powershell
cd android
.\gradlew signingReport
```

The Play **app signing** SHA fingerprints appear in Play Console → your app →
**Setup → App integrity** after Play App Signing is enabled.

## Safety checklist

- [ ] Keystore saved outside the repo (`D:\Gurukula App\keystores\...`).
- [ ] Keystore backed up securely (password manager / encrypted backup).
- [ ] Passwords stored in a password manager.
- [ ] `android/key.properties` created locally, **not** committed.
- [ ] Play App Signing enabled in Play Console.
