#!/bin/sh
# Prepare a fresh source-built release without replacing the running dist app.
set -eu
cd "$(dirname "$0")/.."
PROJECT="$PWD"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)
NOTES="$PROJECT/packaging/releases/v$VERSION.md"
test -f "$NOTES" || { echo "Missing release notes: $NOTES" >&2; exit 1; }
ARCH=$(/usr/bin/uname -m)
KIND="${1:-}"
case "$KIND" in
    --development) export SIGNING_IDENTITY='-'; RELEASE_KIND=development ;;
    --notarized)
        case "${SIGNING_IDENTITY:-}" in
            'Developer ID Application:'*) ;;
            *) echo 'Set SIGNING_IDENTITY to your Developer ID Application identity.' >&2; exit 1 ;;
        esac
        test -n "${NOTARY_PROFILE:-}" || { echo 'Set NOTARY_PROFILE to a stored notarytool keychain profile.' >&2; exit 1; }
        export SIGNING_IDENTITY
        RELEASE_KIND=notarized ;;
    *) echo 'Usage: sh scripts/prepare-release.sh --development | --notarized' >&2; exit 1 ;;
esac
test "$ARCH" = arm64 || { echo 'This release recipe currently supports Apple Silicon only.' >&2; exit 1; }
OUT="$PROJECT/dist/releases/v$VERSION"
ARCHIVE="InsideBattery-$VERSION-$ARCH.zip"
test ! -e "$OUT/$ARCHIVE" || { echo "Archive already exists: $OUT/$ARCHIVE. Nothing overwritten." >&2; exit 1; }
mkdir -p .build/release-staging "$OUT"
STAGING=$(mktemp -d "$PROJECT/.build/release-staging/v$VERSION.XXXXXX")
export APP_DIR="$STAGING/Inside Battery.app"
export CLANG_MODULE_CACHE_PATH="$PROJECT/.build/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PROJECT/.build/module-cache"
if [ -z "${SWIFT_SDK:-}" ]; then export SWIFT_SDK="$(xcrun --show-sdk-path)"; fi
sh scripts/build-app.sh
"$APP_DIR/Contents/MacOS/InsideBattery" --self-test
sh scripts/verify-helper.sh

if [ "$RELEASE_KIND" = notarized ]; then
    ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$STAGING/notarization.zip"
    xcrun notarytool submit "$STAGING/notarization.zip" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$APP_DIR"
    xcrun stapler validate "$APP_DIR"
    spctl --assess --type execute --verbose "$APP_DIR"
fi
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$OUT/$ARCHIVE"
mkdir "$STAGING/unpacked"
ditto -x -k "$OUT/$ARCHIVE" "$STAGING/unpacked"
codesign --verify --deep --strict "$STAGING/unpacked/Inside Battery.app"
"$STAGING/unpacked/Inside Battery.app/Contents/MacOS/InsideBattery" --self-test
cp "$NOTES" "$OUT/RELEASE-NOTES.md"
python3 scripts/write-release-recipes.py "$OUT/$ARCHIVE" "$VERSION" "$RELEASE_KIND"
echo "PASS: release archive round-trip verifies: $OUT/$ARCHIVE"
echo 'Fresh-install helper approval and power switching are NOT verified by packaging.'
