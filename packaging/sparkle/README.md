# Sparkle updates

Sparkle 2.10.0 provides the standard version/release-notes dialog, Skip This
Version, Remind Me Later, Install Update, installation and automatic relaunch.
Automatic silent installation is disabled; the user chooses Install Update.
The app menu contains Check for Updates; Sparkle schedules background checks.

## Signing keys

Public verification key is in Resources/Info.plist. The private key is in the
login Keychain under account `inside-battery`. Do not commit or export it.
Sparkle Ed25519 signing is separate from Apple Developer ID/notarization.

Tools were downloaded from the official Sparkle 2.10.0 release into
`.build/sparkle-tools/bin`. For a new machine, download and extract
`Sparkle-2.10.0.tar.xz` from https://github.com/sparkle-project/Sparkle/releases/tag/2.10.0.
The existing signing key must be securely transferred to that machine's Keychain;
generating a different key would invalidate updates for existing installations.

## Feed preparation

Build a release with `scripts/prepare-release.sh`, then prepare the signed feed:

```sh
python3 scripts/prepare-update-feed.py dist/releases/vVERSION/InsideBattery-VERSION-arm64.zip \
  --notes packaging/releases/vVERSION.md --output .build/update-VERSION/appcast.xml
```

The script checks the archive's verification key, signs/verifies the archive,
adds version, notes and helper compatibility metadata, then signs/verifies the
feed. It refuses to overwrite existing staging files. It never publishes.
An empty signed bootstrap feed can be prepared by omitting archive and notes.

The configured HTTPS endpoint is the `appcast.xml` asset of a dedicated
`update-feed` GitHub release. It is live for 0.2.2. The release publisher
uploads the signed feed snapshot alongside the versioned ZIP, then creates or
updates that dedicated feed release. Keep versioned archives immutable.

## Helper compatibility

Registered helpers pin exact binary hashes. A UI-only update with the same helper
is allowed. Missing or changed helper metadata blocks in-app installation with
an explanatory error; the running app and service are untouched. Changed-helper
upgrades require a manual installation and still need desktop verification.
Metadata is protected by the signed feed; archives are verified before extraction.

## Verification status

The separate `.build/updater-integration/Inside Battery.app` is for verification;
do not register its helper or replace the working local app's helper with it.
Build, executable checks, nested signatures and feed signing are verified.
A disposable app without a power helper passed replacement and automatic relaunch
through the standard Sparkle dialog after the user clicked Install and Relaunch.
Real Sparkle downloaded and parsed the public HTTPS feed. Public archive checksum
and Ed25519 signatures matched; Homebrew fetch of 0.2.2 passed.
Privileged-helper upgrades remain unverified and require manual installation.
Users on 0.2.1 need one manual/Homebrew upgrade to the first updater-enabled release.

Sparkle and its bundled components' redistribution notices are in [LICENSE](LICENSE).
The release publisher attaches these notices to updater-enabled releases.
