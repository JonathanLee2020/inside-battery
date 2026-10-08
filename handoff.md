# Inside Battery handoff

Updated: 8 October 2026. There is one app build: `dist/Inside Battery.app`.

## Release preparation — 0.2.1

User authorized publishing current UI and energy-parser fixes as newest release.
Source branch `release/v0.2.1`; archive built separately from running app at
`dist/releases/v0.2.1/InsideBattery-0.2.1-arm64.zip`, 205314 bytes, SHA-256
`e9d0b3147a8976c87bce83cc89cf079fbe59c8c0af18b6234d83f5076460d84a`.
171 checks, signature pinning and ZIP round-trip pass. Homebrew recipe parses
0.2.1; MacPorts lint has 0 errors/0 warnings (installed port definitions are old).
Publisher reads plist version and can update an existing public tap. It creates
a release branch and fast-forwards an existing non-main tap default branch so
existing brew update users receive changes. No direct main push or force push.
Development-preview restrictions remain: no Developer ID/notarization or tested
fresh-install helper approval/switching/restart. Live dist helper pair unchanged.
Publication pending; update this section with verified public URLs after success.

## Published release — 0.2.0

User requested downloadable versions and Homebrew/MacPorts distribution.
Prepared an Apple Silicon development-preview ZIP at
`dist/releases/v0.2.0/InsideBattery-0.2.0-arm64.zip` from the current source with
a fresh matched helper/client, separate from the working runtime pair. SHA-256:
`43e560904c309f8cbd52781ed5f4b0ff6a9782413e1be634d06f4781b3fc36dd`.
168 checks, signature tests and archive extraction round-trip pass. MacPorts
recipe lints with 0 errors/0 warnings; Homebrew's content loader parses the cask.
Initial MacPorts lint failed on an unquoted semicolon, corrected in generator.
Initial Homebrew path loading rejected a file outside an installed tap; parsing
the trusted local recipe's contents succeeds. Package install tests are pending.

No signing identity is visible in this environment; user is unsure about Apple
Developer membership. Archive is ad-hoc signed, not notarized. Fresh-install
helper approval, mode switching and restart persistence remain unverified.
No global BTM reset, permanent helper installation or current-runtime update
was performed. The user's working old helper PID 79954 remains running.

`scripts/prepare-release.sh --development` builds in `.build/release-staging`
and refuses to overwrite an existing archive. Optional Developer ID/notarytool
preparation uses `--notarized` with signing identity/keychain profile env vars.
`scripts/write-release-recipes.py` generates checksum-pinned Homebrew and local
MacPorts recipes. There is no source license grant; MacPorts uses Restrictive.

`scripts/publish-release.sh` expects branch `release/v0.2.0`, checks
the archive hash, stages an explicit source allowlist and commits the release
using GitHub noreply metadata, pushes only that branch, publishes GitHub v0.2.0 as a
prerelease, and creates a separate public `homebrew-inside-battery` tap with
the release branch as its default. No push to main, official registry submission,
Gatekeeper bypass, or silent administrator approval occurs. Initial restricted
Codex execution blocked `.git/index.lock` writes and GitHub networking. User
changed to Full access; authentication and publication then succeeded.
Release source commit: `b0dffee`, pushed on `release/v0.2.0` only.
Public prerelease: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.0
Public tap: https://github.com/JonathanLee2020/homebrew-inside-battery
Tap commit: `79d8ce8`; default branch `release/v0.2.0`.
Public ZIP downloaded without authentication: 204162 bytes, SHA-256 matches above.
Install command: `brew install --cask JonathanLee2020/inside-battery/inside-battery`.
MacPorts lint reports 0 errors/0 warnings; Homebrew content-loader
parsing passes without a recipe deprecation warning. No package installation
test has run. Original app still uses the working temporary helper.

## Current runtime rollback

