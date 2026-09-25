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
flutter drive -d "$DEVICE" \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart \
  --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
