# Prelaunch Review — LiveHealthy: Vitals v1.0.0

Date: 2026-09-25

## Test results
| Suite | Result |
|---|---|
| `flutter analyze` | no issues |
| Dart unit tests (reference ranges at every §6 boundary, BMI, validation, keypad, models, notifications) | pass |
| Service tests on fake Firestore (readings, patients, reminders, app state, account-deletion cascade) | pass |
| Widget tests (sign-up both paths, entry/validation/urgent notice, glucose context, history edit/delete, reminders, Urdu RTL, delete-account dialog, sign-out, text contrast) | pass (82 Dart tests total) |
| Firestore rules tests on the emulator (Vitals rules + regression of every Medicine Reminder rule) | 18/18 pass |
| On-device end-to-end, Android 15 emulator against local Firebase emulators (sign-up → BP → glucose → height/BMI → charts → reminders → family member → Urdu → sign out → sign in) | pass |
| Release AAB/APK build, R8 + resource shrinking, signature check | pass |

## Real-device run (Samsung Galaxy A12 SM-A125F, Android 12)
720×1600, display zoom (density 340), **1.3× system font**. Full journey passes against local
Firebase emulators via `adb reverse` (`scripts/run_e2e.sh R58R61F3FDK`). Issues found only on
this device, all fixed:
- The welcome screen's "sign in" button was below the fold, so existing Medicine Reminder
  users couldn't see it. It's now pinned to the bottom.
- The keypad covered the required glucose "When was it taken?" chips. Keys are shorter and
  spacing is tighter on screens under 800dp tall.
- The "Reminders" nav label wrapped mid-word, and units split ("mg/" + "dL"). Both fixed.
Real-font layout assertions for these now run in the on-device test.

## Real bugs found by testing (all fixed)
1. **App couldn't render (theme).** Scaling `ThemeData.textTheme` under Material 3 hits a
   TextStyle assertion because sizes are null at that point.
2. **Invisible text.** The first fix for (1) produced colourless text styles, so almost every
   label was white-on-white on the device. The widget tests couldn't catch this; the
   screenshots did. A contrast regression test now covers it.
3. **"Could not save" on every new reading.** The write's offline timeout returned `null` into
   a `Future<String>`, a runtime type error. The reading was saved but the screen showed an
   error and stayed open.
4. **Sign-out didn't return to the welcome screen.** The auth listener awaited stream cancels
   before clearing state, and a late cancel could also kill the new subscriptions.
5. **"Reading saved" snackbar covered the next entry screen's Save button** (found on the
   device run).
6. Layout overflows: relationship dropdown ("Other family member" at 1.1× text) and the BMI row.
7. Cross-app data compatibility: the "other" relationship key differed from Medicine
   Reminder's `other family member`, and saving an edit would have rewritten it. The key is
   now aligned, and relationship is only written when the user changes it.

## Design decisions made during the build (V1)
- **Shared account = shared Firebase project.** Required so one login works in both apps.
  Account deletion therefore cascades **both apps'** data (vitals, medicines, schedules, dose
  events, purchases), and the deletion dialog and web page say so explicitly. The app
  re-authenticates *before* deleting anything, so a stale login can't leave an account with
  its data already wiped.
- **Reminders are inexact daily notifications** (normal priority): no `SCHEDULE_EXACT_ALARM`,
  no full-screen intent. This matches "does not nag unless asked" and avoids Play's
  exact-alarm policy review. The notification permission is requested only when the first
  reminder is switched on. Reminder settings live in `users/{uid}/vitalReminders` (per
  person, since the reminder belongs to whoever is being reminded).
- **Flag colours** (§6 names the bands; colours were my call):
  green = Normal · amber = BP Elevated/Stage 1, SpO2 Low, pulse Low/High, glucose
  Prediabetic, BMI Under/Overweight · red = BP Stage 2/Very high, SpO2 Critical, glucose
  Low/Diabetic, BMI Obese. "Very high" BP and "Critical" SpO2 also show a seek-care notice.
  Every flag carries its text label, so colour is never the only signal.
- **BP category = the higher of systolic/diastolic** (AHA convention). Exactly 180/120 is
  Stage 2 ("above 180 / above 120" is Very high).
- **Glucose context must be chosen** (no silent default), since it changes the flag.
- Plausibility bounds (e.g. pulse 20–250) catch typos. They are separate from the reference
  ranges and enforced in both the app and the Firestore rules.
- Offline: writes wait up to 4 s for a server acknowledgement, then are treated as queued.
  Firestore persists them locally and syncs later.

## Open items / needs the owner
- ~~Deploy Firestore rules + index~~ **Done.** Verified 2026-09-28: the production ruleset is
  byte-identical to `firebase/firestore.rules` (released 2026-09-25 19:26 UTC), and the
  `vitalReadings (type, measuredAt)` index is live. Both repos hold identical rules/index files.
- **Upload the shared website** (`live_healthy/website/`: index, privacy-policy,
  terms-and-conditions, deleteaccount) to the Hostinger site root. As of 2026-09-28 these cover
  both apps. Vitals uses the same URLs; it has no separate pages.
- Design-doc questions still open: a low-BP band (a reading like 80/50 currently shows
  "Normal", because §6 defines no low range); pediatric/pregnancy threshold sets; editable
  per-patient ranges.
- Reminder *delivery* on a real phone over a day (battery optimisation). The device run
  confirms scheduling, not an actual next-morning notification.
- Play Console's own prelaunch report (runs after the AAB is uploaded to a testing track).