NEUTRAL ENERGY MODE HOVER INSTALLED: user reversed colored hover request after
providing native battery reference. EnergyModeRow uses macOS semantic neutral
unemphasizedSelectedContentBackgroundColor and normal labelColor text; explicit
mode constructor removed. Selected icon circles remain blue/yellow/purple.
This matches the neutral native style; no claim of using Apple's private battery
control. All three row renders inspected, build and installed 171 checks pass.
Original helper/client unchanged, signature verified, app reopened after quit.
Backup: `.build/rollback-backups/interface-install.ikwNly/Inside Battery.app`.
No new commit or published release.

ENERGY MODE HOVER COLORS INSTALLED: EnergyModeRow now stores its explicit mode
and draws hover with BatteryMenu.selectionColor(for:), shared with selected icon
circles. Automatic blue, Low Power yellow, High Power lighter purple. Hover title
is black on yellow/purple, native selected text on blue. Rounded highlight shape,
mouse activation and menu tracking unchanged. All three actual row draw methods
rendered and inspected; build and installed 171 checks pass. Original helper/client
unchanged, signatures verified, app reopened after user quit. Backup:
`.build/rollback-backups/interface-install.gY1Uu2/Inside Battery.app`.
No new commit or published release.

ENERGY MODE SELECTION COLORS INSTALLED: selected Automatic circle stays blue,
Low Power uses system yellow, High Power shares BatteryIcon.highPowerColor
(lighter purple) with the menu-bar fill. Low/High use black inner symbols and
65%-black thin outlines for contrast; Automatic retains white interior and pale
outline. Unselected circles unchanged. Render inspected, build and 171 checks
pass; selected-circle pixel checks now verify each mode's hue. Installed main
only after user quit, signatures verified, original helper/client unchanged,
reopened successfully. Backup:
`.build/rollback-backups/interface-install.Kdqb26/Inside Battery.app`.
No new commit or published release.

SELECTED OUTLINE CONTRAST CORRECTION INSTALLED: shared grey outline was too dark
against blue selection. Native screenshot shows a pale outline. Selected border
and terminal now use pale blue-grey RGB 0.80/0.88/0.94, preserving 1 pt thickness,
blue circle and white interior; unselected stays grey. Render inspected, build
and installed 171 checks pass; original helper/client byte-identical, app reopened.
Backup: `.build/rollback-backups/interface-install.yAaV6X/Inside Battery.app`.
No new commit or published release.

MATCHING ENERGY MODE OUTLINES INSTALLED: selected icon appeared thicker due to
white outline; both states already used 1 pt strokes. Selected now uses the same
grey outline/terminal RGB 0.60/0.60/0.62 as unselected, retaining blue circle and
white interior symbol. Before/after render inspected, build and 171 checks pass.
Installed main only after user quit, signatures verified, original helper/client
unchanged, reopened successfully. Backup:
`.build/rollback-backups/interface-install.O5aehk/Inside Battery.app`.
No new commit or published release.

ENERGY LIST PARSER FIX INSTALLED: live `--print-energy-apps` reproduced
"The native energy response contains an invalid app identity." A raw query
returned WindowServer with empty responsible ID and display name. Parser now
filters unnamed coalitions before app identity validation, without a process-name
special case. Named invalid identities and malformed response arrays still fail.
Regression fixtures cover system-only, mixed named/unnamed, and invalid named
records. Build and 171 checks pass. Both staged and installed executable return
"No apps using significant energy" against current live macOS data, exit 0.
Installed main only after user quit; original client/helper unchanged, signature
verified, app reopened successfully. Backup:
`.build/rollback-backups/interface-install.5fsbnB/Inside Battery.app`.
No new commit or published release; v0.2.0 download predates this fix.

HIGH POWER PROGRESS VISIBILITY INSTALLED: user reported High Power appearing
full despite partial charge. Rendered before/after fixtures at 25/50/73/95/100%
reproduced near-identical purple fill and remainder. High Power now uses lighter
purple fill RGB 0.86/0.69/0.98 against grey remainder 0.62/0.62/0.66, including
while charging; purple outline lightened. Fill/remainder luminance contrast is
1.465:1. Menu-bar chevrons removed; Energy Mode row symbols unchanged.
Initial self-check failed the old dark-purple color expectation; color checks
updated to require visibly violet light fill, contrasting remainder, and purple
while charging. Build and 168 checks pass. Installed main executable only after
user quit; signature verified and original helper/client compared byte-for-byte.
Backup: `.build/rollback-backups/interface-install.ds3Zj2/Inside Battery.app`.
Reopening now succeeds with Full access. No new commit or download release.

