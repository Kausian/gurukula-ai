# Responsive UI QA Checklist — Gurukula AI (v1.31.1)

A focused manual + automated pass for the **v1.31.1 "Android Responsive UI
Compatibility Polish"** hotfix. The goal: confirm the app looks clean and never
overflows across small, medium and large Android phones, at large system font
sizes and display zoom, with the keyboard open, and around the system
navigation bar.

Identity for this release: **versionName 1.31.1 · versionCode 34 ·
`com.gurukula.gurukula_ai`**.

The app was already tuned on a Samsung S24 Ultra; this pass is about the phones
that are *not* that.

---

## Automated gates (must pass)

- [x] `flutter analyze` → no issues
- [x] `flutter test` → all pass (includes `test/responsive_test.dart`)
- [x] `flutter build apk --release --dart-define="GOOGLE_SERVER_CLIENT_ID=…"`
- [x] `flutter build appbundle --release --dart-define="GOOGLE_SERVER_CLIENT_ID=…"`

---

## Test device buckets

Run the manual items on at least one device/emulator per bucket. Where a real
device isn't available, use an emulator AVD at the listed resolution.

| Bucket | Target | Notes |
| --- | --- | --- |
| Small phone | ~360 × 640 (mdpi/hdpi) | The tightest common size; where overflow shows first |
| Medium phone | Pixel 5 / Pixel 6 class | The mainstream case |
| Large phone | Samsung S24 Ultra class | Known-good baseline; check it still looks premium |
| Tall phone | Modern 20:9 (e.g. 412 × 915) | Long content + gesture nav |
| Tablet/foldable (sanity) | 7–8" or unfolded | Content should center, not stretch edge-to-edge |

## Global font / display settings to sweep

For each device bucket, at minimum sweep:

- [ ] **Default** font size + default display size
- [ ] **Largest** system font size (Settings → Display → Font size = max)
- [ ] **Display zoom / size = larger** (Settings → Display → Display size)
- [ ] Gesture navigation **and** 3-button navigation (nav bar overlap)

> Accessibility note: the app intentionally lets body text grow with the system
> font. Only a few fixed-height chrome elements (bottom nav labels, the Home
> "Explore tools" strip, the Library filter chip rows) cap or grow their scale
> so they can't clip. Large font must remain usable everywhere.

---

## 1. Auth & onboarding (highest priority on small phones)

- [ ] **Auth Landing** — logo, title, three actions and the privacy line all fit;
      scrolls (doesn't overflow) on a small phone at largest font.
- [ ] **Login** — form scrolls; keyboard does not cover the Sign in button; the
      "Don't have an account? Sign up" line wraps instead of overflowing at
      large font.
- [ ] **Sign Up** — all fields reachable with the keyboard open; dropdowns show
      full text; the "Already have an account? Log in" line wraps at large font.
- [ ] **Complete Student Profile** — scrolls; dropdowns (`Study level`,
      `Study goal`) don't clip long values; Save button reachable with keyboard.
- [ ] **Onboarding** — each of the 5 pages stays centered when there's room and
      scrolls (no overflow) on a short screen / at largest font; dots + Next
      button always visible; Skip/Close reachable.
- [ ] On a tablet/foldable, the auth forms **center** (max ~560dp) rather than
      stretching full width.

## 2. Home & study screens

- [ ] **Home** — header, hero card, "Explore tools" strip, stat rows, revision,
      planner, challenge and recent activity all fit; nothing clipped at large
      font. The "Explore tools" cards grow with font size (labels not cut off).
- [ ] **Upload** — option cards and the privacy note fit; the "Scan notes"
      bottom sheet (gallery/camera) sits above the nav bar.
- [ ] **Paste text / New note** — body field fills the screen; the action and
      privacy line stay above the keyboard.
- [ ] **Import preview** — extracted text is editable; Create button reachable.
- [ ] **Note Workspace** — the 5 tabs (Note/Summary/Tools/Flashcards/Quiz)
      scroll; scrollable tab bar; long titles ellipsize in the app bar.
- [ ] **Summary** — length chips wrap; source line + actions never overflow.
- [ ] **Flashcards** — count + share/add-cards actions **stack** instead of
      overflowing at large font; cards scroll.
- [ ] **Quiz (tab)** — "Quiz ready" card fits; share/regenerate actions stack.
- [ ] **Quiz (taking)** — question scrolls; Back/Next row fits; result review
      and Retake/Done buttons fit.
- [ ] **Revision** — card scrolls; Easy/Medium/Hard buttons share the row evenly
      at large font.
- [ ] **Study Planner** — goal cards fit; countdown never collides with the
      title.
- [ ] **Study goal form** — date row: a long date ellipsizes and never collides
      with "Change"; SegmentedButton readable; linked-note dropdown ellipsizes.
- [ ] **Library** — search + both filter chip rows scroll horizontally; the
      "N items / source / sort" controls stack instead of overflowing at large
      font; note/rewrite tiles ellipsize.
- [ ] **Idea Lab / Idea detail / Idea form** — mode cards, refine chips (wrap),
      dropdowns and preview all fit; notes dialog is keyboard-safe.

## 3. Profile, privacy & data flows

- [ ] **Profile** — all sections fit; setting rows ellipsize values; nothing
      clipped at large font.
- [ ] **Privacy Lock settings** — cards, switches and the info line fit.
- [ ] **Lock screen** — centered, scrolls at large font; PIN field, Unlock and
      biometric actions reachable with the keyboard open; the footer line wraps.
- [ ] **Delete Account** — the "what gets deleted" list, password field, DELETE
      field and the red button all reachable with the keyboard open.
- [ ] **Clear Local Study Data** — confirmation dialog readable; buttons fit.
- [ ] **Export Study Pack / share actions** — remain visible and tappable.

## 4. Dialogs & bottom sheets

- [ ] **Set PIN / Enter PIN** dialogs scroll and stay above the keyboard at
      large font (`scrollable`).
- [ ] **Notes** dialog (Idea detail) scrolls with the keyboard open.
- [ ] **Theme picker**, **Send feedback**, **Privacy**, **Clear data**,
      **Delete goal**, **Regenerate quiz**, **Discard changes** dialogs fit and
      never overflow at large font.
- [ ] **Scan notes** and **Rewrite preview** bottom sheets respect SafeArea, cap
      their height and scroll their content.

## 5. System chrome

- [ ] **Bottom navigation** — all 5 labels (Home/Upload/Idea Lab/Library/
      Profile) render without clipping at largest font (labels are scale-capped).
- [ ] **Navigation bar overlap** — no content or FAB hidden behind the gesture
      pill / 3-button bar; scroll lists end above it.
- [ ] **Keyboard** — no form action is permanently hidden behind the keyboard on
      any screen.
- [ ] **Landscape** — auth, onboarding, quiz and revision don't hard-overflow
      (they scroll). Full landscape polish is out of scope for this hotfix.

## 6. Regression guards (must still hold)

- [ ] Large-phone (S24-class) layout still looks premium — no new empty gutters
      or shrunken content.
- [ ] Startup still reaches Auth Landing on a fresh signed-release install.
- [ ] No behavior/feature changes — this was a layout-only pass.

---

## Known limitations / notes

- Full-screen editors (Paste text, Note editor, Import preview) use an
  `Expanded` text field that fills remaining space. With the keyboard open on a
  very small screen, the helper text/button stay pinned; the editable area
  shrinks rather than the page scrolling — expected for a full-screen editor.
- Landscape and full tablet layouts get *sanity* coverage only; a dedicated
  large-screen redesign is out of scope for v1.31.1.
