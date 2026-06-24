<div align="center">
  <img src="docs/brand/Gurukula-logo.png" width="150" alt="Gurukula AI Logo" />
  <br/>
  <h1>Gurukula AI</h1>

  <p><strong>Study smarter, even when the internet does not help.</strong></p>

  <p>A privacy-first, offline-focused study assistant app for students.</p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android" />
    <img src="https://img.shields.io/badge/Min%20SDK-API%2026-3DDC84" alt="Min SDK 26" />
    <img src="https://img.shields.io/badge/State-Riverpod-7E57C2" alt="Riverpod" />
    <img src="https://img.shields.io/badge/Storage-Hive-FFCA28" alt="Hive" />
    <img src="https://img.shields.io/badge/On--device%20AI-ML%20Kit%20GenAI-4285F4?logo=google&logoColor=white" alt="ML Kit GenAI" />
  </p>
</div>

---

## 📖 Overview

Gurukula AI is a privacy-first, offline-focused study assistant built for students who want to study smarter without depending on constant internet access, paid AI tools, or cloud-based services.

The app helps students turn pasted notes, .txt files, text-based PDFs, gallery images, and camera-scanned printed notes into useful study materials such as summaries, flashcards, quizzes, revision cards, and project ideas.

Gurukula AI is designed around a local-first workflow. Study data is stored on the device, OCR runs on-device, and the core study experience remains usable even without a network connection.

Where supported, Gurukula AI uses ML Kit GenAI / Gemini Nano for real on-device summary generation. On unsupported devices, it safely falls back to a built-in local generator so the app remains reliable and usable.

---

## 📱 Screenshots

### ☀️ Light mode

| Login | Home | Upload |
|---|---|---|
| <img src="docs/screenshots/login.jpg" width="240" alt="Login screen" /> | <img src="docs/screenshots/home.jpg" width="240" alt="Home dashboard" /> | <img src="docs/screenshots/upload.jpg" width="240" alt="Upload screen" /> |

| Idea Lab | Library | Profile |
|---|---|---|
| <img src="docs/screenshots/idealab.jpg" width="240" alt="Idea Lab" /> | <img src="docs/screenshots/library.jpg" width="240" alt="Library" /> | <img src="docs/screenshots/profile.jpg" width="240" alt="Profile" /> |

### 🌙 Dark mode

| Dark Home | Dark Upload |
|---|---|
| <img src="docs/screenshots/dark-home.jpg" width="240" alt="Home in dark mode" /> | <img src="docs/screenshots/dark-upload.jpg" width="240" alt="Upload in dark mode" /> |

| Dark Idea Lab | Dark Profile |
|---|---|
| <img src="docs/screenshots/dark-idealab.jpg" width="240" alt="Idea Lab in dark mode" /> | <img src="docs/screenshots/dark-profile.jpg" width="240" alt="Profile in dark mode" /> |

---

## Key features

| Area | What you get |
|------|--------------|
| **Capture notes** | Paste text · import `.txt` · import text-based PDFs |
| **Scan notes (OCR)** | Pick an image from the gallery or take a photo, extract text on-device |
| **Summaries** | Short summary, detailed summary, and key points |
| **Real on-device AI** | On-device summary generation where ML Kit GenAI / Gemini Nano is available |
| **Safe fallback** | A built-in generator produces summaries on unsupported devices |
| **Source transparency** | Each summary shows a badge: **On-device AI** or **Fallback mode** |
| **Study tools** | Flashcards · quizzes · revision mode · smart spaced practice |
| **Idea Lab** | Generate, refine, and plan project ideas locally |
| **Library** | Search, filter, sort, and open everything you've created |
| **Share & export** | Copy, share, and export study content as `.txt` |
| **Account** | Google Sign-In (identity only) · dynamic app version · feedback/contact option |
| **Polish** | Light & dark mode · overflow-safe, font-scaling-friendly UI |

---

## How it works

1. **Add material** — paste text, import a `.txt`/PDF, pick a gallery image, or scan a page with the camera.
2. **Extract text** — text files and PDFs are read directly; images run through **on-device OCR** (ML Kit Text Recognition).
3. **Review & edit** — a preview screen lets you clean up the extracted text before saving.
4. **Create a study workspace** — Gurukula AI generates a **summary** (on-device AI where available, fallback otherwise), then flashcards and a quiz on demand.
5. **Revise** — practice flashcards, take quizzes, and let **smart spaced practice** schedule what's due.
6. **Organize & share** — find anything in the **Library**, and copy / share / export to `.txt`.

Everything is stored **locally**. Nothing is uploaded to a server.

---

## Tech stack