STATUS WIDTH CORRECTION INSTALLED: user screenshot showed oversized highlighted
area after the fixed 49 pt status-item change. Restored NSStatusItem.variableLength
and removed the unused accessory slot when unplugged: icon canvas is 30 pt on
battery/unavailable, 35 pt on external power. Closer accessory positions remain.
168 checks and signatures pass, original helper/client unchanged. Actual native
status button/pill width awaits desktop confirmation (do not claim measured total).
Backup: `.build/rollback-backups/interface-install.u19QZp/Inside Battery.app`.
Automatic reopening again failed; user must reopen as before.

COMPACT MENU-BAR ICON INSTALLED: lightning/plug moved 1 pt toward the battery,
terminal narrowed slightly to retain a small gap; High Power terminal chevrons
also compressed to avoid the accessory. Icon canvas narrowed 36 to 35 pt.
Status item now has an explicit 49 pt width (35 pt image + 14 pt total padding).
Rendered icons inspected, 168 checks and signatures pass. Original helper/client
unchanged; backup `.build/rollback-backups/interface-install.RMJaom/Inside Battery.app`.
Automatic reopening failed in the agent; desktop spacing awaits user confirmation.

MODE BRIGHTNESS UPDATE INSTALLED: mode rows no longer become disabled solely
because `changingMode` is true, preventing their custom view's 40% opacity /
disabled text flash during a switch. The action guard still blocks overlapping
requests; genuinely unavailable modes remain disabled. User confirmed previous
custom rows keep the menu open, but reported the dimming. 168 checks and
signatures pass; original helper/client unchanged. Backup:
`.build/rollback-backups/interface-install.OyOoTS/Inside Battery.app`.
Reopen failed in the agent; visual no-dimming check remains pending desktop use.

PERSISTENT ENERGY MODE MENU INSTALLED: `EnergyModeRow.swift` provides custom
mouse-driven menu views for the three mode rows, sends their existing actions
without standard command selection/dismissal, and draws hover/disabled/selected
states with accessibility press support. AppDelegate refreshes mode icons in
place and disables mode clicks during a change. Completion is dispatched into
default and event-tracking run-loop modes so it can update/re-enable controls
while the menu remains open. Errors close tracking to present their alert.
Staged in `.build/interface-updates/persistent-modes-2026-10-08/Inside Battery.app`.
168 existing checks and signature checks pass. Actual keep-open clicks remain
unverified through desktop automation; user must confirm after installation.
Installed after user quit; installer preserved the working original pair.
Backup: `.build/rollback-backups/interface-install.4ci5tp/Inside Battery.app`.
Automatic reopen failed in the agent; user must reopen and test switching
between modes without dismissing the menu. Standard keyboard menu activation
still uses NSMenu behaviour; keep-open custom activation covers mouse/AX press.

UNPLUGGED PADDING UPDATE INSTALLED: header bottom padding is now uniformly 2 pt;
on-battery padding reduced from 8 to 2 pt, closing the gap between Power Source:
Battery and the divider by 6 pt. Connected padding is retained at 2 pt. 168
self-checks and signatures pass; original helper/client unchanged. Backup:
`.build/rollback-backups/interface-install.2GoRuh/Inside Battery.app`.
Automatic reopen failed in the agent; user must reopen to confirm appearance.

