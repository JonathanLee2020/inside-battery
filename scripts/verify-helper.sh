#!/bin/sh
set -eu
APP_DIR="${APP_DIR:-$PWD/dist/Inside Battery.app}"
CLIENT="$APP_DIR/Contents/Helpers/InsideBatteryPowerClient"
HELPER="$APP_DIR/Contents/Helpers/InsideBatteryPowerHelper"
REQUIREMENT="$("$HELPER" --print-client-requirement)"
codesign --verify --strict -R "=$REQUIREMENT" "$CLIENT"
echo "PASS: helper's embedded requirement accepts the bundled client"
if codesign --verify --strict -R "=$REQUIREMENT" "$APP_DIR/Contents/MacOS/InsideBattery"; then
    echo "FAIL: helper requirement accepted a different executable" >&2
    exit 1
fi
echo "PASS: helper's embedded requirement rejects a different executable"
HELPER_HASH="$(tr -d '\n' < "$APP_DIR/Contents/Resources/PowerHelperHash.txt")"
codesign --verify --strict -R "=cdhash H\"$HELPER_HASH\"" "$HELPER"
echo "PASS: client's pinned helper hash matches the bundled helper"
codesign --verify --deep --strict "$APP_DIR"
echo "PASS: complete bundle signature verifies"
plutil -lint "$APP_DIR/Contents/Library/LaunchDaemons/com.insidebattery.power-helper.plist"
echo "NOTE: approval, live XPC authentication, and privileged changes require desktop testing"
