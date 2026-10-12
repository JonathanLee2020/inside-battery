# Changelog

Versions preserve source snapshots and, from 0.2.0, prepared downloadable previews.

## Unreleased

## 0.2.7 — 2026-10-13 (development preview)

- Piplup is slightly darker and bluer; Chimchar uses soft red to
  distinguish it from Low Power yellow.

- Themes now occupies its own menu section, separated from Preferences and Quit.

## 0.2.6 — 2026-10-13 (development preview)

- Renamed Meadow to turtwig, Tidepool to Piplup, and Ember to Chimchar;
  existing saved selections are preserved.
- Joey uses warmer lavender. turtwig stays green across all energy modes.
- Yoshi uses green Automatic on both power sources, yellow Low Power, and
  light-lavender High Power, with green charging symbols.
- Every menu-bar battery outline is 2pt: grey Automatic, gold Low Power,
  dark-purple High Power. Energy Mode menu icons retain their thin outlines.

## 0.2.5 — 2026-10-12 (development preview)

- Saved Themes submenu with native color-swatch rows: 💜 Joey 💜, Meadow (the
  previous palette), Yoshi, Tidepool and Ember.
- Preferences replaces the Inside Battery submenu. Themes is a separate row
  immediately below it, with a four-color grid icon.
- Battery interiors stay identical across energy modes. Automatic has no
  outline, Low Power has a deeper gold outline, High Power has a dark purple
  outline. Both colored menu-bar outlines are thicker. Theme changes update the
  shared fill; the app icon remains purple and green.
- Energy Mode menu icons retain their original blue/yellow/lavender circles,
  thin native-style battery outlines and original mode glyphs.
- Yoshi now uses sunshine yellow for charge and lavender for its empty portion.
- 291 checks cover saved selections, original grey/charging green, rendering and
  percentage contrast across every theme.

Verification: 291 checks, nested signatures, ZIP round-trip and signed feed/archive
passed. Public helper/client are byte-for-byte unchanged from 0.2.4, preserving
Sparkle compatibility. Fresh public installation remains unverified.

## 0.2.4 — 2026-10-12 (development preview)

- Purple app-icon tile with a green battery fill, bundled at every macOS size.
- Automatic uses light purple; Low Power uses warm lavender with a subtle gold
  tint; High Power uses dark purple. Menu-bar progress and selected circles match.
- High Power uses white numerals and a darker empty remainder to keep charge
  level legible. Charging accessories stay visible on light and dark menu bars.
- Retains Sparkle's signed update dialog and install/relaunch flow. The public
  helper/client pair matches 0.2.3, making this a compatible in-app update.

Verification: 177 checks including number contrast and selected-icon rendering,
helper hash equality with 0.2.3, nested signatures, ZIP round-trip and signed
archive/feed preparation passed. Fresh public installation remains unverified.

## 0.2.3 — 2026-10-11 (development preview)

- Consolidated current UI and energy-data fixes with the Sparkle updater from
  0.2.2; version metadata is now 0.2.3/build 5.
- README now describes the current icons, selected-mode colors, neutral hover,
  charging details, energy-data parsing and signed install/relaunch flow.
- Documents the verified Homebrew fetch/dry run and the downloaded preview's
  Gatekeeper rejection. Developer ID signing and notarization remain pending.

This is a packaging and documentation update; Sparkle behavior is unchanged
from 0.2.2. Verification: 177 executable checks, helper signature pinning, nested
signatures, ZIP round-trip and signed feed/archive checks passed. Local 0.2.3
installed with the original helper/client unchanged; reapplying the current mode
completed without changing saved preferences. Existing public-build helper
upgrade and fresh-install verification limits remain.

## 0.2.2 — 2026-10-08 (development preview)

- Sparkle 2.10.0 integration with Check for Updates, standard update dialog and
  scheduled checks; signed archives/feeds and helper compatibility validation.
- Signed-feed checks and a disposable app's download/install/relaunch passed.
  Privileged-helper upgrades remain unverified and require manual installation.

## 0.2.1 — 2026-10-08 (development preview)

- High Power charge fill is lighter purple with a contrasting grey empty area;
  menu-bar fast-forward marks removed.
- Significant-energy parser filters unnamed system coalitions instead of
  rejecting valid responses or discarding named apps alongside them.
- Selected Energy Mode circles are blue for Automatic, yellow for Low Power,
  and purple for High Power; thin outlines and readable symbols.
- Neutral macOS hover highlights replace colored row backgrounds.
- Publisher supports versioned updates to the existing Homebrew tap.

Verification: 171 executable checks, actual energy query, rendered UI fixtures,
and source-matched release/helper signatures and ZIP round-trip. Development
preview remains ad-hoc signed, not notarized; fresh-install helper approval,
switching and restart persistence remain unverified.

## 0.2.0 — 2026-10-08 (development preview)

- Smaller grey menu details, tighter spacing, slimmer icons, centred High Power
  arrows, lighter purple, and automatic compact menu-bar sizing.
- Energy Mode mouse clicks keep the menu open without dimming during switching.
- Optional saved time-until-full display using macOS estimates.
- Prepared Apple Silicon ZIP/checksums, Homebrew tap cask, local MacPorts recipe,
  and optional Developer ID signing/notarization preparation.

- Wait for Service Management's asynchronous unregister completion before
  re-registering the helper. Setup now verifies an authenticated, read-only XPC
  response before reporting success. Add Terminal repair/status/connection
  diagnostics for desktop verification of failed helper registrations.

- Show the connected charger's reported wattage capability in the battery menu
  header, clearly labeled Charger capacity. Missing ratings remain unavailable,
  and unplugging clears the reading. This is not a live power measurement.

Verification: 168 checks, matched helper/client signatures, bundle verification
and ZIP extraction round-trip. The preview is ad-hoc signed; fresh-install
helper approval, switching and restart persistence are unverified for its pair.
Official package-manager acceptance and a stable notarized release are not claimed.

## 0.1.0 — 2026-10-08

- Native macOS menu-bar battery percentage, notification-driven updates, and
  charging, Low Power, and High Power indicators.
- Native-style Battery menu with energy-mode controls and a visible Quit action.
- Optional signed XPC helper for power-mode changes, with saved-mode verification
  and a repair action for mismatched development builds.
- Experimental significant-energy app list, guarded to macOS 26.2; status and
  empty results occupy one row.
- One app build workflow. Review variants have been retired.

Verification: executable self-checks and bundle/helper signature checks are run
for the snapshot. XCTest is unavailable in the current Command Line Tools
installation. Desktop helper approval and mode switching after registration
changes remain unverified; this is a development snapshot, not a stable release.