SLIMMER BATTERY SHAPES INSTALLED: menu-bar battery body reduced from 25x16 to
25x14 pt, centred vertically, with a proportional terminal and corner radius.
Energy Mode battery bodies reduced from 17x10 to 17x8 pt, with shorter fills,
terminals and centred High Power arrows. Icon widths/circle sizes remain the
same. A rendered preview of all modes and percentage icons was inspected;
168 self-checks and signatures pass. Original helper/client unchanged.
Backup: `.build/rollback-backups/interface-install.CcVzW9/Inside Battery.app`.
Automatic reopening failed in the agent; user must reopen and check appearance.

GREY ROW SPACING UPDATE INSTALLED: detail row pitch/field height reduced from
20 to 17 pt for source, charging estimate and charger capacity; header shrinks
accordingly, retaining title spacing and bottom padding. 168 self-checks and
installed bundle signature pass, original helper/client unchanged. Backup:
`.build/rollback-backups/interface-install.cFFaBp/Inside Battery.app`.
Automatic reopening failed in the agent; desktop appearance awaits user reopen.

HEADER TEXT UPDATE INSTALLED: regular header rows (power source/status, charge
estimate, charger capacity) changed from 13 pt labelColor to 12 pt
secondaryLabelColor to follow the native screenshot's smaller grey text.
Battery title and percentage retain 13 pt semibold labelColor. 168 checks and
signatures pass; live desktop appearance awaits user confirmation. Original
client/helper remain unchanged. Backup:
`.build/rollback-backups/interface-install.GUVWxF/Inside Battery.app`.
Automatic reopening failed again in the agent; user must open the app manually.

HEADER SPACING UPDATE INSTALLED: connected-power header bottom padding reduced
from 8 to 2 pt, shrinking the gap below charger capacity by 6 pt. Other row
spacing and on-battery padding remain the same. Staged in
`.build/interface-updates/header-spacing-2026-10-08/Inside Battery.app`, passing
168 checks and signatures. Installer points to this bundle and preserves the
original helper/client. Installed after user quit. Backup:
`.build/rollback-backups/interface-install.fjlG9x/Inside Battery.app`.
Automatic reopening failed with kLSNoExecutableErr; user must reopen the app.
Desktop appearance confirmation remains pending.

CHARGE ESTIMATE INSTALLED: `Inside Battery` submenu now includes a persistent
`Show Time Until Fully Charged` toggle (default on, UserDefaults key
`showTimeUntilFull`). While charging below 100%, header adds a time estimate
row using public IOKit `kIOPSTimeToFullChargeKey` (minutes). Hours/minutes and
singular/plural are formatted; -1 shows calculating, missing/invalid estimates
show unavailable, and paused/unplugged/full/absent batteries hide the row.
State copies retain valid estimates. Combined Power Adapter/status row remains.
Staged at `.build/interface-updates/charge-estimate-2026-10-08/Inside Battery.app`.
168 checks and signature checks pass. Live read: 89%, charging on AC, estimate
36 minutes until full. GUI/toggle behaviour requires desktop confirmation.
Installed after user quit GUI. Backup at
`.build/rollback-backups/interface-install.yzplyi/Inside Battery.app`.
Installer preserved original helper/client. Automatic reopening failed with
kLSNoExecutableErr in the agent; user must reopen the real app as before.

LATEST UI INSTALLED: unselected Energy Mode icons now have a grey outline and
terminal with a white fill in dark appearance; selected icons retain white on
blue, matching the native selected reference. Header source and charge status
now share one row, e.g. `Power Source: Power Adapter · Charging`; separate status
row removed and header height reduced by 20 pt. Charging, Not Charging, and
Fully Charged source lines were measured and fit within the 282 pt label width.
153 self-checks pass, a rendered grey-outline preview was visually inspected,
and the original helper/client remain byte-identical. Backup:
`.build/rollback-backups/interface-install.PvmF3a/Inside Battery.app`.
Automatic reopening again failed in the agent; user must reopen the real app.

