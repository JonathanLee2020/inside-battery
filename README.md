# Inside Battery

A tiny, native macOS menu-bar app that puts the percentage **inside** its battery icon. No Electron or third-party runtime dependencies. Quick power switching uses an optional native privileged helper.

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
Public distribution still requires
Developer ID signing and notarization; ad-hoc signatures are development-only.

The Android-inspired icon uses bold 10.5-point black tabular numbers inside a
grey battery. A lighter grey fill shows charge level; when connected to external
power, that fill turns green and a status symbol appears to the right of the
battery terminal. Black digits stay readable over both filled and unfilled
areas. The status item is 36 × 18 points, with the same palette on light and dark
menu bars and reserved space for the bolt to prevent layout shifts.

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
visible. The icon stays 36 × 18 points. Preferences are read off the main thread
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

To render a visual check of fifteen states in both appearances (after building):

```sh
swiftc Sources/InsideBattery/BatteryState.swift Sources/InsideBattery/BatteryIcon.swift scripts/render-icons.swift -o .build/render-icons
.build/render-icons
```

The preview is written to `dist/battery-preview.png`. The executable self-checks
also verify rendering and at least 4.5:1 number contrast for both appearances.

`--print-power-mode` reads the saved battery/adapter modes without changing them.

## Source versions

Version tags preserve source snapshots; no app binaries or downloadable releases
are published. Generated apps, Swift build artifacts, and local environment files
are excluded from Git. See [CHANGELOG.md](CHANGELOG.md) for each version's changes
and verification limits.

The initial source snapshot is staged on `initial-import`. To finish creating its
public GitHub repository from Terminal, run `sh scripts/publish-source.sh`. It
authenticates if necessary, commits the staged source with a GitHub noreply email,
creates `v0.1.0`, and pushes `initial-import` and that tag. It does not push to
`main` or create downloadable app releases. The environment preparing this
snapshot could not write the commit lock or access GitHub authentication, so
the public repository and version tag are pending until this command succeeds.

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

## Future distribution

The app bundle is built at `dist/Inside Battery.app`. Public binary distribution
is deferred. If enabled later, the release bundle needs Developer ID signing and
notarization before publishing.

The simplest package-manager route is a Homebrew tap containing a cask that downloads that signed release zip. MacPorts can use the same release archive, but maintaining both recipes before the first public release adds little value. See [`packaging/homebrew/inside-battery.rb`](packaging/homebrew/inside-battery.rb) for the release-ready template.

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
