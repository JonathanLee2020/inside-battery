# Inside Battery

A tiny, native macOS menu-bar app that puts the percentage **inside** its battery icon. Quick power switching uses an optional native privileged helper. Sparkle provides signed in-app updates; see [updater setup and verification status](packaging/sparkle/README.md).

The app icon is an original green battery on a purple rounded tile. The build
bundles `Resources/AppIcon.icns` for Finder, Launchpad and system dialogs; the
live menu-bar icon continues to show charge level and power mode.

Choose **Themes** for a saved palette with color-swatch previews:
**💜 Joey 💜** (default medium purple, slightly darker in High Power; purple animated sprite in the menu), **turtwig** (green in every mode; animated Turtwig sprite in the menu), **Yoshi** (green Automatic, yellow Low Power, light-lavender High Power; animated Yoshi without the egg or background),
**Piplup** (cool blue; animated sprite in the menu), **Chimchar** (soft red; animated sprite in the menu), or **Test Joey** (Joey purple with a grey Automatic border, listed last). Themes has its own menu section, separated from Preferences and Quit. Themes update
the menu-bar battery immediately. Themes is a
separate top-level row below Preferences, with a four-color icon. The app icon
keeps its purple-and-green artwork.

## Downloads and package managers

Version **0.2.10** is available as an **Apple Silicon development preview**, with
a ZIP archive and SHA-256 manifest on
[GitHub Releases](https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.10).
macOS 13 or newer is required; Intel builds are not included.

The preview is ad-hoc signed, not Developer ID signed or notarized. Gatekeeper
may block downloaded copies. Fresh-install helper approval, power switching,
and persistence after restarting are unverified for the release build. The
development Mac uses a temporary helper recovery, not a public installer.
Read [the release notes](packaging/releases/v0.2.10.md) before installing.

Versions 0.2.1 and earlier require one manual or Homebrew upgrade to get the
Sparkle updater. From 0.2.2, use **Preferences → Check for Updates…** for
compatible UI updates. Registered power-helper changes still require manual
installation until helper upgrades are verified.

The Homebrew preview command is:

```sh
brew tap JonathanLee2020/inside-battery
brew install --cask JonathanLee2020/inside-battery/inside-battery
```

For an existing Homebrew installation, quit Inside Battery and run:

```sh
brew update
brew upgrade --cask JonathanLee2020/inside-battery/inside-battery
```

For manual installation, download the ZIP from the release page, extract it,
move the complete app to Applications and open it. Avoid multiple app copies.

This is our own tap, not an official Homebrew Cask listing. Quarantine and macOS
helper approval remain in place. The [local MacPorts recipe](packaging/macports/README.md)
has not been submitted to the official ports tree.

Release preparation never replaces the running app:

```sh
sh scripts/prepare-release.sh --development
sh scripts/publish-release.sh
```

For a future notarized version, install a Developer ID Application certificate,
store a `notarytool` keychain profile, set `SIGNING_IDENTITY` and `NOTARY_PROFILE`,
and use `prepare-release.sh --notarized`. Publication currently accepts only
the reviewed development preview. Existing release archives/tags are not overwritten.

> macOS does not let third-party apps redraw Apple's built-in battery item. Inside Battery adds its own replacement item. Turn off **System Settings → Control Centre → Battery → Show in Menu Bar** to avoid seeing two battery icons.

## Build and run

Requirements: macOS 13 or newer and the Swift toolchain included with Xcode Command Line Tools.

```sh
make app
"dist/Inside Battery.app/Contents/MacOS/InsideBattery" --self-test
open "dist/Inside Battery.app"
```

The build bundles and signs Sparkle alongside the app and power helper. Run
self-checks from the complete app bundle so the updater framework can load.
`make run` builds and opens the app in one step. Full builds replace the local
app and helper binaries; use a separate `APP_DIR` when preserving a working
installation (see [handoff.md](handoff.md)).

`swift test` runs the XCTest suite where the installed toolchain provides XCTest.
It failed with `no such module 'XCTest'` in the current Command Line Tools
installation; no XCTest pass is claimed. The 0.2.2 release passed 177 executable
self-checks. SDK overrides for this development Mac are recorded in the handoff.

To copy the app to `~/Applications` and open it:

```sh
make install
```

