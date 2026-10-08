#!/bin/sh
# User-authorized release publication; branch pushes only, never main.
set -eu
cd "$(dirname "$0")/.."
PROJECT="$PWD"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)
BRANCH="release/v$VERSION"
REPO='JonathanLee2020/inside-battery'
TAP_REPO='JonathanLee2020/homebrew-inside-battery'
OUT="$PROJECT/dist/releases/v$VERSION"
ARCHIVE="$OUT/InsideBattery-$VERSION-arm64.zip"
test "$(git branch --show-current)" = "$BRANCH" || { echo "Expected branch $BRANCH." >&2; exit 1; }
python3 - "$OUT/release.json" "$ARCHIVE" "$VERSION" <<'PY'
import hashlib, json, pathlib, sys
manifest = json.loads(pathlib.Path(sys.argv[1]).read_text())
archive = pathlib.Path(sys.argv[2])
assert manifest["version"] == sys.argv[3]
assert manifest["kind"] == "development", "Use a reviewed signed release workflow for stable publication."
assert manifest["sha256"] == hashlib.sha256(archive.read_bytes()).hexdigest()
print("PASS: prepared release archive matches its manifest")
PY
gh auth status --hostname github.com
# Explicit source allowlist: archives, caches, and environment files stay out.
git add .gitignore CHANGELOG.md Makefile Package.swift README.md Resources Sources \
    Tests handoff.md packaging scripts Casks
git diff --cached --check
if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo 'Untracked files outside the release allowlist exist. Inspect before publishing.' >&2
    exit 1
fi
if ! git diff --cached --quiet; then
    git -c user.name=JonathanLee2020 \
        -c user.email=48521291+JonathanLee2020@users.noreply.github.com \
        commit -m "Prepare v$VERSION development preview and package distribution"
fi
test -z "$(git status --porcelain)" || { echo 'Uncommitted changes remain; refusing to publish.' >&2; exit 1; }
git push --set-upstream origin "$BRANCH"
COMMIT=$(git rev-parse HEAD)
if gh release view "v$VERSION" --repo "$REPO" >/dev/null 2>&1; then
    echo "Release v$VERSION already exists; refusing to replace its assets." >&2
    exit 1
fi
gh release create "v$VERSION" "$ARCHIVE" "$OUT/SHA256SUMS.txt" \
    "$OUT/release.json" --repo "$REPO" --target "$COMMIT" --prerelease \
    --title "Inside Battery $VERSION — development preview" \
    --notes-file "$OUT/RELEASE-NOTES.md"
gh release view "v$VERSION" --repo "$REPO" --json url,assets --jq '{url, assets: [.assets[].name]}'

# A separate tap lets Homebrew see Casks on its default branch without changing
# the app repository's default branch or pushing either repository's main.
TAP_DIR="$PROJECT/.build/homebrew-inside-battery-v$VERSION"
if [ -e "$TAP_DIR" ]; then
    echo "Tap staging already exists: $TAP_DIR. App release published; inspect tap state before continuing." >&2
    exit 1
fi
if gh repo view "$TAP_REPO" >/dev/null 2>&1; then
    TAP_DEFAULT=$(gh repo view "$TAP_REPO" --json defaultBranchRef --jq .defaultBranchRef.name)
    git clone "https://github.com/$TAP_REPO.git" "$TAP_DIR"
    git -C "$TAP_DIR" switch -c "$BRANCH"
else
    TAP_DEFAULT="$BRANCH"
    mkdir -p "$TAP_DIR"
    git -C "$TAP_DIR" init -b "$BRANCH"
    gh repo create "$TAP_REPO" --public --source "$TAP_DIR" --remote origin \
        --description 'Homebrew tap for Inside Battery development releases'
fi
mkdir -p "$TAP_DIR/Casks"
cp Casks/inside-battery.rb "$TAP_DIR/Casks/"
cp packaging/homebrew/README.md "$TAP_DIR/README.md"
git -C "$TAP_DIR" add Casks README.md
git -C "$TAP_DIR" -c user.name=JonathanLee2020 \
    -c user.email=48521291+JonathanLee2020@users.noreply.github.com \
    commit -m "Add Inside Battery $VERSION development-preview cask"
git -C "$TAP_DIR" push --set-upstream origin "$BRANCH"
# Existing taps keep their non-main tracking branch so brew update receives
# this release without requiring users to repair a renamed default branch.
case "$TAP_DEFAULT" in
    main|master) gh repo edit "$TAP_REPO" --default-branch "$BRANCH" ;;
    "$BRANCH") gh repo edit "$TAP_REPO" --default-branch "$BRANCH" ;;
    *) git -C "$TAP_DIR" push origin "$BRANCH:$TAP_DEFAULT" ;;
esac
gh repo view "$TAP_REPO" --json url --jq .url
echo 'Published Homebrew preview command:'
echo 'brew install --cask JonathanLee2020/inside-battery/inside-battery'
echo 'MacPorts recipe is local only; no official registry submission was made.'
