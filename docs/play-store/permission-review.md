# Permission Review — Gurukula AI (v1.27.0)

This documents every Android permission the app requests, why, and whether it is
safe. It is based on the app's own `AndroidManifest.xml` plus permissions merged
in from plugin manifests. **Verify the final set against the merged manifest**
after a build:
`build/app/intermediates/merged_manifests/debug/AndroidManifest.xml`.

## Declared in the app manifest

`android/app/src/main/AndroidManifest.xml`

| Permission | Why | Keep? |
|---|---|---|
| `android.permission.USE_BIOMETRIC` | Biometric unlock for **Privacy Lock** (`local_auth`). | **Keep** — required for biometric unlock. |

No other permissions are declared directly by the app.

## Merged in from plugins (transitive)

Confirmed against the merged manifest of the v1.27.0 debug build
(`build/app/intermediates/merged_manifest/debug/.../AndroidManifest.xml`):

| Permission | Source | Why | Keep? |
|---|---|---|---|
| `android.permission.INTERNET` | `google_sign_in`, Firebase (`firebase_auth`/`firebase_core`) | Firebase Authentication + Google Sign-In. Not used to sync study data. | **Keep** — required for sign-in. |
| `android.permission.ACCESS_NETWORK_STATE` | Firebase / Google Play services | Network availability checks for auth. | **Keep** — needed by the auth stack. |
| `android.permission.USE_BIOMETRIC` | app manifest + `local_auth` | Biometric unlock for Privacy Lock. | **Keep**. |
| `android.permission.USE_FINGERPRINT` | `local_auth` | Legacy biometric fallback for older Android. Normal permission, deprecated but harmless. | **Keep** — plugin-managed. |
| `com.google.android.providers.gsf.permission.READ_GSERVICES` | Firebase / ML Kit (Google Play services) | Read Google services framework values. Signature-level; granted only to Google-signed components. | **Keep** — plugin-managed. |
| `com.google.android.apps.aicore.service.BIND_SERVICE` | ML Kit GenAI / AICore | Bind to on-device AICore (Gemini Nano) **where supported**. Used by the ML Kit GenAI availability check + on-device generation. | **Keep** — plugin-managed. |
| `com.gurukula.gurukula_ai.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX (auto-generated) | Internal, app-private permission for a non-exported dynamic broadcast receiver. Not user-facing. | **Keep** — framework-generated. |

None of the above are Android "dangerous"/runtime permissions, so no runtime
permission prompt is shown for them and none require a sensitive-permission
declaration in Play Console.

## Not requested (by design)

- **CAMERA** — not declared. Camera scanning uses `image_picker`, which launches
  the system camera via an intent (`ACTION_IMAGE_CAPTURE`), so the app does not
  need the CAMERA permission.
- **READ_MEDIA_IMAGES / READ_EXTERNAL_STORAGE** — not declared. Gallery import
  uses the Android Photo Picker / document picker, which needs no storage
  permission on modern Android.
- No location, contacts, phone/SMS, microphone, calendar, or background
  permissions.

## Notes / actions

- The explicit `USE_BIOMETRIC` in the app manifest duplicates the one from
  `local_auth`; this is harmless (manifest merger de-duplicates). It is kept for
  clarity.
- No unnecessary or risky permissions were found. Nothing needs to be removed.
- `INTERNET` is unavoidable for Firebase Auth / Google Sign-In and is the only
  network-facing capability; the app performs **no** study-data upload, cloud
  sync, analytics, or ads network calls.