Click the icon to see charging status, enable launch at login, or quit.
While connected to external power, the header also shows **Charger capacity:
96 W** (using the reported value). This is the adapter's capability, not live
input or battery charging power. A missing rating shows **Unavailable**. The
reading uses the public IOKit adapter-details API and refreshes with battery
notifications; no `system_profiler` process is run in the menu.

The menu also offers **Low Power**, **Automatic**, and **High Power** for the
current power source (battery or power adapter), followed by **Battery Settings…**.
Choose **Enable Quick Power Switching…** and approve Inside Battery in macOS
**Login Items & Extensions** once. macOS retains that approval; the app never
stores your password. Subsequent mode changes go through the approved helper and
verify the saved preference before reporting success. High Power requires supported
hardware; macOS rejects unsupported requests. Battery and adapter preferences
are independent, matching System Settings. Mode controls remain disabled until
the helper is approved. The setup row disappears after approval; there is no
in-app disable option. If a new development build cannot connect to the registered
helper, **Repair Quick Power Switching…** appears and re-registers that build's
helper. macOS Login Items & Extensions remains available to manage the helper.
Administrator authorization is required to change system power preferences;
the helper is optional. Touch ID can be used only when the macOS approval UI
offers it. A separate in-app fingerprint prompt cannot grant administrator rights.

Keep the complete app bundle in Applications before enabling the helper. For
local builds, the helper pins the exact signature hash of the bundled power
client, and the client pins the helper's signature hash. macOS XPC validates
these requirements. Only the active desktop user's signed power client is
accepted, and requests are limited to three modes and two power sources; no
arbitrary shell command is accepted. The client is a short-lived native process.
Rebuilds change signature hashes: use **Repair Quick Power Switching…** when
replacing a build. Only one build can match the registered service; quit other
copies before switching to the updated app. The menu has no standalone disable action.
Developer ID signing and notarization provide the normal trusted-download
experience; the current preview remains development-only.

The compact menu-bar battery uses bold 10.5-point black tabular numbers inside
the battery. Most themes retain the same interior across energy modes. turtwig stays green.
Yoshi Automatic stays green on both power sources, Low Power
uses the menu circle's yellow, and High Power uses a slightly deeper lavender. Yoshi uses
black numbers with a contrasting grey empty portion for readable charge level;
the deeper gold and dark purple outlines remain. Automatic has a neutral grey outline, Low Power has a deeper gold outline,
and High Power has a dark purple outline. All menu-bar battery outlines are 2pt across themes. The selected theme supplies the charge
fill: lavender, green, Yoshi mode colors, sea glass or apricot.
Yoshi Automatic has a grey empty portion and the shared 2pt grey outline.
Energy Mode menu icons retain the original blue Automatic, yellow Low Power,
and lavender High Power circles, with uniformly thin native-style battery
outlines and the original battery/fast-forward glyphs.

The icon is 30 × 18 points on battery and 35 × 18 on external power. Automatic
sizing avoids reserving an unused charging-symbol slot while unplugged. Charging
shows a lightning bolt; plugged in but not charging shows a plug. These symbols
use white on dark menu bars and black on light menu bars, except Yoshi uses
contrast-adjusted green for both symbols. No status symbol appears
on battery power. turtwig retains its green interior on both power sources.
System power-state notifications update the display, including changes made in
System Settings. Preferences are read off the main thread so power-mode detection
does not delay cable-state rendering. The menu-bar icon has no chevrons.

The menu follows the native Battery layout: a Battery/percentage header, power
source and charging status, Energy Mode options (Automatic, Low Power, High Power),
the energy-app section, and Battery Settings. Circular mode icons mark the selection.
Launch at Login is in the Preferences submenu. Quit is always a top-level menu
item. There is one app and one build workflow: `dist/Inside Battery.app`.
The header's detail rows use smaller grey text and compact spacing. Power source
and charging status share one line. Battery shapes are slim, with thin outlines.
Selected circles use blue, yellow and lavender, with the same thin native-style
battery outlines as before; hovering a mode uses a
neutral rounded highlight like the native Battery menu. Empty energy results show
only **No Apps Using Significant Energy**; errors show only **Energy data unavailable**
with details in the tooltip. Opening the menu keeps the saved High Power styling
instead of clearing it while waiting for a background preference read.

Energy Mode mouse clicks keep the menu open and retain normal brightness while
switching. Overlapping requests are blocked. The submenu also has **Show Time
Until Fully Charged**, enabled by default and saved between launches. It formats
macOS's estimate as minutes or hours and minutes, distinguishes calculating /
unavailable values, and hides stale estimates when charging stops or completes.

