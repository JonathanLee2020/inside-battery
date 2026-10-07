#!/bin/sh
set -eu

CONFIGURATION="${CONFIGURATION:-release}"
APP_DIR="${APP_DIR:-$PWD/dist/Inside Battery.app}"

swift_build() {
    if [ -n "${SWIFT_SDK:-}" ] && [ "${DISABLE_SWIFTPM_SANDBOX:-0}" = "1" ]; then
        swift build -c "$CONFIGURATION" --disable-sandbox --sdk "$SWIFT_SDK" "$@"
    elif [ -n "${SWIFT_SDK:-}" ]; then
        swift build -c "$CONFIGURATION" --sdk "$SWIFT_SDK" "$@"
    elif [ "${DISABLE_SWIFTPM_SANDBOX:-0}" = "1" ]; then
        swift build -c "$CONFIGURATION" --disable-sandbox "$@"
    else
        swift build -c "$CONFIGURATION" "$@"
    fi
}

swift_build
BIN_DIR="$(swift_build --show-bin-path)"

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" "$APP_DIR/Contents/Helpers" "$APP_DIR/Contents/Library/LaunchDaemons"
cp "$BIN_DIR/InsideBattery" "$APP_DIR/Contents/MacOS/InsideBattery"
cp Resources/Info.plist "$APP_DIR/Contents/Info.plist"
# Sign leaf binaries first. The helper embeds the exact client hash; this avoids
# a circular app/helper resource-seal dependency with local ad-hoc signatures.
SUPPORT="Sources/InsideBattery/PowerMode.swift Sources/InsideBattery/PowerHelperProtocol.swift"
SDK_PATH="${SWIFT_SDK:-$(xcrun --show-sdk-path)}"
TARGET="$(uname -m)-apple-macosx13.0"
swiftc -O -swift-version 6 -target "$TARGET" -sdk "$SDK_PATH" $SUPPORT Sources/PowerClient/main.swift -o "$APP_DIR/Contents/Helpers/InsideBatteryPowerClient"
codesign --force --sign - --options runtime --identifier com.insidebattery.power-client "$APP_DIR/Contents/Helpers/InsideBatteryPowerClient"
CLIENT_HASH="$(codesign -d --verbose=4 "$APP_DIR/Contents/Helpers/InsideBatteryPowerClient" 2>&1 | sed -n 's/^CDHash=//p')"
test "${#CLIENT_HASH}" -eq 40
cp Resources/PowerHelperInfo.plist .build/PowerHelperInfo.plist
/usr/libexec/PlistBuddy -c "Set :InsideBatteryClientHash $CLIENT_HASH" .build/PowerHelperInfo.plist
swiftc -O -swift-version 6 -target "$TARGET" -sdk "$SDK_PATH" $SUPPORT Sources/PowerHelper/main.swift -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker .build/PowerHelperInfo.plist -o "$APP_DIR/Contents/Helpers/InsideBatteryPowerHelper"
codesign --force --sign - --options runtime --identifier com.insidebattery.power-helper "$APP_DIR/Contents/Helpers/InsideBatteryPowerHelper"
codesign -d --verbose=4 "$APP_DIR/Contents/Helpers/InsideBatteryPowerHelper" 2>&1 | sed -n 's/^CDHash=//p' > "$APP_DIR/Contents/Resources/PowerHelperHash.txt"
cp Resources/com.insidebattery.power-helper.plist "$APP_DIR/Contents/Library/LaunchDaemons/"
codesign --force --sign - "$APP_DIR"

echo "$APP_DIR"
