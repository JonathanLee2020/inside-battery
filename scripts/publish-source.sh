#!/bin/sh
# Run in the user's Terminal: the agent sandbox cannot commit or authenticate.
set -eu
cd "$(dirname "$0")/.."

VERSION=0.1.0
REPOSITORY=inside-battery
BRANCH=initial-import

if [ "$(git branch --show-current)" != "$BRANCH" ]; then
    echo "Expected branch $BRANCH. No repository was published." >&2
    exit 1
fi
if [ -n "$(git remote)" ]; then
    echo "A remote already exists. Inspect it before publishing." >&2
    exit 1
fi
# Explicit source allowlist; generated apps, caches, and local environments stay out.
git add .gitignore CHANGELOG.md Makefile Package.swift README.md Resources Sources \
    Tests handoff.md packaging scripts
if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo "Untracked source files exist. Review and stage them before publishing." >&2
    exit 1
fi
if ! git diff --quiet; then
    echo "Unstaged source changes exist. Review and stage them before publishing." >&2
    exit 1
fi
git diff --cached --check

if ! gh auth status --hostname github.com; then
    gh auth login --hostname github.com --web --git-protocol https
fi
ACCOUNT="$(gh api user --jq .login)"
ACCOUNT_ID="$(gh api user --jq .id)"
echo "Publishing public source to $ACCOUNT/$REPOSITORY; no app binaries or releases."

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    # Keep the user's private email address out of public commit metadata.
    git -c user.name="$ACCOUNT" \
        -c user.email="$ACCOUNT_ID+$ACCOUNT@users.noreply.github.com" \
        commit -m "Create v$VERSION source snapshot for Inside Battery"
elif ! git diff --cached --quiet; then
    echo "HEAD already exists with staged changes. Review before publishing." >&2
    exit 1
fi
if ! git rev-parse --verify "refs/tags/v$VERSION" >/dev/null 2>&1; then
    git -c user.name="$ACCOUNT" \
        -c user.email="$ACCOUNT_ID+$ACCOUNT@users.noreply.github.com" \
        tag -a "v$VERSION" -m "Inside Battery $VERSION development source snapshot"
fi

gh repo create "$ACCOUNT/$REPOSITORY" --public --source . --remote origin \
    --description "Native macOS menu-bar battery app. Versioned source; no binary releases."
git push --set-upstream origin "$BRANCH" "refs/tags/v$VERSION"
gh repo view "$ACCOUNT/$REPOSITORY" --json url --jq .url
git log -1 --oneline
git tag -n