The **Apps Using Significant Energy** section requests Apple's native coalition list when the menu opens,
not through constant background polling. App rows carry icons and open Activity
Monitor with Control Center's native Energy-tab/bundle-selection Apple event.
The generic Activity Monitor shortcut is removed. No CPU proxy or battery-use
percentage is substituted for Apple's native data.

This integration is **experimental**, not a public API. Its function ABI,
default 120-second/5-app query with a minimum score of `120 × 500`, response
keys, and selection event were inspected in this Mac's macOS **26.2** system
binaries. Other macOS versions are deliberately disabled until verified.
Missing symbols, nil responses, and changed response schemas show **Energy data
unavailable** with a diagnostic tooltip, never a false empty list. A slow request
does not block cable updates and changes the loading row to unavailable after
10 seconds. No extra root helper access is requested.

`--print-energy-apps` runs a read-only diagnostic. The live query returned a valid
empty app list on the development Mac after fixing parsing of unnamed system
coalitions. Those entries are filtered out; malformed responses and invalid
named-app identities still report an error. Named-app results and Activity
Monitor selection are covered by fixtures, but highlighting an actual listed
app on the desktop remains unverified. Executable self-checks cover parsing,
responsible-app deduplication, invalid responses, selection command validation,
and the Apple event's structure.

After building, `sh scripts/verify-helper.sh` checks both pinned signature hashes,
rejection of a different executable, and the bundle signature. This is not a
substitute for testing macOS approval and a real mode switch on the desktop.

If a helper registration fails to launch after replacing a development build,
repair it from Terminal using the real app bundle:

```sh
"dist/Inside Battery.app/Contents/MacOS/InsideBattery" --repair-power-helper
```

Repair waits for asynchronous unregistration to complete before registering.
Exit 2 means macOS approval is still required in Login Items & Extensions. Exit
0 means the authenticated helper actually answered a read-only connection check;
it does not claim that a mode switch has been tested. Other errors exit 1 with
the failure text. `--check-power-helper` repeats only that read-only check, and
`--print-helper-status` prints the Service Management registration status.

To render a visual check of fifteen states in both appearances (after building):

```sh
swiftc Sources/InsideBattery/BatteryState.swift Sources/InsideBattery/BatteryIcon.swift Sources/InsideBattery/BatteryTheme.swift Sources/InsideBattery/PowerMode.swift scripts/render-icons.swift -o .build/render-icons
.build/render-icons
```

The preview is written to `dist/battery-preview.png`. The executable self-checks
also verify rendering and at least 4.5:1 number contrast for both appearances.

`--print-power-mode` reads the saved battery/adapter modes without changing them.

## In-app updates

Sparkle 2.10.0 checks for updates in the background. Choose **Inside Battery →
Check for Updates…** to check immediately. Its standard dialog shows the new
version and release notes, with **Skip This Version**, **Remind Me Later**, and
**Install Update**. After choosing installation, Sparkle closes the app, replaces
it, and relaunches it. Silent automatic installation is disabled.

The public update feed and archives are signed with Ed25519, and Sparkle verifies
updates before extraction. These signatures do not replace Apple's Developer ID
signing or notarization. If a registered power helper would change, the updater
blocks in-app installation and explains that a manual upgrade is required.
Compatible UI updates preserve the helper's pinned trust relationship.

Installation and automatic relaunch passed in a disposable app without a power
helper. Real Sparkle also downloaded and parsed the public signed feed. Upgrading
the real app's registered privileged helper remains unverified. See
[updater setup and verification](packaging/sparkle/README.md) for details.

## Source versions

