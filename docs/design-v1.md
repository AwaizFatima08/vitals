# LiveHealthy Vitals — Design Document (V1 Scope)

**Status:** Design decisions locked as of this document, except where marked "Proposed" — those need your confirmation before they count as locked. Any change to what's below should be treated as a new decision, discussed and confirmed before code changes.

**App name:** LiveHealthy Vitals — locked, following the suite-wide "LiveHealthy + function" naming scheme (see LiveHealthy Pill Reminder for the other app using this scheme).

**Part of:** The LiveHealthy family of health apps. Shares one LiveHealthy account and the same multi-patient model as LiveHealthy Pill Reminder — separate, focused apps, not one combined app.

---

## 1. Purpose & Target User

An Android app for logging and tracking vital signs at home: blood pressure, oxygen saturation (SpO2), pulse, weight, and blood glucose (fasting and other contexts). Commercial intent: a Play Store product, part of the LiveHealthy suite.

Unlike the Pill Reminder app, this app is inherently a data-entry task, not a single-tap confirmation — so the design goal here is "as few taps and as large a keypad as possible," not "zero typing." The same account can serve a patient managing their own vitals or a family member managing them on a relative's behalf, using the shared multi-patient model.

---

## 2. App Structure

- One entry screen per vital type (not one crowded form for all of them) — large numeric entry, minimal on screen.
- Each entry stores: value(s), timestamp (defaults to "now," editable), which patient it belongs to, and an optional short note (e.g., "before walk," "felt dizzy").
- History and graphs are viewed per vital type, not all crammed onto one dashboard.

---

## 3. Account Model

Shared with LiveHealthy Pill Reminder: one LiveHealthy account, one or more patient profiles under it. Not a rigid one-time choice — a patient profile can be added at any time from settings, regardless of how the account started.

---

## 4. V1 Feature List

### Vitals covered, with units
- Blood pressure — systolic/diastolic, mmHg
- Oxygen saturation (SpO2) — %
- Pulse — bpm
- Weight — kg
- Blood glucose — mg/dL, tagged by context: fasting / before meal / after meal / random

### Manual entry only
No Bluetooth or connected-device support in V1. Family member or patient types in the reading after taking it with their own device (BP monitor, oximeter, glucometer, scale). Device sync is a possible V2 idea, not committed.

### Computed values
- **BMI** — calculated automatically from weight + the patient's height (captured once per patient profile).

### Reference-range color flags
Simple color-coded indicator (e.g., green/amber/red) shown against each logged reading, using general adult reference ranges (see §6 for proposed default values). Explicitly framed as informational only, not a diagnosis — wording throughout the app should avoid clinical claims.

### Optional per-vital reminders
Family member can optionally set a reminder per vital type (e.g., "check fasting glucose every morning," "check BP daily"). Off by default — this app does not nag unless asked to.

### Graphical history
- One chart per vital type.
- Blood pressure plots systolic and diastolic together as two lines on the same chart (they're only meaningful in relation to each other).
- Default date-range views: last 7 / 30 / 90 days.

---

## 5. Deferred to V2 (explicitly out of scope for V1)

- **Bluetooth-connected device support** (BP monitors, oximeters, smart scales) — deferred to keep V1 simple and avoid the wide variability in device compatibility.

---

## 6. Reference-Range Defaults (Locked)

These are general adult reference ranges commonly used in clinical practice, offered as a starting point for you to review and adjust. They are defaults, not fixed rules — a real implementation should let ranges be edited (globally, and ideally per patient, since a range appropriate for a healthy adult may not fit a child, a pregnant patient, an athlete, or someone on medication affecting heart rate or blood pressure). V1 as scoped only has one default threshold set — no separate pediatric/pregnancy profiles — worth flagging as a real limitation if the app will be used for those patients.

**Blood pressure (mmHg)**
- Normal: below 120 / below 80
- Elevated: 120–129 / below 80
- High (Stage 1): 130–139 / 80–89
- High (Stage 2): 140+ / 90+
- Very high (seek urgent care): above 180 / above 120

**Oxygen saturation (SpO2)**
- Normal: 95–100%
- Low: 90–94%
- Critical: below 90%

**Pulse (resting, bpm)**
- Low: below 60
- Normal: 60–100
- High: above 100

**Blood glucose (mg/dL) — fasting or before meal**
- Low: below 70
- Normal: 70–99
- Prediabetic range: 100–125
- Diabetic range: 126+

**Blood glucose (mg/dL) — after meal or random**
- Low: below 70
- Normal: below 140
- Prediabetic range: 140–199
- Diabetic range: 200+

**BMI**
- Underweight: below 18.5
- Normal: 18.5–24.9
- Overweight: 25–29.9
- Obese: 30+

---

## 7. Proposed Build Sequence (needs your confirmation)

Suggested, matching the incremental approach used for LiveHealthy Pill Reminder — not yet explicitly agreed:

1. **Core entry + storage for one vital type** (e.g., blood pressure) end-to-end, including the patient model — proves the pattern before repeating it five more times.
2. **Remaining vital types** using the same entry pattern, plus BMI calculation and glucose context tags.
3. **Graphical history** for all vitals.
4. **Reference-range color flags**, once real values exist to flag.
5. **Optional per-vital reminders**, last, since they're the least essential piece.

---

## 8. Open / Not Yet Decided

- Confirmation of the proposed build sequence in §7.
- Exact technical stack (likely Flutter/Firebase, matching other HomiLabs apps — to be confirmed before build starts).
- Screen-by-screen mockups / wireframes.
- Whether a pediatric/pregnancy-specific threshold set is needed, given the app may be used across different patient profiles.