| Layer | Technology |
|-------|------------|
| **App** | Flutter · Dart |
| **State management** | Riverpod |
| **Local storage** | Hive (local-first, single source of truth) |
| **Auth** | Firebase Auth · Google Sign-In (identity only) |
| **Native bridge** | Kotlin · `MethodChannel` |
| **OCR** | ML Kit Text Recognition (on-device, Latin script) |
| **On-device GenAI** | ML Kit GenAI / Gemini Nano / Android AICore *(where supported)* |
| **Architecture** | Local-first, offline-focused, fallback-safe |

---

## Architecture overview

```
Flutter UI (Riverpod)
        │
        ▼
  Study controllers / providers
        │
        ├──► Hive repositories ──► Local device storage (all study data)
        │
        └──► AiService (interface)
                 ├── OnDeviceAiService ──(Kotlin MethodChannel)──► ML Kit GenAI / Gemini Nano
                 │         └── falls back automatically on any failure
                 └── MockAiService ─────────────────────────────► safe built-in fallback
```

- **One `AiService` interface, two implementations.** The on-device service tries real ML Kit GenAI; if the device is unsupported, the model isn't ready, or anything errors or times out, it **transparently falls back** to the built-in generator.
- **Hive is the single source of truth** for notes, summaries, flashcards, quizzes, ideas, and revision data.
- **Firebase is used only for identity** (Google Sign-In) — no study data is sent anywhere.

---

## 🔒 Privacy-first design

- **Your study data stays on your device**, stored locally with **Hive**.
- **No cloud sync, no backend, no analytics of your notes.**
- **No OpenAI API and no cloud Gemini API.** AI runs **on-device** where supported.
- **OCR is on-device** — images are processed locally and never uploaded.
- **Google Sign-In is identity only**; it does not store or read your study content.

---

## On-device AI explanation

Gurukula AI is **ready** for on-device generative AI but never **depends** on it:

- ✅ **Available** → real **on-device summary generation** via **ML Kit GenAI / Gemini Nano**, and the summary is tagged **“Generated by On-device AI.”**
- 🟡 **Preparing / downloadable** → uses **fallback mode** and tells you the model isn't ready yet.
- ⚪ **Not supported** → uses **fallback mode**; the app remains fully usable.

**Important honesty notes:**
- Real on-device summary generation works **only where the device supports** ML Kit GenAI / Gemini Nano (e.g. select recent high-end Android devices with AICore).
- **Fallback mode remains active** as the safety net on every other device, and for flashcards, quizzes, ideas, and rewrites.
- This phase wires **summary generation** to on-device AI; other features currently use the built-in generator.

---

## OCR limitations

- ✅ **Works best with clear, printed/typed English text.**
- ✍️ **Handwriting may be inaccurate** — messy notebook photos can produce poor results.
- 🌐 **Sinhala and Tamil OCR are not supported yet.**
- 📶 On some Android devices, the OCR model setup may need Google Play Services **once**.

---

## 📥 How to Download & Install

Gurukula AI is currently distributed through GitHub Releases as an Android APK while the app is still in active portfolio development.

1. Navigate to the **GitHub Releases** page of this repository.

2. Download the latest `.apk` file, for example:

   ```text
   gurukula-ai-v1.15.0.apk
   ```

3. Transfer the APK to your Android device if you downloaded it on a computer.

4. Open the downloaded APK on your Android phone.

5. When prompted, allow your browser or file manager permission to **Install unknown apps**.

6. Follow the Android installer instructions to complete the installation.

> **Minimum Android requirement:** Android 8.0 / API 26 or higher.
> This is required after the ML Kit GenAI / on-device AI integration.

---

## 🛠️ Build from Source

To build Gurukula AI locally, make sure you have:

* Flutter SDK installed
* Android Studio / Android SDK configured
* A connected Android device or emulator
* Firebase `google-services.json` configured for Google Sign-In

Then run:

```bash
flutter pub get
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For development testing, run:

```bash
flutter run
```


---

## 🚧 Current limitations

- On-device AI generation currently covers **summaries only**; flashcards, quizzes, ideas, and rewrites use the built-in fallback generator.
- Real on-device AI is **device-dependent** — most devices will run in **fallback mode**.
- **OCR is English / Latin-script and printed-text focused**; handwriting and Sinhala/Tamil are not supported yet.
- **Android only** (no iOS build configured).
- **Minimum Android SDK is API 26.**

---

## 🗺️ Roadmap

- [ ] Extend on-device generation to **flashcards** and **quizzes**
- [ ] Optional, user-initiated **on-device model download**
- [ ] Improved OCR guidance and image pre-processing
- [ ] Additional export formats
- [ ] Broader language support (future)

---

## 📌 Project status

**Active.** Current version: **v1.15.0**. The core study workflow, OCR, real on-device summary availability, and on-device summary generation (with fallback) are implemented and verified on-device.

---

## 👨‍💻 Developer

Built by **Kausian** as a real, problem-solving study app for students — not just a demo.
- **Feedback / contact:** in-app **“Send feedback”** option (Profile → Settings)

---

## License
License details will be added later.