COSMETIC UPDATE INSTALLED after user quit and clarified that only Energy Mode
menu icon borders should be thinned. Menu battery outlines are now 1 pt,
High Power arrows are horizontally centred, and violet colors are lighter.
Menu-bar border thickness was restored to its previous 1.5 pt in High Power /
0.75 pt otherwise before installation. Main executable alone was replaced;
original helper/client are unchanged. 153 checks and signatures pass.
Backup: `.build/rollback-backups/interface-install.jez0ZC/Inside Battery.app`.
Automatic reopen from the agent again failed with kLSNoExecutableErr; user
must open the app as before. Desktop appearance confirmation remains pending.

Pending cosmetic update after user confirmed the updated interface works:
status battery border reduced from High Power 1.5 pt to uniform 0.75 pt;
menu battery outline reduced from 1.25 pt to 1 pt; three High Power arrows
are centred as a group using the battery body's midpoint (previous group
was 1 pt left of centre); violet surface/fill/outline lightened.
Staged at `.build/interface-updates/style-2026-10-08/Inside Battery.app`.
153 checks and signatures pass. A rendered icon preview was inspected at
`/private/tmp/inside-battery-style-preview.png`. Installer now points to this
staging bundle and preserves the original client/helper. User has been asked
to quit the GUI; installation has not happened yet (GUI PID 80633 still active).

UI UPDATE INSTALLED at 10:24 after user quit the GUI and launchctl confirmed its
application service absent. Replaced only `Contents/MacOS/InsideBattery` with the
prepared current-source interface and re-signed the outer app. Original helper
and client remain byte-identical; live helper PID 79954 is still running.
Installed executable passes 153 self-checks and bundle signature verification.
This runtime is now current UI + original helper/client, not the exact original
main binary described in earlier chronological notes below. The source hides
setup when enabled and contains no Disable Quick Power Switching action.
Backup: `.build/rollback-backups/interface-install.dxt4SP/Inside Battery.app`.
Codex `open` failed with kLSNoExecutableErr even though the executable exists
and self-tests run. User must open the real app from regular Terminal/Finder;
menu visibility and switching with this updated interface await desktop checks.
`scripts/install-interface-update.sh` now uses launchctl instead of pgrep to
check for the running GUI (pgrep cannot list processes in the agent sandbox).

Pending UI-only update: user requested removal of Disable Quick Power Switching
after enablement. Current source already hides setup when enabled and has no
disable action. An updated main executable was built and staged in
`.build/interface-updates/2026-10-08/Inside Battery.app`, passing 153 checks and
bundle/client/helper signature checks. Its original client/helper are byte-for-byte
identical to the working runtime pair. Backup of the working app:
`.build/rollback-backups/menu-update.IF5AoW/Inside Battery.app`.
Termination of GUI PID 79606 failed with operation not permitted; user was asked
to quit the GUI. No runtime app files have been replaced. After user quits,
replace ONLY Contents/MacOS/InsideBattery from staging, re-sign the outer app,
verify unchanged original helper/client and live PID 79954, then reopen the app.
Do not run the full build-app.sh: that would rebuild the helper pair.

VERIFIED RECOVERY at 10:20: the user ran the temporary absolute-path diagnostic
and confirmed that power switching worked in the restored original app.
launchd spawned PID 79954 from
`/private/tmp/inside-battery-launch-test.76MBJD/com.insidebattery.power-helper.plist`.
The signed original helper and its client can therefore successfully perform a
live mode change when launchd uses the absolute executable path. The failing
SMAppService BundleProgram resolution remains unrepaired; this temporary load
does not survive a restart. Preserve the working original app/client/helper
pair. Do not rebuild in place or describe the permanent registration as fixed.

At 10:17, the user's fresh administrator logs again show launchd failing to
resolve/execute `Contents/Helpers/InsideBatteryPowerHelper`, before the helper
handles any request. The original app/client/helper signature checks pass.
`scripts/test-original-helper-launch.sh` prepares a temporary root-owned
launchd plist with `Program` set to the original helper's absolute path. It
unloads only the existing Inside Battery service, then bootstraps that temporary
definition. This is a diagnostic, not a permanent SMAppService repair; no app
files or preferences change. Shell syntax and prepare-only/plist validation
passed. Live execution requires the user's regular Terminal and remains pending.
Do not claim a successful helper launch or mode switch from preparation alone.

