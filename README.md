# Inside Battery

A tiny, native macOS menu-bar app that puts the percentage **inside** its battery icon. No Electron or third-party runtime dependencies. Quick power switching uses an optional native privileged helper.

## Downloads and package managers

Version **0.2.1** is available as an **Apple Silicon development preview**, with
a ZIP archive and SHA-256 manifest on
[GitHub Releases](https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.1).
macOS 13 or newer is required; Intel builds are not included.

The preview is ad-hoc signed, not Developer ID signed or notarized. Gatekeeper
may block downloaded copies. Fresh-install helper approval, power switching,
and persistence after restarting are unverified for the release build. The
development Mac uses a temporary helper recovery, not a public installer.
Read [the release notes](packaging/releases/v0.2.1.md) before installing.

The Homebrew preview command is:

```sh
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
make test
make run
```

`make test` runs fast executable self-checks followed by the XCTest suite.

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

The Android-inspired icon uses bold 10.5-point black tabular numbers inside a
grey battery. A lighter grey fill shows charge level; when connected to external
power, that fill turns green and a status symbol appears to the right of the
battery terminal. Black digits stay readable over both filled and unfilled
areas. The icon is 30 × 18 points on battery and 35 × 18 on external power,
with the same palette on light and dark menu bars. Automatic sizing avoids
reserving an unused charging-symbol slot while unplugged.

The menu distinguishes actively charging from plugged in but not charging (for
example, when charging is paused). Both plugged-in states show green; actively
charging shows a lightning bolt, while plugged in but not charging shows a plug.
On battery power, neither status symbol appears.

When macOS Low Power Mode is enabled, the progress fill uses the native system
yellow instead of grey or green. Plug/lightning status remains visible.
System power-state notifications update this immediately, including changes
made outside the app in System Settings.

High Power uses a medium violet battery fill/remainder, a stronger violet
outline (visible even when the green charging fill reaches 100%), and a small double-chevron beside
the battery. Charging remains green, and plug/lightning indicators remain
visible. Preferences are read off the main thread
so power-mode detection does not delay cable-state rendering.

The menu follows the native Battery layout: a Battery/percentage header, power
source and charging status, Energy Mode options (Automatic, Low Power, High Power),
the energy-app section, and Battery Settings. Circular mode icons mark the selection.
Launch at Login is in an Inside Battery submenu. Quit is always a top-level menu
item. There is one app and one build workflow: `dist/Inside Battery.app`.
Selection uses a blue circle with a white battery glyph. Empty energy results show
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

`--print-energy-apps` runs a read-only diagnostic. The native data query returned
nil inside this development environment; real app names and Activity Monitor
highlighting still require testing on an unrestricted desktop. Executable
self-checks cover parsing, responsible-app deduplication, invalid responses,
selection command validation, and the Apple event's structure.

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
swiftc Sources/InsideBattery/BatteryState.swift Sources/InsideBattery/BatteryIcon.swift scripts/render-icons.swift -o .build/render-icons
.build/render-icons
```

The preview is written to `dist/battery-preview.png`. The executable self-checks
also verify rendering and at least 4.5:1 number contrast for both appearances.

`--print-power-mode` reads the saved battery/adapter modes without changing them.

## Source versions

Version tags preserve source snapshots. The public repository is
[JonathanLee2020/inside-battery](https://github.com/JonathanLee2020/inside-battery).
Generated apps, Swift build artifacts, and local environment files
are excluded from Git. See [CHANGELOG.md](CHANGELOG.md) for each version's changes
and verification limits.

The initial snapshot is tagged `v0.1.0`. Version `v0.2.1` is published from
`release/v0.2.1` as a prerelease with download assets. Publication never pushes
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
tests it, and archives it under `dist/releases/v0.2.1`. Checksum-pinned recipes
are generated from those exact bytes. The release helper pair differs from the
development Mac's preserved original pair and needs desktop install testing.
Developer ID signing, notarization, fresh-install/restart verification and
package-manager install tests remain required before calling a release stable.

## Design constraints

- The battery is read through Apple's public IOKit power-source API.
- It subscribes to macOS power-source notifications instead of polling. Cable and
  battery changes refresh the icon as soon as macOS delivers the event, including
  while the menu is open.
- The app is an accessory (`LSUIElement`), so it has no Dock icon.
- Launch at login uses `SMAppService`; no login-item helper is required.

For a 30-second live notification diagnostic, run the app executable with
`--watch-battery`, then unplug and reconnect the charger. Each line is an initial
reading or a macOS notification, timestamped relative to diagnostic startup.
