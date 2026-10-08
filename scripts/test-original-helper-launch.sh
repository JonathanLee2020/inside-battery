#!/bin/sh
# Temporary diagnostic: launch the preserved original helper without
# Service Management's failing BundleProgram resolution. No app files change.
set -eu

APP='/Users/jonathanlee/Documents/projects/mac_battery/dist/Inside Battery.app'
SERVICE='com.insidebattery.power-helper'
ORIGINAL="$APP/Contents/Library/LaunchDaemons/$SERVICE.plist"
HELPER="$APP/Contents/Helpers/InsideBatteryPowerHelper"

if [ "${1:-}" != '--prepare-only' ] && [ "$(/usr/bin/id -u)" != 0 ]; then
    echo 'Run this script with sudo in your regular Terminal.' >&2
    exit 1
fi

/usr/bin/codesign --verify --deep --strict "$APP"
test -x "$HELPER"
RECOVERY_DIR=$(/usr/bin/mktemp -d /private/tmp/inside-battery-launch-test.XXXXXX)
PLIST="$RECOVERY_DIR/$SERVICE.plist"
/bin/cp "$ORIGINAL" "$PLIST"
/usr/libexec/PlistBuddy -c 'Delete :BundleProgram' "$PLIST"
/usr/libexec/PlistBuddy -c "Add :Program string $HELPER" "$PLIST"
/bin/chmod 600 "$PLIST"
/usr/bin/plutil -lint "$PLIST"
echo 'Helper executable:'
/usr/libexec/PlistBuddy -c 'Print :Program' "$PLIST"
echo "Diagnostic files retained at: $RECOVERY_DIR"

if [ "${1:-}" = '--prepare-only' ]; then
    echo 'PASS: configuration prepared; no service changed.'
    exit 0
fi

# Save the loaded definition first. Any failed command stops the test visibly.
/bin/launchctl print "system/$SERVICE" > "$RECOVERY_DIR/previous-service.txt"
echo 'Unloading only the failing Inside Battery helper service.'
/bin/launchctl bootout "system/$SERVICE"
echo 'Loading the original signed helper using its absolute executable path.'
/bin/launchctl bootstrap system "$PLIST"
/bin/launchctl kickstart -p "system/$SERVICE"
/bin/launchctl print "system/$SERVICE"
echo 'Temporary service loaded. Try Low Power in Inside Battery and report the result.'
echo 'This does not install a permanent LaunchDaemon or repair the SMAppService registration.'
echo 'It changes no app files or saved power-mode preferences. A restart discards this temporary load.'
