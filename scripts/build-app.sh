#!/bin/sh
set -eu

CONFIGURATION="${CONFIGURATION:-release}"
APP_DIR="${APP_DIR:-$PWD/dist/Inside Battery.app}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:--}"

sign_binary() {
    if [ "$SIGNING_IDENTITY" = '-' ]; then
        # Ad-hoc development builds cannot satisfy hardened library validation.
        codesign --force --sign - --identifier "$2" "$1"
    else
        codesign --force --sign "$SIGNING_IDENTITY" --timestamp --options runtime --identifier "$2" "$1"
    fi
}

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
FRAMEWORK='.build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework'
mkdir -p "$APP_DIR/Contents/Frameworks"
ditto "$FRAMEWORK" "$APP_DIR/Contents/Frameworks/Sparkle.framework"
SPARKLE="$APP_DIR/Contents/Frameworks/Sparkle.framework/Versions/B"
sign_binary "$SPARKLE/Autoupdate" org.sparkle-project.Autoupdate
sign_binary "$SPARKLE/Updater.app" org.sparkle-project.Sparkle.Updater
sign_binary "$SPARKLE/XPCServices/Downloader.xpc" org.sparkle-project.Downloader
sign_binary "$SPARKLE/XPCServices/Installer.xpc" org.sparkle-project.Installer
sign_binary "$APP_DIR/Contents/Frameworks/Sparkle.framework" org.sparkle-project.Sparkle
# Sign leaf binaries first. The helper embeds the exact client hash; this avoids
# a circular app/helper resource-seal dependency with local ad-hoc signatures.
SUPPORT="Sources/InsideBattery/PowerMode.swift Sources/InsideBattery/PowerHelperProtocol.swift"
SDK_PATH="${SWIFT_SDK:-$(xcrun --show-sdk-path)}"
TARGET="$(uname -m)-apple-macosx13.0"
swiftc -O -swift-version 6 -target "$TARGET" -sdk "$SDK_PATH" $SUPPORT Sources/PowerClient/main.swift -o "$APP_DIR/Contents/Helpers/InsideBatteryPowerClient"
sign_binary "$APP_DIR/Contents/Helpers/InsideBatteryPowerClient" com.insidebattery.power-client
CLIENT_HASH="$(codesign -d --verbose=4 "$APP_DIR/Contents/Helpers/InsideBatteryPowerClient" 2>&1 | sed -n 's/^CDHash=//p')"
test "${#CLIENT_HASH}" -eq 40
cp Resources/PowerHelperInfo.plist .build/PowerHelperInfo.plist
/usr/libexec/PlistBuddy -c "Set :InsideBatteryClientHash $CLIENT_HASH" .build/PowerHelperInfo.plist
swiftc -O -swift-version 6 -target "$TARGET" -sdk "$SDK_PATH" $SUPPORT Sources/PowerHelper/main.swift -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker .build/PowerHelperInfo.plist -o "$APP_DIR/Contents/Helpers/InsideBatteryPowerHelper"
sign_binary "$APP_DIR/Contents/Helpers/InsideBatteryPowerHelper" com.insidebattery.power-helper
codesign -d --verbose=4 "$APP_DIR/Contents/Helpers/InsideBatteryPowerHelper" 2>&1 | sed -n 's/^CDHash=//p' > "$APP_DIR/Contents/Resources/PowerHelperHash.txt"
cp Resources/com.insidebattery.power-helper.plist "$APP_DIR/Contents/Library/LaunchDaemons/"
sign_binary "$APP_DIR" com.insidebattery.app

echo "$APP_DIR"