Version tags preserve source snapshots. The public repository is
[JonathanLee2020/inside-battery](https://github.com/JonathanLee2020/inside-battery).
Generated apps, Swift build artifacts, and local environment files
are excluded from Git. See [CHANGELOG.md](CHANGELOG.md) for each version's changes
and verification limits.

The initial snapshot is tagged `v0.1.0`. Version `v0.2.10` is published from
`release/v0.2.10` as a prerelease with download assets. Publication never pushes
directly to `main`. No source license has been
selected; publishing source does not itself grant a reuse license.

To inspect an older tagged version without changing the current checkout:

```sh
git worktree add --detach ../inside-battery-v0.1.0 v0.1.0
```

To start a repair branch from that source snapshot:

```sh
git switch -c restore-v0.1.0 v0.1.0
```

Commit or stash any current edits before switching. Prefer `git revert` when
undoing a specific published change, so shared history remains intact.

## Distribution status

The working app remains at `dist/Inside Battery.app`. Release preparation builds
a separate source-matched app/client/helper set in `.build/release-staging`,
tests it, and archives it under `dist/releases/v0.2.10`. Checksum-pinned recipes
are generated from those exact bytes. The release helper pair differs from the
development Mac's preserved original pair and needs desktop install testing.
The 0.2.10 release adds five transparent animated theme sprites with 20×26pt
display bounds. 375 bundled self-checks, ZIP extraction, bundle signatures,
helper pinning, and the signed feed/archive passed. The public helper pair is
unchanged from 0.2.9. Publication details are recorded in
[handoff.md](handoff.md). The Small baseline is 18×24pt in a 28pt menu row.

The 0.2.4 release passed 177 checks, including number contrast, selected-circle
rendering and ZIP round-trip. Public archive checksum/signatures and the signed
feed verified. A real 0.2.3 Sparkle diagnostic received and parsed the 0.2.4 feed;
the published helper hash is unchanged, so the compatibility guard permits the
update for that public helper pair. Homebrew fetch/dry run passed, and the local
MacPorts recipe passed lint. Compatible installations with automatic checks
enabled are offered the release on their next check; this is not a push notification.

The 0.2.3 release passed 177 executable self-checks, nested signatures, helper
signature pinning, ZIP extraction and public archive/feed signature verification.
Homebrew fetch and install dry run of 0.2.3 passed. The local MacPorts recipe
passed lint with 0 errors and 0 warnings. The standard Sparkle diagnostic
received and parsed the signed public 0.2.3 feed; no installation was attempted. Version 0.2.2
previously passed 177 executable self-checks, app/framework/helper signatures, ZIP
extraction, public download checksum and update signatures passed. Homebrew
fetch and install dry run passed; the local MacPorts recipe passed lint with
0 errors and 0 warnings. A fresh Homebrew download also passed checksum,
extraction and bundle-signature checks, but macOS killed its self-test with
`SIGKILL`; Gatekeeper assessment rejected the quarantined app. The 177 passing
checks above were from release preparation, not that downloaded copy. Actual
package-manager installation and first launch remain unverified.

Developer ID signing, notarization, fresh-install/restart verification and
package-manager install tests remain required before calling a release stable.
The development Mac now runs 0.2.8 with Sparkle while retaining its original
working helper/client pair. Installation verified both files unchanged; a request
to reapply the current mode completed with saved power preferences unchanged.
That preserved pair differs from the public archive, so its helper compatibility
guard may require manual upgrades when checking the public feed.

## Design constraints

To regenerate the app icon from its vector drawing:

```sh
swiftc -sdk "$(xcrun --show-sdk-path)" scripts/render-app-icon.swift -o .build/render-app-icon
.build/render-app-icon
iconutil -c icns .build/app-icon.iconset -o Resources/AppIcon.icns
```

- The battery is read through Apple's public IOKit power-source API.
- It subscribes to macOS power-source notifications instead of polling. Cable and
  battery changes refresh the icon as soon as macOS delivers the event, including
  while the menu is open.
- The app is an accessory (`LSUIElement`), so it has no Dock icon.
- Launch at login uses `SMAppService`; no login-item helper is required.

For a 30-second live notification diagnostic, run the app executable with
`--watch-battery`, then unplug and reconnect the charger. Each line is an initial
reading or a macOS notification, timestamped relative to diagnostic startup.

## Regenerating theme sprites

App builds use the prepared GIFs in Resources; Pillow is needed only to regenerate
those files. With Python and Pillow 12.2 or newer, run:

```sh
python3 scripts/prepare-piplup-sprite.py
python3 scripts/theme_gif.py assets/turtwig/turtwig-sprite.gif Resources/TurtwigTheme.gif 240
python3 scripts/prepare-extra-theme-sprites.py
```

The original source GIFs remain unchanged. Frame counts, timing, transparency,
and palette error are checked during conversion. Source GIFs used by these
commands are included under assets; unused GIF experiments are not release inputs.

Release scripts accept `RELEASE_PYTHON` to choose a working Python interpreter
for plist/XML and signing helpers (for example, `RELEASE_PYTHON=python3.13`).