Follow-up at 10:13: the user's administrator `sfltool dumpbtm` output points to
the correct `dist/Inside Battery.app` and lists the daemon as enabled/allowed,
with UUID `490F33D0-1C5B-4723-8E81-836BE847BD6D`. The live launchctl service still
references BTM UUID `C2B7F40D-7294-444D-ADF1-E07F5C2BC608`, has attempted 68
launches, and reports exit 78 / spawn failed. This establishes a mismatch
between the dumped background-item record and the live submitted service;
it does not yet establish why it occurred. A restart is proposed to check
whether macOS reconstructs the live service from the current record. No
additional source/bundle changes were made; switching remains unverified.

At the user's request, the actual pre-review app bundle was restored from
`.build/retired-builds/2026-10-08/main-before-versioning.app` to
`dist/Inside Battery.app`. The previously running main process was terminated
before replacement; its launchd application service was confirmed absent. The
restored executable passes 142 self-checks and the helper/bundle signature checks.
The replaced bundle is preserved at
`.build/rollback-backups/2026-10-08-before-original-restore.app`.

This is a binary rollback, not a Git/source rollback: the current source retains
the newer menu, charger-capacity work, and helper-registration experiments below.
Those newer UI/features are not present in the restored executable. Rebuilding
will replace this restored executable with the newer source implementation;
do not claim that rebuilding reproduces the original bundle. No source edits,
version tags, or remote commits were discarded or rewritten.

The live registration was still failing with exit 78 even after the user's
outside-Codex repair printed Enabled. The restored app's original enable/disable
and macOS approval flow is available for registering its original helper. A live
mode change after restoration remains unverified. The agent sandbox's service
lookup denial is separate from the desktop helper's launch failure.
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

Latest helper investigation: desktop logs confirmed launchd's repeating
`Could not find and/or execute program ... Contents/Helpers/InsideBatteryPowerHelper`
and exit 78 (EX_CONFIG), even though the bundled executable exists. The earlier
repair used synchronous unregister followed immediately by register. Apple's
SDK documents that this call returns before the process is reaped and only the
asynchronous completion establishes when re-registration is safe. Repair now
awaits that completion. This corrects the confirmed lifecycle violation; the
live stale-registration repair remains pending desktop verification.

Added `--repair-power-helper`, `--check-power-helper`, and `--print-helper-status`.
The helper protocol's connection check is authenticated with the same pinned
signature requirements and changes no settings. UI/Terminal setup checks its
response before reporting success. Pending macOS approval is reported separately.
Registration errors and helper-side mode errors remain visible. Terminal repair
must run outside the agent sandbox, which denies mach lookup to this service.

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
4. The connected-power menu header now shows **Charger capacity: … W** from the
   public `IOPSCopyExternalPowerAdapterDetails` API. Missing ratings display
   Unavailable, and unplugging clears the rating. No live input-power measurement
   is implemented. The `system_profiler` Wattage field describes adapter capability. Current
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
PASS: 153 Inside Battery self-checks
PASS: helper's embedded requirement accepts the bundled client
PASS: helper's embedded requirement rejects a different executable
PASS: client's pinned helper hash matches the bundled helper
PASS: complete bundle signature verifies
```

The signature script intentionally emits a rejection diagnostic for the wrong
executable. Checks include state parsing, notifications, power preferences and
commands, native-energy fixtures/event structure, icon rendering and contrast,
and selected-mode icon pixels. Icon previews were visually inspected.
The charger-capacity fixtures verify a 96 W reading, preservation across mode
updates, clearing on unplug, and missing/zero handling. A test that instantiated
the header crashed with exit 134 in AppKit application registration because the
headless environment cannot register a GUI process; that UI-only check was
removed, retaining the data-path checks. The rebuilt self-checks then passed.
The live adapter reading returned unavailable, and System Information exposed
no Wattage value during this verification. A real rated value and the new header
still require desktop verification with a charger whose rating macOS reports.

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
