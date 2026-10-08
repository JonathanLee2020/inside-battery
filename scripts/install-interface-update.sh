#!/bin/sh
# Install the prepared interface without rebuilding or replacing the working helper.
set -eu
PROJECT='/Users/jonathanlee/Documents/projects/mac_battery'
APP="$PROJECT/dist/Inside Battery.app"
STAGED="${STAGED:-$PROJECT/.build/interface-updates/automatic-status-width-2026-10-08/Inside Battery.app}"

GUI_SERVICES=$(/bin/launchctl print "gui/$(/usr/bin/id -u)")
if printf '%s\n' "$GUI_SERVICES" | /usr/bin/grep -q 'application\.com\.insidebattery\.app\.'; then
    echo 'Quit Inside Battery from its menu, then run this command again.' >&2
    exit 1
fi

test -x "$STAGED/Contents/MacOS/InsideBattery"
/usr/bin/codesign --verify --deep --strict "$STAGED"
# Refuse to install if the interface was prepared with a different helper pair.
/usr/bin/cmp "$APP/Contents/Helpers/InsideBatteryPowerClient" "$STAGED/Contents/Helpers/InsideBatteryPowerClient"
/usr/bin/cmp "$APP/Contents/Helpers/InsideBatteryPowerHelper" "$STAGED/Contents/Helpers/InsideBatteryPowerHelper"
/usr/bin/cmp "$APP/Contents/Resources/PowerHelperHash.txt" "$STAGED/Contents/Resources/PowerHelperHash.txt"

BACKUP=$(/usr/bin/mktemp -d "$PROJECT/.build/rollback-backups/interface-install.XXXXXX")
/usr/bin/ditto "$APP" "$BACKUP/Inside Battery.app"
echo "Previous app backed up at: $BACKUP/Inside Battery.app"
/bin/cp "$STAGED/Contents/MacOS/InsideBattery" "$APP/Contents/MacOS/InsideBattery"
if [ -d "$STAGED/Contents/Frameworks/Sparkle.framework" ]; then
    /usr/bin/ditto "$STAGED/Contents/Frameworks/Sparkle.framework" "$APP/Contents/Frameworks/Sparkle.framework"
    /bin/cp "$STAGED/Contents/Info.plist" "$APP/Contents/Info.plist"
fi
/usr/bin/codesign --force --sign - "$APP"
/usr/bin/codesign --verify --deep --strict "$APP"
/usr/bin/cmp "$APP/Contents/Helpers/InsideBatteryPowerClient" "$BACKUP/Inside Battery.app/Contents/Helpers/InsideBatteryPowerClient"
/usr/bin/cmp "$APP/Contents/Helpers/InsideBatteryPowerHelper" "$BACKUP/Inside Battery.app/Contents/Helpers/InsideBatteryPowerHelper"
echo 'PASS: interface installed; working client and helper are unchanged.'
/usr/bin/open "$APP"
