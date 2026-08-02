# Content Rating Notes — Gurukula AI (v1.30.0)

Guidance for the Play Console **Content Rating (IARC) questionnaire**. This is
**not legal advice** — answer every Play Console question **truthfully based on
the final app behavior**. The IARC questionnaire generates region-specific
ratings from your answers.

App type: **Education / study utility** (reference/productivity), no game
content.

## Likely answers (verify against the final build)

| Topic | Expected answer | Why |
|---|---|---|
| Violence (realistic/fantasy/graphic) | **No** | None in the app. |
| Sexual content / nudity | **No** | None. |
| Profanity / crude humor | **No** | App UI has none. Generated content comes from the *user's own notes*. |
| Gambling / simulated gambling | **No** | None. |
| Alcohol, tobacco, drugs (use/reference) | **No** | Not promoted; only if a user's own notes mention them academically. |
| Horror / fear themes | **No** | None. |
| User-generated content shared publicly | **No** | Study content is local; no public feed or community. |
| User-to-user communication / chat | **No** | No messaging, no anonymous chat. |
| Shares user location | **No** | No location access. |
| Digital purchases / in-app purchases | **No** | None currently. |
| Contains ads | **No** | No ads. |
| Requires/uses sign-in | **Yes** | Firebase Auth (Google / email). |
| Accesses camera/photos | **Yes, for user-initiated note import/OCR only** | Camera scan + gallery import. |

## Notes for the questionnaire

- If asked about **user-generated content**: the app lets a user create private
  study notes on their own device; there is **no** sharing to other users or a
  public audience inside the app. (Users can manually export/share a file via
  the OS share sheet — that is user-controlled, outside the app.)
- **Generated study content** depends on the user's own provided notes; the app
  does not inject mature or objectionable content.
- Target audience: general students (school/university/self-study). Set the
  **Target Audience** section to the appropriate age range for your market; the
  app is a general study tool, not directed at young children, and collects no
  data beyond auth. **Verify** the exact target-age selection in Play Console.

## Reminder

Answer the live Play Console / IARC questions yourself based on the shipping
build. If any feature changes (e.g. adding chat, ads, or purchases), redo the
questionnaire.
