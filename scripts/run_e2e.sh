#!/usr/bin/env bash
# End-to-end test on an Android emulator against LOCAL Firebase emulators.
# Prereqs: an emulator/device attached (adb devices), and
#   firebase emulators:start --only auth,firestore   (JDK 21+, from repo root)
set -euo pipefail
cd "$(dirname "$0")/../app"
DEVICE="${1:-emulator-5554}"
# `flutter drive` reinstalls the app (wiping permissions), so keep granting
# POST_NOTIFICATIONS in the background; otherwise the system dialog blocks
# the reminder step.
( for _ in $(seq 1 900); do
    adb -s "$DEVICE" shell pm grant com.homilabs.livehealthy_vitals android.permission.POST_NOTIFICATIONS 2>/dev/null || true
    sleep 1
  done ) &
GRANTER=$!
trap 'kill $GRANTER 2>/dev/null || true' EXIT
# Emulators reach the host at 10.0.2.2. A physical phone gets an adb
# reverse tunnel instead, so its own localhost maps to the host's emulators.
if [[ "$DEVICE" == emulator-* ]]; then
  HOST=10.0.2.2
else
  # Not 127.0.0.1/localhost: FlutterFire silently rewrites those to 10.0.2.2
  # on Android (emulator-only). 127.0.0.2 is still loopback, reaches the
  # adb reverse tunnel, and is left alone.
  HOST=127.0.0.2
  adb -s "$DEVICE" reverse tcp:8085 tcp:8085
  adb -s "$DEVICE" reverse tcp:9099 tcp:9099
  # Keep Play Store screenshots (emulator) separate from device-run captures.
  export E2E_SHOTS_DIR="${E2E_SHOTS_DIR:-../store/graphics/device_run_$DEVICE}"
fi
flutter drive -d "$DEVICE" \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart \
  --dart-define=FIREBASE_EMULATOR_HOST=$HOST
