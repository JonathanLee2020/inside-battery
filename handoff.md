# Inside Battery handoff

Updated: 8 October 2026. There is one app build: `dist/Inside Battery.app`.
Review-build support has been removed. Earlier generated variants and the prior
handoff are archived locally under `.build/retired-builds/` and excluded from Git.

## Start here

1. Read `README.md` and `CHANGELOG.md`.
2. Build the real app with `make app`; run it with `make run`.
3. Verify desktop helper approval and switching before claiming a stable release.

## Implemented

- Native Swift/AppKit accessory app for macOS 13+, with percentage inside a
  36 × 18-point battery icon. Grey on battery, green on external power, yellow
  for Low Power, medium violet accents for High Power. Bolt and plug distinguish
  charging from plugged-in but not charging. Missing data shows a dash.
- Public IOKit notification-driven battery readings, including updates while the
  menu tracks. Low Power notifications refresh the icon. Saved High Power state
  comes from `pmset`; it is refreshed on battery/power events and menu opening.
- Native-style menu: Battery/percentage, source and charge status, Energy Mode,
  significant-energy apps, Battery Settings, app preferences, and top-level Quit.
  Selected modes use a blue circle and white battery. Empty energy results and
  query errors each use one status line; unavailable data is not reported as empty.
- Optional `SMAppService` root helper. A short-lived native XPC client and helper
  pin each other's signature hashes. Only the active console user is accepted,
  with closed mode/profile enums and saved-preference verification. No arbitrary
  shell requests or stored passwords. Setup hides after approval; connection
  failures expose a repair action. There is no standalone disable menu option.
- Launch at login through `SMAppService.mainApp`.

## File map

| Files | Responsibility |
| --- | --- |
| `Sources/InsideBattery/AppDelegate.swift`, `BatteryMenu.swift`, `main.swift` | App/menu, registration, diagnostics |
| `BatteryState.swift`, `BatteryMonitor.swift`, `BatteryIcon.swift` | State, notification subscriptions, icon rendering |
| `PowerMode.swift`, `PowerHelperProtocol.swift`, `Sources/PowerClient/`, `Sources/PowerHelper/` | Preferences, commands, signed XPC |
| `NativeEnergy.swift`, `SelfTest.swift`, `Tests/InsideBatteryTests/` | Experimental energy integration and checks |
| `scripts/`, `Resources/`, `Package.swift`, `Makefile`, `packaging/` | Build, bundle, diagnostics, future packaging template |

## Important limits

1. Native energy data uses a private `systemstats_get_top_coalitions` ABI, guarded
   to macOS 26.2. Queries occur on menu opening, normally over 120 seconds with
   five results and a minimum score of 60,000. A ten-second UI timeout does not
   terminate the native call. The development query returned nil; live app rows
   and Activity Monitor selection remain unverified. Scores are not watts.
2. Ad-hoc development signatures change on rebuild. The registered service must
   match the running build's client/helper. Earlier main/review copies shared
   the service identity but had different hashes, causing connection failures.
   The review workflow has been retired; use only the real app. Registration,
   system approval, and successful switching after a rebuild still need desktop
   verification. Do not equate registration with macOS approval.
3. A client SIGTRAP in an XPC error callback was reproduced and diagnosed from
   crash reports. Callbacks now originate in a nonisolated function. Connection
   failures produce readable errors instead of inheriting the main actor.
4. No charger-wattage display or live input-power measurement is implemented.
   The `system_profiler` Wattage field describes adapter capability. Current
   telemetry did not expose `PowerTelemetryData.SystemPowerIn` even when connected.
   Battery voltage × current describes battery power, not total adapter input.
5. Public app downloads are deferred. Developer ID signing and notarization are
   required before binary distribution; the Homebrew cask is only a template.

## Verification on 8 October 2026

The real app builds with the installed macOS 15.4 SDK and a workspace module cache:

```sh
CLANG_MODULE_CACHE_PATH="$PWD/.build/module-cache" \
SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/module-cache" \
SWIFT_SDK=/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk \
DISABLE_SWIFTPM_SANDBOX=1 sh scripts/build-app.sh
```

```text
PASS: 149 Inside Battery self-checks
PASS: helper's embedded requirement accepts the bundled client
PASS: helper's embedded requirement rejects a different executable
PASS: client's pinned helper hash matches the bundled helper
PASS: complete bundle signature verifies
```

The signature script intentionally emits a rejection diagnostic for the wrong
executable. Checks include state parsing, notifications, power preferences and
commands, native-energy fixtures/event structure, icon rendering and contrast,
and selected-mode icon pixels. Icon previews were visually inspected.

Default `make test` failed before tests: sandbox cache permissions and a reported
SDK/compiler mismatch. A source build succeeded with the above configuration,
but `swift test` failed with `no such module 'XCTest'`; the installed Command Line
Tools lack that framework. No XCTest pass is claimed. Live helper repair, approval,
mode switching with the latest helper, and the revised desktop menu remain
unverified. Computer-use inspection timed out. Attempting to terminate the last
running review copy on retirement returned `operation not permitted`.

## Source versioning

The initial development snapshot is version 0.1.0. Version tags preserve source
history; no GitHub downloadable releases or app binaries are published. Build
artifacts and local environment files are ignored. Use tagged worktrees to inspect
old versions, restore branches to build on them, or revert commits to undo changes
without rewriting shared history. See `README.md` for commands.

Git has been initialized on `initial-import` and the source staged. Commit failed
with `Unable to create '.git/index.lock': Operation not permitted`; no commit or
version tag exists yet. Restaging the final documentation/script also failed with
the same lock permission error. GitHub CLI authentication/network access failed in the
agent sandbox, and escalation is disabled. Run `sh scripts/publish-source.sh`
from the user's Terminal to authenticate, create the initial commit/tag, create
the public `inside-battery` repo, and push the branch/tag. Publication is not yet
verified. The script uses GitHub noreply metadata, excludes generated apps, does
not push to main, and does not create binary releases.
