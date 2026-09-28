# Play Store Listing — LiveHealthy: Vitals

Package: `com.homilabs.livehealthy_vitals` · Version 1.0.0 (1)

## App name (30 chars max)
LiveHealthy: Vitals

(Home-screen label is just "Vitals", the same convention as LiveHealthy: Medicine Reminder,
whose launcher label is "Medicine Reminder".)

## Short description (80 chars max)
Log BP, oxygen, pulse, weight & blood sugar — big keypad, clear charts.

## Full description
LiveHealthy: Vitals is a simple home logbook for the numbers that matter: blood pressure,
oxygen saturation (SpO2), pulse, weight and blood glucose — for yourself or for a parent or
family member you help look after.

**Made for typing numbers quickly.**
One screen per vital and an oversized on-screen keypad. A full blood-pressure reading is six
taps and Save. The time defaults to "now" and you can add a short note ("before walk",
"felt dizzy").

**See how things are going.**
A chart for each vital over the last 7, 30 or 90 days. Blood pressure shows the upper and
lower numbers together on one chart.

**Colour flags, with plain labels.**
Each reading gets a green, amber or red flag with a text label (e.g. "Normal", "High
(Stage 1)", "Prediabetic range"), based on general adult reference ranges. Blood glucose is
flagged according to when it was taken: fasting, before a meal, after a meal, or random.
BMI is worked out automatically from your latest weight and height.
The flags are for information only. They are not a diagnosis, so talk to your doctor about
your readings.

**For families.**
Track more than one person from one account, and switch between them with a tap. Your
LiveHealthy account works across the LiveHealthy apps, including LiveHealthy: Medicine Reminder.

**Reminders only if you want them.**
Optional daily reminders for any vital (for example "check fasting glucose every morning").
All reminders are off until you turn them on.

**English and Urdu.**

LiveHealthy: Vitals doesn't measure anything itself and doesn't connect to Bluetooth devices.
You enter readings taken with your own BP monitor, oximeter, glucometer or scale.

## Category
Medical

## Tags / contact
- Email: info@homilabs.org
- Website: https://livehealthy.homilabs.org/
- Privacy policy: https://livehealthy.homilabs.org/privacy-policy.html  (shared by the whole LiveHealthy family)
- Account deletion URL: https://livehealthy.homilabs.org/deleteaccount.html  (shared)

## App access (Play Console → App content → App access)
Sign-in is required. Vitals has its **own** review account, pre-filled with 30 days of demo
readings: `playstore-reviewer-vitals@homilabs.org`. The password and a ready-to-paste
instructions text are in `secrets/playstore_review_account.txt` (never committed).
Create/refresh it with `cd scripts && npm install && node create_playstore_review_account.js`.
Re-running keeps the password and refreshes the demo data; `--reset-password` rotates it (then
update Play Console).
It's kept separate from Medicine Reminder's reviewer on purpose, because that app's script
rotates its password on every run.

## Content rating (IARC questionnaire)
Category: Reference, News, or Educational / Utility. No violence, sexual content, profanity,
controlled substances, gambling, or user-to-user communication. Expected: Everyone / PEGI 3.

## Target audience
18+ (adult account holder; app not designed for children). Not a "Designed for Families" app.

## Ads
No ads.

## Health apps declaration (Play Console → App content → Health apps)
Tick exactly these:
- Health and fitness → **Nutrition and weight management** (weight logging, BMI)
- Medical → **Diseases and conditions management** (tracking BP / blood glucose over time)

Leave unticked: Activity and fitness (not exercise tracking), Disease prevention and public
health (not vaccination/screening/public-health info), Clinical decision support (flags are
for the user, not clinicians), Medical device apps (measures nothing, connects to no device,
makes no diagnostic claims), Medical reference and education, Medication and treatment
management (that's Medicine Reminder), Other.

NOT a medical device; no regulatory clearance claimed. The "informational only, not a
diagnosis" disclaimer is shown on the welcome screen, home, history, in Settings, and in the
terms.

## Data safety form
Data collected (all "collected", none "shared" with third parties; encrypted in transit;
users can request deletion — in-app and via the deletion URL):

| Data type | Collected | Purpose | Optional? |
|---|---|---|---|
| Personal info → Name | Yes | Account management, App functionality | Required |
| Personal info → Email address | Yes | Account management | Required |
| Health and fitness → Health info (vitals readings, height) | Yes | App functionality | Required to use core feature |
| App activity → Other user-generated content (reading notes) | Yes | App functionality | Optional |

Not collected: location, contacts, photos/videos, audio, messages, financial info, web
history, device/advertising IDs, app interactions/analytics, crash logs.

Data is processed by Google Firebase (Auth, Cloud Firestore) as a service provider on our
behalf, which Play treats as not "sharing".

## Permissions (final, from the release APK)
| Permission | Why |
|---|---|
| POST_NOTIFICATIONS | optional per-vital reminders (asked only when you switch one on) |
| RECEIVE_BOOT_COMPLETED | keep reminders scheduled after a restart |
| INTERNET, ACCESS_NETWORK_STATE | Firebase Auth / Firestore sync |
| VIBRATE | notification vibration (from flutter_local_notifications) |
| READ_GSERVICES, DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION | added by Firebase / AndroidX; no user-facing access |

No exact-alarm, full-screen-intent, camera, location, contacts or storage permissions.

## Assets
- Hi-res icon 512×512: `store/graphics/play_store_icon_512.png`
- Feature graphic 1024×500: `store/graphics/feature_graphic.png`
- Phone screenshots (1200×2400, within Play's 2:1 limit), upload in order:
  `store/graphics/phone_screenshots/01..08`
  01 home · 02 BP entry · 03 BP history chart · 04 glucose entry · 05 glucose history ·
  06 reminders · 07 patients · 08 Urdu
- Raw 1080×2400 device captures: `store/graphics/screenshots/`
- Icon/feature graphic source: `scripts/make_icons.py` (reproducible)

## Release notes (v1.0.0)
First release: log blood pressure, SpO2, pulse, weight and blood glucose; BMI; 7/30/90-day
charts; colour flags; optional reminders; multiple patients; English & Urdu.

## Release artifacts
- Upload to Play Console: `app/build/app/outputs/bundle/release/app-release.aab`
- Direct-install test APK (not for Play): `app/build/app/outputs/flutter-apk/app-release.apk`
- Upload key: `secrets/livehealthy-vitals-release.jks` (alias `livehealthyvitals`). This is
  a new key, separate from Medicine Reminder's. Enrol in Play App Signing when you create the
  app. Back up this key. If it's lost, you'll need Google's upload-key reset process to ship
  updates.
  SHA-256: `1F:75:E3:E8:A6:1E:6B:4D:86:74:14:11:87:B2:4E:C8:C5:7C:CE:3C:A2:E6:A7:D2:C0:81:2F:FB:12:33:85:5F`
