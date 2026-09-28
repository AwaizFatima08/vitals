# LiveHealthy: Vitals — Flutter app (see ../README.md)

Second app in the LiveHealthy suite (after LiveHealthy: Medicine Reminder). An Android app
for logging blood pressure, SpO2, pulse, weight and blood glucose at home, for yourself or a
family member. Scope: [docs/design-v1.md](docs/design-v1.md).

- **Stack:** Flutter 3.41 / Dart 3.11, Firebase Auth + Cloud Firestore, fl_chart,
  flutter_local_notifications. English + Urdu (RTL).
- **Firebase project:** `live-healthy-medreminder`, the *same* project as Medicine Reminder.
  Both apps share one LiveHealthy account and the same `users` / `patients` documents.
  Android app id `com.homilabs.livehealthy_vitals`.
- **Repo:** github.com/AwaizFatima08/vitals · **Site:** https://livehealthy.homilabs.org/

## Layout
```
app/                 Flutter app
  lib/core/vitals/   pure-Dart domain: vital types, reference ranges (§6), BMI, validation
  lib/services/      Firestore/Auth/notification services (injectable for tests)
  lib/screens/       onboarding, auth, home, entry, history, patients, reminders, settings
  test/              unit, service (fake Firestore) and widget tests
  integration_test/  on-device end-to-end journey (+ Play Store screenshots)
firebase/            firestore.rules + indexes (shared with Medicine Reminder!), rules tests
store/               Play listing text + graphics
scripts/             icons, website generator, e2e runner, backup
secrets/             release keystore + credentials (gitignored; never commit)
```

## Everyday commands
```bash
cd app && flutter analyze && flutter test                    # 82 tests
cd firebase/tests && npm install && npm test                 # 18 rules tests (JDK 21+)
firebase emulators:start --only auth,firestore               # (repo root, JDK 21+) then:
scripts/run_e2e.sh emulator-5554                             # on-device end-to-end + screenshots
cd app && flutter build appbundle --release                  # Play upload
scripts/backup.sh                                            # local + Google Drive backup
```
`flutter run --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2` runs a debug build against the
local emulators. Release builds ignore this flag.

## Shared-project rules
`firebase/firestore.rules` is deployed for **both** apps. Keep it identical in
this repo and in `live_healthy/firebase/`. Medicine Reminder's rules are unchanged; Vitals only
adds `patients/{id}/vitalReadings` and `users/{uid}/vitalReminders`. Run the rules tests
before every deploy:
```bash
firebase deploy --only firestore --project live-healthy-medreminder
```

## Website
livehealthy.homilabs.org is the shared site for the whole family: one privacy policy, one set of
terms and one account-deletion page cover every LiveHealthy app, because the account is shared.
The source lives in the Medicine Reminder repo (`live_healthy/website/`). It's hosted on
Hostinger and uploaded by hand to the site root. Vitals links to those same pages (see
`app/lib/core/constants/links.dart`).
